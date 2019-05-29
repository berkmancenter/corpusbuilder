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

    desc 'OCRs a single line for a document and returns the text'
    params do
      required :zone_id, Integer
    end
    get ':id/zone-text-transcription' do
      authorize!

      async! OcrModels,
        model_id: params[:id],
        zone_id: params[:zone_id]
    end
  end
end
