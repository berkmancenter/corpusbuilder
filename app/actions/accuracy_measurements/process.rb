module AccuracyMeasurements
  class Process < Action::Base
    attr_accessor :measurement

    def execute
      if measurement.ocring?
        execute_ocr
      elsif measurement.summarizing?
        execute_summarize
      else
        return errors.add(:measurement, "Should be in the state :ocring or :summarizing")
      end

      if !measurement.ready?
        ProcessAccuracyMeasurementJob.perform_later \
          measurement: measurement
      end

      measurement.reload
    end

    def execute_ocr
      line_measurements_with_transcriptions.each(&:save!)
      measurement.ocred!
    end

    def execute_summarize
      lms = AccuracyLineMeasurement.
        joins(accuracy_document_measurement: :accuracy_measurement).
        where(
          accuracy_document_measurements: {
            accuracy_measurements: {
              id: measurement.id
            }
          }
        ).
        uniq.
        each do |line_measurement|
          AccuracyLineMeasurements::Summarize.run!(
            line_measurement: line_measurement
          ).result
        end

      sum_up_confusion_matrices(lms)

      measurement.ready!
    end

    def sum_up_confusion_matrices(lms)
      matrices = lms.map { |lm| [lm.zone_id, lm.confusion_matrix] }.to_h

      doc_matrices = measurement.accuracy_document_measurements.map do |dm|
        bt_matrices = dm.bootstraps.map do |zone_ids|
          lm_matrices = zone_ids.map { |zone_id| matrices[zone_id] }

          ConfusionMatrix.sum(lm_matrices)
        end

        ConfusionMatrix.mean(bt_matrices).tap do |cm|
          dm.update_attributes! confusion_matrix: cm
        end
      end

      measurement.update_attributes! \
        confusion_matrix: ConfusionMatrix.mean(doc_matrices)
    end

    def model_id
      measurement.ocr_model_id
    end

    def zone_ids
      memoized do
        AccuracyLineMeasurement.
          joins(accuracy_document_measurement: :accuracy_measurement).
          where(
            accuracy_document_measurements: {
              accuracy_measurements: {
                id: measurement.id
              }
            }
          ).
          pluck(:zone_id).
          uniq
      end
    end

    def line_measurements_with_transcriptions
      memoized do
        results = OcrModels::TranscribeZones.run!(
          model_id: model_id,
          zone_ids: zone_ids,
          base_path: Rails.root.join('tmp', 'measurements', measurement.id)
        ).result

        AccuracyLineMeasurement.
          joins(accuracy_document_measurement: :accuracy_measurement).
          where(
            accuracy_document_measurements: {
              accuracy_measurements: {
                id: measurement.id
              }
            }
          ).
          uniq.
          map do |line_measurement|
            line_measurement.transcription = \
              results[line_measurement.zone_id][:result]
            line_measurement.processed_image = \
              File.new(results[line_measurement.zone_id][:image_path])
            line_measurement.status = :ocred
            line_measurement
          end
      end
    end
  end
end
