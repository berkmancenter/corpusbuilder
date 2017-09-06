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

      present action!(Images::Create), with: Image::Short
    end
  end

end
