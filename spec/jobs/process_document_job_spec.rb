require 'rails_helper'

RSpec.describe ProcessDocumentJob, type: :job do
  include ActiveJob::TestHelper

  def assert_reschedule(&block)
    assert_enqueued_jobs 1, only: ProcessDocumentJob do
      block.call
    end
  end

  def assert_no_reschedule(&block)
    assert_enqueued_jobs 0, only: ProcessDocumentJob do
      block.call
    end
  end

  before(:each) do
    allow(RestClient).to receive(:post)
    allow_any_instance_of(Pipeline::Local).to receive(:store)
    allow_any_instance_of(Pipeline::Local).to receive(:binarize)
    allow_any_instance_of(Pipeline::Local).to receive(:deskew)
    allow_any_instance_of(Pipeline::Local).to receive(:segment)
    allow_any_instance_of(Pipeline::Local).to receive(:ocr)
    allow_any_instance_of(Pipeline::Local).to receive(:cleanup)
  end

  context "Document is in initial state" do
    let(:perform_initial) do
      ProcessDocumentJob.perform_now(document_initial)
    end

    let(:document_initial) do
      create :document
    end

    let(:pipeline_for_initial) do
      Pipeline.where(document_id: document_initial.id).first
    end

    it "Creates the new pipeline" do
      perform_initial

      expect(pipeline_for_initial).to be_present
    end

    it "Calls the pipeline's start method" do
      expect_any_instance_of(Pipeline::Local).to receive(:start)

      perform_initial
    end

    it "Schedules another run of the same job" do
      assert_reschedule do
        perform_initial
      end
    end

    it "Puts document in the processing state" do
      perform_initial

      expect(document_initial.reload.status).to eq("processing")
    end
  end

  context "Document is in processing state" do
    let(:perform_processing) do
      ProcessDocumentJob.perform_now(document_processing)
    end

    let(:document_processing) do
      document = create :document, status: "processing"
      create :local_pipeline, document_id: document.id, status: Pipeline.statuses["processing"]
      document
    end

    it "Moves the pipeline forward" do
      expect_any_instance_of(Pipeline::Local).to receive(:forward)

      perform_processing
    end

    context "Pipeline returns info that it is still processing" do
      before(:each) do
        expect_any_instance_of(Pipeline::Local).to receive(:forward).and_return(:processing)
      end

      it "Schedules another run of the same job" do
        assert_reschedule do
          perform_processing
        end
      end
    end

    context "Pipeline returns an error" do
      before(:each) do
        expect_any_instance_of(Pipeline::Local).to receive(:forward).and_return("error")
      end

      it "Puts document in the error state" do
        perform_processing

        expect(document_processing.reload.status).to eq("error")
      end

      it "Does not schedule another run of the same job" do
        assert_no_reschedule do
          perform_processing
        end
      end
    end

    context "Pipeline returns success" do
      let(:parsed_result) do
        [
          {
            'abcd1' => [
              Parser::Element.new(name: "surface", area: Area.new(lrx: 100, lry: 10, ulx: 0, uly: 0)),
              Parser::Element.new(name: "zone", area: Area.new(lrx: 60, lry: 10, ulx: 0, uly: 0)),
              Parser::Element.new(name: "grapheme", certainty: 0.1, area: Area.new(lrx: 10, lry: 10, ulx: 0, uly: 0), value: 'h'),
              Parser::Element.new(name: "grapheme", certainty: 0.2, area: Area.new(lrx: 20, lry: 10, ulx: 10, uly: 0), value: 'e'),
              Parser::Element.new(name: "grapheme", certainty: 0.3, area: Area.new(lrx: 30, lry: 10, ulx: 20, uly: 0), value: 'l'),
              Parser::Element.new(name: "grapheme", certainty: 0.4, area: Area.new(lrx: 40, lry: 10, ulx: 30, uly: 0), value: 'l'),
              Parser::Element.new(name: "grapheme", certainty: 0.5, area: Area.new(lrx: 50, lry: 10, ulx: 40, uly: 0), value: 'o'),
              Parser::Element.new(name: "zone", area: Area.new(lrx: 60, lry: 20, ulx: 0, uly: 10)),
              Parser::Element.new(name: "grapheme", certainty: 0.7, area: Area.new(lrx: 20, lry: 20, ulx: 10, uly: 10), value: 'o'),
              Parser::Element.new(name: "grapheme", certainty: 0.6, area: Area.new(lrx: 10, lry: 20, ulx: 0, uly: 10), value: 'w'),
              Parser::Element.new(name: "grapheme", certainty: 0.8, area: Area.new(lrx: 30, lry: 20, ulx: 20, uly: 10), value: 'r'),
              Parser::Element.new(name: "grapheme", certainty: 0.9, area: Area.new(lrx: 40, lry: 20, ulx: 30, uly: 10), value: 'l'),
              Parser::Element.new(name: "grapheme", certainty: 0.99, area: Area.new(lrx: 50, lry: 20, ulx: 40, uly: 10), value: 'd')
            ].lazy
          },
          {
            'abcd2' => [
              Parser::Element.new(name: "surface", area: Area.new(lrx: 100, lry: 10, ulx: 0, uly: 0)),
              Parser::Element.new(name: "zone", area: Area.new(lrx: 60, lry: 10, ulx: 0, uly: 0)),
              Parser::Element.new(name: "grapheme", certainty: 0.1, area: Area.new(lrx: 10, lry: 10, ulx: 0, uly: 0), value: 'h'),
              Parser::Element.new(name: "grapheme", certainty: 0.2, area: Area.new(lrx: 20, lry: 10, ulx: 10, uly: 0), value: 'e'),
              Parser::Element.new(name: "grapheme", certainty: 0.3, area: Area.new(lrx: 30, lry: 10, ulx: 20, uly: 0), value: 'l'),
              Parser::Element.new(name: "grapheme", certainty: 0.4, area: Area.new(lrx: 40, lry: 10, ulx: 30, uly: 0), value: 'l'),
              Parser::Element.new(name: "grapheme", certainty: 0.5, area: Area.new(lrx: 50, lry: 10, ulx: 40, uly: 0), value: 'o'),
              Parser::Element.new(name: "zone", area: Area.new(lrx: 60, lry: 20, ulx: 0, uly: 10)),
              Parser::Element.new(name: "grapheme", certainty: 0.7, area: Area.new(lrx: 20, lry: 20, ulx: 10, uly: 10), value: 'o'),
              Parser::Element.new(name: "grapheme", certainty: 0.6, area: Area.new(lrx: 10, lry: 20, ulx: 0, uly: 10), value: 'w'),
              Parser::Element.new(name: "grapheme", certainty: 0.8, area: Area.new(lrx: 30, lry: 20, ulx: 20, uly: 10), value: 'r'),
              Parser::Element.new(name: "grapheme", certainty: 0.9, area: Area.new(lrx: 40, lry: 20, ulx: 30, uly: 10), value: 'l'),
              Parser::Element.new(name: "grapheme", certainty: 0.99, area: Area.new(lrx: 50, lry: 20, ulx: 40, uly: 10), value: 'd')
            ].lazy
          }
        ].lazy
      end

      before(:each) do
        expect_any_instance_of(Pipeline::Local).to receive(:forward).and_return("success")
        expect_any_instance_of(Pipeline::Local).to receive(:result).and_return(parsed_result)

        expect(Documents::Compile).to receive(:run!).with({ image_ocr_result: anything, image_id: "abcd1", document: document_processing})
        expect(Documents::Compile).to receive(:run!).with({ image_ocr_result: anything, image_id: "abcd2", document: document_processing})
      end

      it "puts document in the ready state" do
        perform_processing

        expect(document_processing.reload.status).to eq("ready")
      end

      it "calls the pipeline's result method" do
        perform_processing
      end

      it "Does not schedule another run of the same job" do
        assert_no_reschedule do
          perform_processing
        end
      end
    end
  end

  context "Document is in error state" do
    let(:perform_error) do
      ProcessDocumentJob.perform_now(document_error)
    end

    let(:document_error) do
      document = create :document, status: "error"
      create :local_pipeline, document_id: document.id
      document
    end

    it "Does not schedule another run of the same job" do
      assert_no_reschedule do
        perform_error
      end
    end

    it "Puts document in the error state" do
      perform_error

      expect(document_error.reload.status).to eq("error")
    end
  end

  context "Document is in ready state" do
    let(:perform_ready) do
      ProcessDocumentJob.perform_now(document_ready)
    end

    let(:document_ready) do
      document = create :document, status: "ready"
      create :local_pipeline, document_id: document.id
      document
    end

    it "Does not schedule another run of the same job" do
      assert_no_reschedule do
        perform_ready
      end
    end
  end

end
