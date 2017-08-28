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
      expect_any_instance_of(Pipeline::Nidaba).to receive(:start)

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
      create :nidaba_pipeline, document_id: document.id
      document
    end

    it "Polls the pipeline for changes" do
      expect_any_instance_of(Pipeline::Nidaba).to receive(:poll)

      perform_processing
    end

    context "Pipeline returns info that it is still processing" do
      before(:each) do
        expect_any_instance_of(Pipeline::Nidaba).to receive(:poll).and_return(:processing)
      end

      it "Schedules another run of the same job" do
        assert_reschedule do
          perform_processing
        end
      end
    end

    context "Pipeline returns an error" do
      before(:each) do
        expect_any_instance_of(Pipeline::Nidaba).to receive(:poll).and_return("error")
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
      before(:each) do
        expect_any_instance_of(Pipeline::Nidaba).to receive(:poll).and_return("success")
      end

      it "Puts document in the ready state" do
        perform_processing

        expect(document_processing.reload.status).to eq("ready")
      end

      it "Calls the pipeline's result method" do
        expect_any_instance_of(Pipeline::Nidaba).to receive(:result)

        perform_processing
      end

      it "Creates the document tree with the results" do
        perform_processing

        expect(document_processing.reload.master).to be_present
        expect(document_processing.reload.master.graphemes).to be_present
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
      create :nidaba_pipeline, document_id: document.id
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
      create :nidaba_pipeline, document_id: document.id
      document
    end

    it "Does not schedule another run of the same job" do
      assert_no_reschedule do
        perform_ready
      end
    end
  end

end
