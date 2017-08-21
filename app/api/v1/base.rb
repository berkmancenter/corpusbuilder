class V1::Base < Grape::API
  mount V1::Editors
end
