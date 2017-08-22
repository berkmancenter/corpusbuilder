class V1::EditorsAPI < Grape::API
  include V1Base

  resource :editors do

    desc "Creates a new editor"
    params do
      requires :email, type: String, desc: 'Email address that identifies the editor in the network'
      optional :first_name, type: String, desc: 'First name'
      optional :last_name, type: String, desc: 'Last name'
    end
    post do
      action! Editors::Create
    end

  end
end
