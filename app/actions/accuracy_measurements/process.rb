module AccuracyMeasurements
  class Process < Action::Base
    attr_accessor :measurement

    def execute
      if measurement.scheduled?
        execute_ocr
      elsif measurement.ocred?
        execute_summarize
      else
        return errors.add(:measurement, "Should be in the state :scheduled or :ocred")
      end

      if !measurement.ready?
        ProcessAccuracyMeasurementJob.perform_later \
          measurement: measurement
      end

      measurement.reload
    end

    def execute_ocr
      AccuracyLineMeasurement.import \
        line_measurements_with_transcriptions,
        on_duplicate_key_update: {
          conflict_target: [:id],
          columns: [:transcription, :status]
        }
      measurement.ocred!
    end

    def execute_summarize
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
        each do |line_measurement|
          AccuracyLineMeasurements::Summarize.run! \
            line_measurement: line_measurement
        end

      measurement.ready!
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
        results = OcrModels::TranscribeZones.run! \
          model_id: model_id,
          zone_ids: zone_ids,
          base_path: Rails.root.join('tmp', 'measurements', measurement.id)

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
              results[line_measurement.zone_id]
            line_measurement.status = :ocred
            line_measurement
          end
      end
    end
  end
end
