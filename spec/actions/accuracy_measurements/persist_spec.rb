require 'rails_helper'

describe AccuracyMeasurements::Persist do
  let(:documents) do
    create_list :document, 5
  end

  let(:images) do
    documents.map do |doc|
      create_list :image, 4, document_id: doc.id
    end.flatten
  end

  let(:surfaces) do
    images.map do |im|
      create_list :surface, 4, document_id: im.document_id, image_id: im.id
    end.flatten
  end

  let(:zones) do
    surfaces.map do |surf|
      create_list :zone, 4, surface_id: surf.id
    end.flatten
  end

  let(:model) { create :ocr_model }

  let(:measurement) do
    measurement = AccuracyMeasurement.new ocr_model: model,
      bootstrap_sample_size: 2,
      bootstrap_number: 2,
      seed: 1234
    measurement.assigned_document_ids = zones.map(&:surface).flatten.map(&:document_id).flatten.uniq
    measurement
  end

  it "runs successfully when given correct data" do
    expect(
      AccuracyMeasurements::Persist.run!(model: measurement).result
    ).to be_persisted
  end

  it "creates document measurements" do
    expect(
      AccuracyMeasurements::Persist.run!(model: measurement).
        result.
        accuracy_document_measurements.
        uniq.
        count
    ).to eq(documents.count)
  end

  it "creates line measurements" do
    count_lines = AccuracyMeasurements::Persist.run!(model: measurement).
      result.
      accuracy_document_measurements.
      uniq.
      map(&:accuracy_line_measurements).
      flatten.
      uniq.
      count

    expect(count_lines).to be > 0
    expect(count_lines).to be <= zones.count
  end

  it "saves correct numbers of bootstraps for the document measurement" do
    doc_measurements = AccuracyMeasurements::Persist.run!(model: measurement).
      result.
      accuracy_document_measurements

    doc_measurements.each do |doc_measurement|
      expect(doc_measurement.bootstraps.count).to \
        eq(measurement.bootstrap_number)

      doc_measurement.bootstraps.each do |zone_ids|
        expect(zone_ids.count).to eq(measurement.bootstrap_sample_size)
      end
    end
  end
end
