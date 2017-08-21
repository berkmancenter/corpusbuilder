class V1::Editors < Grape::API
  include V1Base

  resource :editors do
    params do
      requires :email, type: String, desc: 'Email address that identifies the editor in the network'
      optional :first_name, type: String, desc: 'First name'
      optional :last_name, type: String, desc: 'Last name'
    end
    post do
      Editors::Create.run
      # todo: implement me
    end

    desc "All"
    get :all do
      [ 1, 2, 3 ]
    end
  end
end
