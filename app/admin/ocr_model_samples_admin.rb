Trestle.resource(:ocr_model_samples) do
  menu do
    item :ocr_model_samples, icon: "fa fa-image", label: 'Model Image Examples'
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :id do |sample|
      link_to excerpt(sample.id, '', radius: 4),
        trestle.edit_ocr_model_samples_admin_path(id: sample.id)
    end
    column :model do |sample|
      if sample.ocr_model.present?
        "#{sample.ocr_model.backend}: #{sample.ocr_model.name}"
      else
        "---"
      end
    end
    column :sample_image do |sample|
      image_tag sample.sample_image
    end
    actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |ocr_model_sample|
    collection_select :ocr_model_id, OcrModel.where({}), :id, :name, include_blank: true

    image_field :sample_image, ocr_model_sample.sample_image
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:ocr_model_sample).permit(:name, ...)
  # end
end
