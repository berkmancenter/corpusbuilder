class V1::ImagesAPI < Grape::API
  include V1Base

  resource :images do
    desc "Stores the image scan upload"
    params do
      requires :file, type: File
      optional :name, type: String
    end
    post do
      authorize!

      async! Images::Create,
        file_id: Files::Stash.run!(file: params[:file]).result.id,
        name: params[:name]
    end
  end

end
