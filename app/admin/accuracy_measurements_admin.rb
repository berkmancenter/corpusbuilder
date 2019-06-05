Trestle.resource(:accuracy_measurements) do
  menu do
    item :accuracy_measurements, icon: "fa fa-stethoscope"
  end

  controller do
    def start
      measurement = admin.find_instance(params)

      ProcessAccuracyMeasurementJob.perform_later \
        measurement: measurement

      measurement.scheduled!

      flash[:message] = "The model's has been scheduled to be measured"

      redirect_to admin.path(:show, id: measurement)
    end
  end

  routes do
    post :start, on: :member
  end

  build_instance do |attrs, params|
    document_ids = attrs.delete(:document_ids)

    instance = model.new(attrs)

    instance.bootstrap_sample_size ||= 100
    instance.bootstrap_number ||= 100
    instance.seed ||= rand(1..10000)

    if document_ids.present?
      instance.assigned_document_ids = document_ids.reject(&:empty?)
    end

    instance
  end

  save_instance do |instance, attrs, params|
    action = AccuracyMeasurements::Persist.run(
      model: instance
    )

    if !action.result
      for error in action.errors.full_messages
        instance.errors.add(:base, error)
      end
    end

    action.result
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
        if measurement.sampled?
          concat tag.div "The process isn't started. After clicking on the below button, you won't be able to edit or delete this measurement until it succeeds or fails.", class: 'alert alert-info'
          concat link_to 'Start Measuring', admin.path(:start, id: measurement.id), class: 'btn btn-primary', method: :post
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
