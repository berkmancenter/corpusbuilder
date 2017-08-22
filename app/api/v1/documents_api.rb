class V1::DocumentsAPI < Grape::API
  include V1Base

  resources :documents do
    desc <<-doc
     Starts up the process of the document creation.
     The resulting document initially is in the "not ready"
     state and awaits the data from the OCR pipeline.
    doc
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
      action! Documents::Create
    end
  end
end
