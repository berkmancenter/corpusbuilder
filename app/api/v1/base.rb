class V1::Base < Grape::API
  mount V1::EditorsAPI
  mount V1::ImagesAPI
end
