module AccuracyMeasurements
  class Persist < Action::Base
    attr_accessor :model

    def execute
      model.save!

      model.assigned_document_ids.each do |document_id|
        create_document_measurement! \
          document_id: document_id
      end

      model.sampled!
      model.reload
    end

    def create_document_measurement!(document_id:)
      AccuracyDocumentMeasurement.create!(
        document_id: document_id,
        accuracy_measurement: model
      ).tap do |document_measurement|
        create_line_measurements! \
          accuracy_document_measurement: document_measurement
      end
    end

    def create_line_measurements!(accuracy_document_measurement:)
      bootstraps = generate_bootstraps(
        document: accuracy_document_measurement.document
      )

      line_measurements = bootstraps.flatten.uniq.map do |zone_id|
        measurement = AccuracyLineMeasurement.create! \
          accuracy_document_measurement: accuracy_document_measurement,
          zone_id: zone_id
        [ zone_id, measurement ]
      end.to_h

      accuracy_document_measurement.update_attributes! \
        bootstraps: bootstraps
    end

    def generate_bootstraps(document:)
      all_zone_ids = Zone.joins(:surface).
        where(surfaces: { document_id: document.id }).
        select('zones.id').
        pluck(:id).
        uniq

      zone_count = all_zone_ids.count

      rnd = Random.new(model.seed)

      (1..model.bootstrap_number).to_a.map do |_|
        (1..model.bootstrap_sample_size).to_a.map do |_|
          all_zone_ids[ rnd.rand(zone_count) ]
        end
      end
    end
  end
end
