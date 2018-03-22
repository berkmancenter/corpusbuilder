class V1::DocumentsAPI < Grape::API
  include V1Base

  resources :documents do
    desc %Q{Starts up the process of the document creation.
            The resulting document initially is in the
            \"not ready\" state and awaits the data from the
            OCR pipeline}
    params do
      requires :images, type: Array do
        requires :id, type: String
      end
      requires :metadata, type: Hash do
        requires :title, type: String
        optional :authority, type: String
        optional :date, type: String
        optional :editor, type: String
        optional :license, type: String
        optional :notes, type: String
        optional :publisher, type: String
      end
      requires :editor_email, type: String
      optional :backend, type: String
    end
    post do
      authorize!

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

    params do
      requires :metadata, type: Hash do
        requires :title, type: String
        optional :authority, type: String
        optional :date, type: String
        optional :editor, type: String
        optional :license, type: String
        optional :notes, type: String
        optional :publisher, type: String
      end
    end
    get 'similar' do
      authorize!

      # todo: implement querying only for the ones that are similar
      present Documents::QueryAll.run!(
        app: @current_app,
        status: Document.statuses[:ready]
      ).result, with: Document::Simple
    end

    namespace ':id', requirements: { id: uuid_pattern } do
      before do
        fetch_and_authorize_document!
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
        infer_editor!

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

        data_options[:editor_id] = @editor_id

        present @document, { with: Document::Tree }.merge(data_options)
      end

      desc 'Returns a diff of changes for a revision with respect to other revision'
      params do
        optional :other_revision, type: String
      end
      get ':revision/diff' do
        revision1 = revision_from_params :revision
        revision2 = revision_from_params(:other_version, required: true)

        present Graphemes::QueryDiff.run!(
            revision_left: revision1,
            revision_right: revision2
          ).result,
          with: Grapheme::Diff
      end

      desc 'Merged changes from other branch or revision'
      params do
        requires :other_branch, type: String
      end
      put ':branch/merge' do
        infer_editor!

        current_branch = @document.branches.where(name: params[:branch]).first
        other_branch = @document.branches.where(name: params[:other_branch]).first

        async! Branches::Merge,
          branch: current_branch,
          other_branch: other_branch,
          current_editor_id: @editor_id
      end

      desc 'Resets the working revision for a given branch'
      put ':branch/reset' do
        branch = @document.branches.where(name: params[:branch]).first

        action! Branches::Reset, branch: branch
      end

      desc 'Removes the branch'
      delete ':branch' do
        infer_editor!

        branch = @document.branches.where(name: params[:branch]).first

        action! Branches::Remove, branch: branch, editor_id: @editor_id
      end

      desc 'Commits changes from the working tree into the branch'
      put ':branch/commit' do
        branch = @document.branches.where(name: params[:branch]).first

        action! Branches::Commit, branch: branch
      end

      desc 'Adds corrections on a given revision'
      params do
        requires :words, type: Array do
          requires :grapheme_ids, type: Array
          requires :text, type: String
          optional :area, type: Hash do
            requires :ulx, type: String
            requires :uly, type: String
            requires :lrx, type: String
            requires :lry, type: String
          end
        end
        requires :surface_number, type: Integer
      end
      put ':revision/tree' do
        infer_revision!
        infer_editor!

        specs = Documents::CompileCorrections.run! words: params[:words],
          surface_number: params[:surface_number],
          revision_id: @revision_options[:revision_id],
          document: @document,
          branch_name: @revision_options[:branch_name]

        action! Documents::Correct, @revision_options.merge(
          document: @document,
          graphemes: specs.result,
          editor_id: @editor_id
        )
      end

      desc 'Lists branches for the document'
      get 'branches' do
        infer_editor!

        present @document.branches,
          with: Branch::Simple,
          editor_id: @editor_id
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
