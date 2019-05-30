class V1::ModelsAPI < Grape::API
  include V1Base

  resource :models do
    desc 'Lists OCR models'
    params do
      optional :backend, type: String
      optional :scripts, type: Array[String]
      optional :languages, type: Array[String]
    end
    get '' do
      present OcrModels::QueryAll.run!(
        backend: params[:backend],
        scripts: params[:scripts],
        languages: params[:languages]
      ).result, with: OcrModel::Simple
    end
  end
end
