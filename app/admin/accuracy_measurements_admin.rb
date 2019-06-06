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
        concat tag.div measurement.status, class: "badge measurement-status", data: { status: measurement.status }
        concat tag.div "&nbsp;".html_safe

        if measurement.sampled?
          concat tag.div "The process isn't started. After clicking on the below button, you won't be able to edit or delete this measurement until it succeeds or fails.", class: 'alert alert-info'
          concat link_to 'Start Measuring', admin.path(:start, id: measurement.id), class: 'btn btn-primary', method: :post
        end

        if measurement.scheduled?
          concat tag.div "This measurement has been scheduled to be processed. Waiting now for all the sampled lines to be OCRed", class: 'alert alert-info'
        end

        if measurement.ocring?
          concat tag.div "OCRing the line samples now", class: 'alert alert-info'
        end

        if measurement.ocred?
          concat tag.div "The sampled lines have been OCR'ed. Waiting now to match them against ground truth and compute the metrics", class: 'alert alert-info'
        end

        if measurement.summarizing?
          concat tag.div "Computing metrics now", class: 'alert alert-info'
        end

        if measurement.ready?
          concat tag.div "All the metrics have been computed"
          concat tag.span "Normalized grapheme-level edit distance: "
          concat tag.div "&nbsp;".html_safe
          concat tag.b('%.6f' % measurement.confusion_matrix.normalized_edit_distance)
        end
      end
    end
  end

  table do
    column :model do |object|
      if object.ocr_model.present?
        backend = object.ocr_model.backend.to_s.titleize
        "#{backend}<br /><b>#{object.ocr_model.name}</b><br />version: #{object.ocr_model.version_code}".html_safe
      else
        "---"
      end
    end
    column :status do |object|
      "<span class='badge'>#{object.status}</span>".html_safe
    end
    column :normalized_edit_distance do |object|
      if object.confusion_matrix.empty?
        '---'
      else
        '%.6f' % object.confusion_matrix.normalized_edit_distance
      end
    end
    column :documents do |object|
      links = object.accuracy_document_measurements.map do |dm|
        link_to dm.document.title, trestle.edit_documents_admin_path(id: dm.document.id)
      end
      html = <<-UL
      <ul>
        #{ links.map { |link| "<li>#{link}</li>" }.join('') }
      </ul>
      UL
      html.html_safe
    end
    column :bootstrap do |object|
      "Samples: #{object.bootstrap_number}<br />Sample size: #{object.bootstrap_sample_size}".html_safe
    end
    column :updated_at do |object|
      "#{time_ago_in_words object.updated_at} ago"
    end
    actions
  end
end
