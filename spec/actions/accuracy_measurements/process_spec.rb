require 'rails_helper'

describe AccuracyMeasurements::Process do
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
    measurement = AccuracyMeasurement.new \
      ocr_model: model,
      bootstrap_sample_size: 2,
      bootstrap_number: 2,
      seed: 1234

    measurement.assigned_document_ids = zones.map(&:surface).flatten.map(&:document_id).flatten.uniq

    measurement = AccuracyMeasurements::Persist.run!(
      model: measurement
    ).result

    measurement.scheduled!

    measurement
  end

  let(:line_measurements) do
    measurement.
      accuracy_document_measurements.
      map(&:accuracy_line_measurements).
      flatten
  end

  describe "ocring" do
    let(:line_measurements_transcriptions) do
      line_measurements.
        map { |lm| [lm.zone_id, lm.zone_id] }.
        to_h
    end

    before(:each) do
      allow(OcrModels::TranscribeZones).to \
        receive(:run!).
        and_return(line_measurements_transcriptions)

      expect_any_instance_of(AccuracyMeasurements::Process).to \
        receive(:execute_ocr).
        and_call_original
    end

    it "works" do
      expect {
        AccuracyMeasurements::Process.run! \
          measurement: measurement
      }.not_to raise_error

      line_measurements.each do |lm|
        lm.reload

        expect(lm).to be_ocred
        expect(lm.transcription).to eq(lm.zone_id)
      end

      expect(measurement.reload).to \
        be_ocred
    end
  end

  describe "summarizing" do
    before(:each) do
      AccuracyLineMeasurement.where({}).update_all transcription: "abcd"

      expect_any_instance_of(AccuracyMeasurements::Process).to \
        receive(:execute_summarize).
        and_call_original

      allow_any_instance_of(Documents::Export::ExportLineBoxesKraken).to \
        receive(:text).
        and_return("abud")

      measurement.ocred!
    end

    it "works" do
      expect {
        AccuracyMeasurements::Process.run! \
          measurement: measurement
      }.not_to raise_error

      line_measurements.each do |lm|
        lm.reload

        expect(lm).to be_ready
        expect(lm.confusion_matrix).not_to be_empty
      end

      expect(measurement.reload).to \
        be_ready
    end
  end
end
