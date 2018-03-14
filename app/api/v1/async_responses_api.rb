class V1::AsyncResponsesAPI < Grape::API
  include V1Base

  resource :async_responses do
    desc "Retrieves the async response"
    get ':id' do
      authorize!
      infer_editor!

      async = AsyncResponse.find(params[:id])

      if async.initial?
        status 202
      else
        data = async.payload
        content_type 'application/json'

        if async.error?
          async.delete
          error!(data, 500)
        else
          status 200

          return data
        end
      end
    end
  end
end

