class V1::DocumentsAPI < Grape::API
  include V1Base

  helpers do
    def infer_revision!
      @revision_options = {}
      if uuid_pattern.match?(params[:revision])
        if @document.revisions.where(id: params[:revision]).empty?
          error!('Revision doesn\'t exist', 422)
        end

        @revision_options[:revision_id] = params[:revision]
      else
        if @document.branches.where(name: params[:revision]).empty?
          error!('Branch doesn\'t exist', 422)
        end

        @revision_options[:branch_name] = params[:revision]
      end
    end

    def revision_from_params(params_name = :revision, options = { required: true })
      if uuid_pattern.match?(params[params_name])
        revision = @document.revisions.where(id: params[params_name]).first

        if !revision.present? && options[:required]
          error!('Revision doesn\'t exist', 422)
        else
          return revision
        end
      else
        branch = @document.branches.where(name: params[params_name]).first

        if !branch.present? && options[:required]
          error!('Branch doesn\'t exist', 422)
        end

        return branch.try(:revision)
      end
    end
  end

  resources :documents do
    desc %Q{Starts up the process of the document creation.
            The resulting document initially is in the
            \"not ready\" state and awaits the data from the
            OCR pipeline}
    params do
      requires :images, type: Array do
        requires :id, type: String
      end
      requires :metadata, type: JSON do
        requires :title, type: String
        optional :author, type: String
        optional :authority, type: String
        optional :date, type: String
        optional :editor, type: String
        optional :license, type: String
        optional :notes, type: String
        optional :publisher, type: String
      end
      requires :editor_email, type: String
    end
    post do
      authorize!

      # todo: return meaningful error when editor isn't found

      action! Documents::Create, params.merge(app: @current_app)
    end

    desc "Returns a list of all documents within the app"
    get do
      authorize!

      present Documents::QueryAll.run!(
        app: @current_app,
        status: Document.statuses[:ready]
      ).result, with: Document::Simple
    end

    namespace ':id', requirements: { id: uuid_pattern } do
      before do
        authorize!

        @document = Document.find(params[:id])

        if @current_app.id != @document.app_id
          error!('You don\'t own the document', 403)
        end
      end

      desc "Returns document info"
      get do
        present @document, with: Document::Simple
      end

      desc "Returns document status"
      get 'status' do
        present @document, with: Document::Status
      end

      desc %Q{Returns surfaces, zones and graphemes in a tree format.
             The returning tree can be cut to specific surfaces, zones and/or areas.
             It also allows to specify for which version of the document
             the data should come from. The version can be either a branch name
             or a revision id (uuid).}
      params do
        optional :surface_number, type: Integer
        given :surface_number do
          optional :area, type: Hash do
            requires :ulx, type: Integer
            requires :uly, type: Integer
            requires :lrx, type: Integer
            requires :lry, type: Integer
          end
        end
      end
      get ':revision/tree' do
        infer_revision!

        data_options = {}.merge @revision_options

        if params.key? :surface_number
          data_options[:surface_number] = params[:surface_number]
        else
          if params.key? :area
            error!("Cannot specify an area without a surface number", 422)
          end
        end

        if params.key? :area
          data_options[:area] = Area.new ulx: params[:area][:ulx],
            uly: params[:area][:uly],
            lrx: params[:area][:lrx],
            lry: params[:area][:lry]
        end

        present @document, { with: Document::Tree }.merge(data_options)
      end

      desc 'Returns a diff of changes for a revision with respect to other revision'
      params do
        optional :other_revision, type: String
      end
      get ':revision/diff' do
        revision1 = revision_from_params :revision
        revision2 = revision_from_params(:other_revision, required: false) ||
          revision1.parent

        present Graphemes::QueryDiff.run!(
            revision_left: revision2,
            revision_right: revision1
          ).result,
          with: Grapheme::Diff
      end

      desc 'Merged changes from other branch or revision'
      params do
        requires :other_branch, type: String
      end
      put ':branch/merge' do
        current_branch = @document.branches.where(name: params[:branch]).first
        other_branch = @document.branches.where(name: params[:other_branch]).first

        updated_branch = action! Branches::Merge, branch: current_branch, other_branch: other_branch

        if updated_branch.conflict?
          error!('Merge Conflict!', 409)
        end
      end

      desc 'Adds corrections on a given revision'
      params do
        requires :graphemes, type: Array do
          optional :id, type: String
          optional :value, type: String
          optional :surface_number, type: Integer
          optional :position_weight, type: String
          optional :delete, type: Boolean
          optional :area, type: Hash do
            requires :ulx, type: String
            requires :uly, type: String
            requires :lrx, type: String
            requires :lry, type: String
          end
        end
      end
      put ':revision/tree' do
        infer_revision!

        action! Documents::Correct, @revision_options.merge(
          document: @document,
          graphemes: params[:graphemes]
        )
      end

      desc 'Lists branches for the document'
      get 'branches' do
        present @document.branches, with: Branch::Simple
      end

      desc 'Branches off of a given revision'
      params do
        requires :revision, type: String
        requires :name, type: String
      end
      post 'branches' do
        infer_revision!
        require_editor!

        parent_revision_id = @revision_options.fetch(:revision_id, nil) ||
          @document.branches.where(name: @revision_options[:branch_name]).select(:revision_id).first.revision_id

        action! Branches::Create, parent_revision_id: parent_revision_id,
          editor_id: @editor_id,
          name: params[:name],
          document_id: params[:id]
      end
    end

  end
end
