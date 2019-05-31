Trestle.resource(:accuracy_measurements) do
  menu do
    item :accuracy_measurements, icon: "fa fa-stethoscope"
  end

  build_instance do |attrs, params|
    #file = attrs.delete(:model_file)

    instance = model.new(attrs)

    instance.bootstrap_sample_size ||= 100
    instance.bootstrap_number ||= 100
    instance.seed ||= rand(1..10000)

    #instance.file = file

    instance
  end

  form do |measurement|
    select :ocr_model_id,
      OcrModel.all.map { |m| [ "#{m.backend.to_s.titleize}: #{m.name} (ver #{m.version_code})", m.id ] },
      { include_blank: true },
      { disabled: !measurement.initial? }
    select :document_ids,
      Document.ready.map { |d| [ "#{d.title} (#{(d.languages || []).join ','})", d.id ] },
      { include_blank: true, label: 'Documents' },
      { disabled: !measurement.initial?, multiple: true }
    number_field :bootstrap_sample_size, { min: 0 , disabled: !measurement.initial? }
    number_field :bootstrap_number, { min: 1 , disabled: !measurement.initial? }
    number_field :seed, disabled: !measurement.initial?

    if measurement.persisted?
      sidebar do
        if measurement.initial?
          concat tag.div "The process isn't started. After clicking on the below button, you won't be able to edit or delete this measurement until it succeeds or fails.", class: 'alert alert-info'
          concat link_to 'Start Measuring', '#', class: 'btn btn-primary'
        end
      end
    end
  end

  table do
    column :id do |object|
      link_to excerpt(object.id, '', radius: 4),
        trestle.edit_accuracy_measurements_admin_path(id: object.id)
    end
    column :model do |object|
      if object.ocr_model.present?
        "#{object.ocr_model.backend.to_s.titleize}: #{object.ocr_model.name} (ver #{object.ocr_model.version_code})"
      else
        "---"
      end
    end
    column :bootstrap do |object|
      "#{object.bootstrap_number} times with #{object.bootstrap_sample_size} lines in sample"
    end
    column :status
    actions
  end
end
