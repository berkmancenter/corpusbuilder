Trestle.resource(:apps) do
  menu do
    item :apps, icon: "fa fa-list-alt"
  end

  table do
    column :name
    column :id
    actions
  end

  form do |app|
    if app.persisted?
      text_field :id, disabled: true
      text_field :secret, disabled: true
    end
    text_field :name
    text_area :description
  end

  params do |params|
    params.require(:app).require(:name)
    params.require(:app).permit(:name, :description)
  end
end
