class V1::DocumentsAPI < Grape::API
  include V1Base

  resources :documents do
    desc "Starts up the process of the document creation. The resulting document initially is in the \"not ready\" state and awaits the data from the OCR pipeline."
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

    desc "Returns document status"
    get ':id/status', requirements: { id: uuid_pattern } do
      authorize!

      document = Document.only_status.find(params[:id])

      with_authorized_document document do
        present document, with: Document::Status
      end
    end
  end
end
