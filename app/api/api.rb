class API < Grape::API
  insert_after Grape::Middleware::Formatter, Grape::Middleware::Logger, {
    headers: :all
  }

  mount V1::Base
end
