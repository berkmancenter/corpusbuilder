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
        FactoryGirl.create :document,
          status: Document.statuses[:initial],
          title: "Initial pipeline document"
      end

      let(:pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:initial],
          document: initial_document
      end

      let(:create_batch_url) do
        "#{nidaba_base_url}/api/v1/batch"
      end

      let(:send_image_url) do
        "#{nidaba_base_url}/api/v1/batch/#{batch_id}/pages"
      end

      let(:batch_id) do
        "a7b4cb6714384599bd064052e78c36f1"
      end

      def image_file(num)
        {
          file: File.new(Rails.root.join("spec", "support", "uploads", "image", "file_#{num}.png"))
        }
      end

      def image_file_response(num)
        file_name = "file_#{num}.png"
        {
          name: file_name,
          url: "/api/v1/pages/#{batch_id}/#{file_name}"
        }
      end

      let(:image_file_1) do
        image_file(1)
      end

      let(:image_file_2) do
        image_file(2)
      end

      let(:image_1) do
        image = FactoryGirl.build :image,
          name: "image_1.png",
          image_scan: File.new(Rails.root.join("spec", "support", "files", "file_1.png")),
          document_id: pipeline.document.id
        image.save! validate: false
        image
      end

      let(:image_2) do
        image = FactoryGirl.build :image,
          name: "image_2.png",
          image_scan: File.new(Rails.root.join("spec", "support", "files", "file_2.png")),
          document_id: pipeline.document.id
        image.save! validate: false
        image
      end

      let(:image_file_response_1) do
        image_file_response(1)
      end

      let(:image_file_response_2) do
        image_file_response(2)
      end

      let(:create_batch_response_body) do
        {
          id: batch_id,
          url: "/api/v1/batch/#{batch_id}"
        }
      end

      let(:create_batch_request) do
        stub_request(:post, create_batch_url).
          to_return(body: create_batch_response_body.to_json, status: 201)
      end

      let(:create_bad_batch_request) do
        stub_request(:post, create_batch_url).
          to_return(status: 401)
      end

      let(:send_image_request) do
        stub_request(:post, send_image_url).
          with(headers: { 'Content-Type' => /^multipart\/form-data; boundary=.*/ }).
          to_return(body: image_file_response_1.to_json)
      end

      let(:send_bad_image_request) do
        stub_request(:post, send_image_url).
          with(headers: { 'Content-Type' => /^multipart\/form-data; boundary=.*/ }).
          to_return(status: 401)
      end

      it "makes a POST request to <nidaba>/api/v1/batch" do
        create_batch_request

        pipeline.start

        expect(create_batch_request).to have_been_requested
      end

      it "creates a new batch in the system" do
        create_batch_request

        pipeline.start

        expect(create_batch_request).to have_been_requested
        expect(pipeline.reload.batch.id).to eq(batch_id)
      end

      it "turns document and pipeline into error state if the batch create is not successful" do
        create_bad_batch_request && send_image_request && image_1 && image_2

        pipeline.start

        expect(pipeline.reload.status).to eq("error")
        expect(pipeline.document.reload.status).to eq("error")
      end

      it "sends images as pages to /api/v1/batch/:batch_id/pages" do
        create_batch_request && send_image_request && image_1 && image_2

        pipeline.start

        expect(send_image_request).to have_been_requested.twice
      end

      it "turns document and pipeline into error state if the image send is not successful" do
        create_batch_request && send_bad_image_request && image_1 && image_2

        pipeline.start

        expect(send_bad_image_request).to have_been_requested.twice
        expect(pipeline.reload.status).to eq("error")
        expect(pipeline.document.reload.status).to eq("error")
      end

      it "turns document and pipeline into the processing state" do
        create_batch_request && send_image_request && image_1 && image_2

        pipeline.start

        expect(pipeline.reload.status).to eq("processing")
        expect(pipeline.document.reload.status).to eq("processing")
      end
    end
  end

  context "The poll method" do

  end

  context "The result method" do

  end
end

