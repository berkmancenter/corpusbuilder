Trestle.resource(:ocr_models) do
  menu do
    item :ocr_models, icon: "fa fa-star"
  end

  save_instance do |instance|
    if instance.persisted?
    else
      action = OcrModels::Create.run(
        model: instance
      )

      if !action.result
        for error in action.errors.full_messages
          instance.errors.add(:base, error)
        end
      end

      action.result
    end
  end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end

  # Customize the form fields shown on the new/edit views.
  #
  form do |ocr_model|
    select :backend, OcrModel.backends.keys.map { |k| [ k.to_s.titleize, k ] }
    text_field :filename
    text_field :name
    select :languages, LanguageList::COMMON_LANGUAGES.map { |l| [l.name, l.iso_639_3] }, {}, { multiple: true }
    select :scripts, ScriptList::ALL.map { |s| [s.name, s.code] }, {}, { multiple: true }
    text_field :version_code

    #row do
    #  col(xs: 6) { datetime_field :updated_at }
    #  col(xs: 6) { datetime_field :created_at }
    #end
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:ocr_model).permit(:name, ...)
  # end
end
