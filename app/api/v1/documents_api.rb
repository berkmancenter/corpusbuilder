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
    end
    post do
      authorize!

      action! Documents::Create, app: @current_app
    end

    namespace ':id', requirements: { id: uuid_pattern } do
      before do
        authorize!

        @document = Document.find(params[:id])

        if @current_app.id != @document.app_id
          error!('You don\'t own the document', 403)
        end
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
      get ':revision/tree' do
        if uuid_pattern.match?(params[:revision])
          if @document.revisions.where(id: params[:revision]).empty?
            error!('Revision doesn\'t exist', 422)
          end
        else
          if @document.branches.where(name: params[:revision]).empty?
            error!('Branch doesn\'t exist', 422)
          end
        end

        present @document, with: Document::Tree
      end
    end

  end
end
