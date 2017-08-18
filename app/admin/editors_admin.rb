Trestle.resource(:editors) do
  menu do
    item :editors, icon: "fa fa-user"
  end

  table do
    column :avatar, header: false do |editor|
      avatar_for(editor)
    end
    column :email
    column :first_name
    column :last_name
    actions
  end

  form do |editor|
    text_field :email
    text_field :first_name
    text_field :last_name
  end

  params do |params|
    params.require(:editor).require(:email)
    params.require(:editor).permit(:email, :first_name, :last_name)
  end
end
