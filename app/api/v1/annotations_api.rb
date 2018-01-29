class V1::AnnotationsAPI < Grape::API
  include V1Base

  resource :documents do
    namespace ':id', requirements: { id: uuid_pattern } do
      before do
        fetch_and_authorize_document!
      end

      namespace ':revision' do
        before do
          infer_revision! fetch: true
        end

        resource :annotations do
          before do
            infer_editor!
          end

          desc "Creates a new annotation within the document"
          params do
          requires :content, type: String
            requires :areas, type: Array do
              requires :ulx, type: Integer
              requires :lrx, type: Integer
              requires :uly, type: Integer
              requires :lry, type: Integer
            end
          end
          post  do
            action! Annotations::Create, content: params[:content],
              editor_id: @editor_id,
              revision: @revision,
              areas: params[:areas].map { |a| Area.new(a) }
          end
        end
      end
    end
  end
end
