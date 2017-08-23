require 'rails_helper'

RSpec.describe ProcessDocumentJob, type: :job do
  include ActiveJob::TestHelper

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

    it "Schedules another run of the same job" do
      assert_enqueued_jobs 1, only: ProcessDocumentJob do
        perform_initial
      end
    end

    it "Puts document in the processing state" do
      perform_initial

      expect(document_initial.reload.status).to eq("processing")
    end
  end

  context "Document is in processing state" do
    it "Polls the pipeline for changes"
    it "Schedules another run of the same job"

    context "Pipeline returns info that it is still processing" do
      it "Schedules another run of the same job"
    end

    context "Pipeline returns an error" do
      it "Puts document in the processing state"
      it "Does not schedule another run of the same job"
    end

    context "Pipeline returns success" do
      it "Puts document in the ready state"
      it "Creates the document tree with the results"
      it "Creates the main revision"
      it "Does not schedule another run of the same job"
    end
  end

  context "Document is in error state" do
    it "Does not schedule another run of the same job"
  end

  context "Document is in ready state" do
    it "Does not schedule another run of the same job"
  end

end
