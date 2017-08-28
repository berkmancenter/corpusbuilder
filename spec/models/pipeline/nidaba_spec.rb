require 'rails_helper'

RSpec.describe Pipeline::Nidaba, type: :model do
  let(:nidaba_base_url) do
    "my.nidaba.org"
  end

  before(:each) do
    Pipeline::Nidaba.config.base_url = nidaba_base_url
    allow(Pipeline::Nidaba).to receive(:base_url).and_return(nidaba_base_url)
  end

  context "The start method" do
    context "when pipeline was already started" do
      let(:started_document) do
        FactoryGirl.create :document, status: Document.statuses[:processing]
      end

      let(:started_pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:processing],
          document: started_document
      end

      it "raises the error" do
        expect { started_pipeline.start }.to raise_error(Pipeline::Error)
      end
    end

    context "when pipeline ended with error" do
      let(:error_pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:error],
          document: error_document
      end

      let(:error_document) do
        FactoryGirl.create :document, status: Document.statuses[:error]
      end

      it "raises the error" do
        expect { error_pipeline.start }.to raise_error(Pipeline::Error)
      end
    end

    context "when pipeline ended with success" do
      let(:success_pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:success],
          document: success_document
      end

      let(:success_document) do
        FactoryGirl.create :document, status: Document.statuses[:ready]
      end

      it "raises the error" do
        expect { success_pipeline.start }.to raise_error(Pipeline::Error)
      end
    end

    context "when pipeline wasn't started yet" do
      let(:initial_document) do
        FactoryGirl.create :document, status: Document.statuses[:initial]
      end

      let(:pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:initial],
          document: initial_document
      end

      let(:create_batch_url) do
        "#{nidaba_base_url}/api/v1/batch"
      end

      let(:batch_id) do
        "a7b4cb6714384599bd064052e78c36f1"
      end

      let(:create_batch_response) do
        instance_double "RestClient::Response",
          code: 201,
          body: create_batch_response_body.to_json
      end

      let(:create_batch_response_body) do
        {
          id: batch_id,
          url: "/api/v1/batch/#{batch_id}"
        }
      end

      it "makes a POST request to <nidaba>/api/v1/batch" do
        expect(RestClient).to receive(:post).with(create_batch_url, {}).and_return(create_batch_response)

        pipeline.start
      end
    end
  end

  context "The poll method" do

  end

  context "The result method" do

  end
end

