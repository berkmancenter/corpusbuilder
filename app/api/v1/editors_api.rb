class V1::EditorsAPI < Grape::API
  include V1Base

  resource :editors do
    params do
      requires :email, type: String, desc: 'Email address that identifies the editor in the network'
      optional :first_name, type: String, desc: 'First name'
      optional :last_name, type: String, desc: 'Last name'
    end
    post do
      action = Editors::Create.run email: params[:email],
        first_name: params[:first_name],
        last_name: params[:last_name]
      if action.valid?
        action.result
      else
        status_fail
        action.errors
      end
    end

    get do
      Editor.all
    end
  end
end
