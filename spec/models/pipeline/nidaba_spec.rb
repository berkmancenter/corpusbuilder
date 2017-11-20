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

      let(:send_metadata_url) do
        "#{nidaba_base_url}/api/v1/batch/#{batch_id}/pages?auxiliary=1"
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
        [
          {
            name: file_name,
            url: "/api/v1/pages/#{batch_id}/#{file_name}"
          }
        ]
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
          order: 1,
          image_scan: File.new(Rails.root.join("spec", "support", "files", "file_1.png")),
          document_id: pipeline.document.id
        image.save! validate: false
        image
      end

      let(:image_2) do
        image = FactoryGirl.build :image,
          name: "image_2.png",
          order: 2,
          image_scan: File.new(Rails.root.join("spec", "support", "files", "file_2.png")),
          document_id: pipeline.document.id
        image.save! validate: false
        image
      end

      let(:metadata_file_response_1) do
        file_name = "metadata.yml"
        {
          name: file_name,
          url: "/api/v1/pages/#{batch_id}/metadata.yml"
        }
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
          to_return({ body: image_file_response_1.to_json }, { body: image_file_response_2.to_json })
      end

      let(:send_bad_image_request) do
        stub_request(:post, send_image_url).
          with(headers: { 'Content-Type' => /^multipart\/form-data; boundary=.*/ }).
          to_return(status: 401)
      end

      let(:send_metadata_request) do
        stub_request(:post, send_metadata_url).
          with(headers: { 'Content-Type' => /^multipart\/form-data; boundary=.*/ }).
          to_return(body: metadata_file_response_1.to_json)
      end

      let(:send_bad_metadata_request) do
        stub_request(:post, send_metadata_url).
          with(headers: { 'Content-Type' => /^multipart\/form-data; boundary=.*/ }).
          to_return(status: 401)
      end

      def task_url(type, name)
        "#{nidaba_base_url}/api/v1/batch/#{batch_id}/tasks/#{type}/#{name}"
      end

      let(:create_any_to_png_request) do
        stub_request(:post, task_url("img", "any_to_png")).
          to_return(status: 201)
      end

      let(:create_nlbin_request) do
        stub_request(:post, task_url("binarize", "nlbin")).
          to_return(status: 201)
      end

      let(:create_tesseract_segmentation_request) do
        stub_request(:post, task_url("segmentation", "tesseract")).
          to_return(status: 201)
      end

      let(:create_kraken_ocr_request) do
        stub_request(:post, task_url("ocr", "kraken")).
          to_return(status: 201)
      end

      let(:create_output_metadata_request) do
        stub_request(:post, task_url("output", "metadata")).
          to_return(status: 201)
      end

      before(:each) do
        image_1
        image_2
        create_batch_request
        send_metadata_request
        send_image_request
        create_any_to_png_request
        create_nlbin_request
        create_tesseract_segmentation_request
        create_kraken_ocr_request
        create_output_metadata_request
      end

      it "makes a POST request to <nidaba>/api/v1/batch" do
        pipeline.start

        expect(create_batch_request).to have_been_requested
      end

      it "creates a new batch in the system" do
        pipeline.start

        expect(create_batch_request).to have_been_requested
        expect(pipeline.reload.batch_id).to eq(batch_id)
      end

      it "turns document and pipeline into error state if the batch create is not successful" do
        create_bad_batch_request

        pipeline.start

        expect(pipeline.reload.status).to eq("error")
        expect(pipeline.document.reload.status).to eq("error")
      end

      it "sends images as pages to /api/v1/batch/:batch_id/pages" do
        pipeline.start

        expect(send_image_request).to have_been_requested.twice
      end

      pending "stores images in order in pipeline data attribute" #do
       # pipeline.start

       # expect(pipeline.data["images"].count).to eq(2)
       # expect(pipeline.data["images"][0]["/api/v1/pages/#{batch_id}/file_1.png"]).to eq(image_1.id)
       # expect(pipeline.data["images"][1]["/api/v1/pages/#{batch_id}/file_2.png"]).to eq(image_2.id)
      #end

      # changing the following to **not** sending if that's not needed
      # since we already have all metadata
      it "doesn't send metadata along with the images to /api/v1/batch/:batch_id/pages?auxiliary=1" do
        pipeline.start

        expect(send_metadata_request).not_to have_been_requested.once
      end

      it "turns document and pipeline into error state if the image send is not successful" do
        send_bad_image_request

        pipeline.start

        expect(send_bad_image_request).to have_been_requested.twice
        expect(pipeline.reload.status).to eq("error")
        expect(pipeline.document.reload.status).to eq("error")
      end

      it "turns document and pipeline into the processing state" do
        pipeline.start

        expect(pipeline.reload.status).to eq("processing")
        expect(pipeline.document.reload.status).to eq("processing")
      end

      it "should create proper tasks by calling API" do
        pipeline.start

        expect(create_any_to_png_request).to have_been_requested.once
        expect(create_nlbin_request).to have_been_requested.once
        expect(create_tesseract_segmentation_request).to have_been_requested.once
        expect(create_kraken_ocr_request).to have_been_requested.once
        expect(create_output_metadata_request).not_to have_been_requested.once
      end
    end
  end

  context "The poll method" do
    context "when pipeline is in initial state" do
      let(:document) do
        FactoryGirl.create :document, status: Document.statuses[:initial]
      end

      let(:pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:initial],
          document: document
      end

      it "raises the error" do
        expect { pipeline.poll }.to raise_error(Pipeline::Error)
      end
    end

    context "when pipeline is in error state" do
      let(:document) do
        FactoryGirl.create :document, status: Document.statuses[:error]
      end

      let(:pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:error],
          document: document
      end

      it "raises the error" do
        expect { pipeline.poll }.to raise_error(Pipeline::Error)
      end
    end

    context "when pipeline is in the success state" do
      let(:document) do
        FactoryGirl.create :document, status: Document.statuses[:ready]
      end

      let(:pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:success],
          document: document
      end

      it "raises the error" do
        expect { pipeline.poll }.to raise_error(Pipeline::Error)
      end
    end

    context "when pipeline is in the processing state" do
      let(:document) do
        FactoryGirl.create :document, status: Document.statuses[:processing]
      end

      let(:pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:processing],
          document: document
      end

      let(:batch_id) do
        "abcd123456789"
      end

      let(:get_batch_url) do
        "#{nidaba_base_url}/api/v1/batch/#{batch_id}"
      end

      def batch_response_body(state)
        {
          tasks: "<not-used-url>",
          pages: "<not-used-url>",
          chains: {
            abcd1: {
              task: [ "img", "any_to_png" ],
              state: state
            },
            abcd2: {
              task: [ "binarize", "nlbin" ],
              state: state
            },
            abcd3: {
              task: [ "segmentation", "tesseract" ],
              state: state
            },
            abcd4: {
              task: [ "ocr", "kraken" ],
              state: state,
              result: "page1-url.xml",
              root_documents: [
                "/api/something/image_1.png"
              ]
            },
            abcd5: {
              task: [ "ocr", "kraken" ],
              state: state,
              result: "page2-url.xml",
              root_documents: [
                "/api/something/image_2.png"
              ]
            },
            abcd6: {
              task: [ "output", "metadata" ],
              state: state
            }
          }
        }
      end

      let(:get_pending_batch_request) do
        stub_request(:get, get_batch_url).
          to_return(status: 201, body: batch_response_body("PENDING").to_json)
      end

      before(:each) do
        allow_any_instance_of(Pipeline::Nidaba).to receive(:batch_id).and_return(batch_id)
      end

      it "creates a GET request to the created batch endpoint" do
        get_pending_batch_request

        pipeline.poll

        expect(get_pending_batch_request).to have_been_requested.once
      end

      context "when any task in the batch is reported as failure" do
        let(:get_failure_batch_request) do
          stub_request(:get, get_batch_url).
            to_return(status: 201, body: batch_response_body("FAILURE").to_json)
        end

        it "turns the pipeline and document into the error state" do
          get_failure_batch_request

          pipeline.poll

          expect(pipeline.reload.status).to eq("error")
          expect(pipeline.document.reload.status).to eq("error")
        end
      end

      context "when all tasks in the batch are reported as success" do
        let(:get_success_batch_request) do
          stub_request(:get, get_batch_url).
            to_return(status: 201, body: batch_response_body("SUCCESS").to_json)
        end

        before(:each) do
          get_success_batch_request
        end

        it "turns the pipeline and document into the success state" do
          pipeline.poll

          expect(pipeline.reload.status).to eq("success")
          expect(pipeline.document.reload.status).to eq("ready")
        end

        it "stores all pages results under the json data within the pipeline" do
          pipeline.poll

          expect(pipeline.pages.count).to eq(2)
          expect(pipeline.pages.first).to eq({ "/api/something/image_1.png" => "page1-url.xml" })
          expect(pipeline.pages.last).to eq({ "/api/something/image_2.png" => "page2-url.xml"})
        end
      end
    end
  end

  context "The result method" do
    context "when pipeline is in initial state" do
      let(:document) do
        FactoryGirl.create :document, status: Document.statuses[:initial]
      end

      let(:pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:initial],
          document: document
      end

      it "raises the error" do
        expect { pipeline.result }.to raise_error(Pipeline::Error)
      end
    end

    context "when pipeline is in error state" do
      let(:document) do
        FactoryGirl.create :document, status: Document.statuses[:error]
      end

      let(:pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:error],
          document: document
      end

      it "raises the error" do
        expect { pipeline.result }.to raise_error(Pipeline::Error)
      end
    end

    context "when pipeline is in the processing state" do
      let(:document) do
        FactoryGirl.create :document, status: Document.statuses[:processing]
      end

      let(:pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:processing],
          document: document
      end

      it "raises the error" do
        expect { pipeline.result }.to raise_error(Pipeline::Error)
      end
    end

    context "when pipeline is in the success state" do
      let(:document) do
        FactoryGirl.create :document, status: Document.statuses[:ready]
      end

      let(:pipeline) do
        FactoryGirl.create :nidaba_pipeline,
          status: Pipeline.statuses[:success],
          document: document
      end

      let(:image_1) do
        image = FactoryGirl.build :image,
          name: "image_1.png",
          order: 1,
          image_scan: File.new(Rails.root.join("spec", "support", "files", "file_1.png")),
          document_id: pipeline.document.id
        image.save! validate: false
        image
      end

      let(:image_2) do
        image = FactoryGirl.build :image,
          name: "image_2.png",
          order: 2,
          image_scan: File.new(Rails.root.join("spec", "support", "files", "file_2.png")),
          document_id: pipeline.document.id
        image.save! validate: false
        image
      end

      let(:batch_id) { "abcd1234" }

      let(:page_result_url_1) { "someurl/page1.xml" }
      let(:page_result_url_2) { "someurl/page2.xml" }

      let(:image_1_url) { "/api/v1/pages/#{batch_id}/file_1.png" }
      let(:image_2_url) { "/api/v1/pages/#{batch_id}/file_2.png" }

      before(:each) do
        pages = [
          { image_1_url => page_result_url_1 },
          { image_2_url => page_result_url_2 }
        ]
        images = [
          { image_1_url => image_1.id },
          { image_2_url => image_2.id },
        ]
        allow_any_instance_of(Pipeline::Nidaba).to receive(:batch_id).and_return(batch_id)
        allow_any_instance_of(Pipeline::Nidaba).to receive(:images).and_return(images)
        allow_any_instance_of(Pipeline::Nidaba).to receive(:pages).and_return(pages)
      end

      let(:get_page_tei_1) do
        stub_request(:get, page_result_url_1).
          to_return(status: 201, body: "<TEI>1</TEI>")
      end

      let(:get_page_tei_2) do
        stub_request(:get, page_result_url_2).
          to_return(status: 201, body: "<TEI>2</TEI>")
      end

      it "makes GET requests for the resulting TEI xml data" do
        get_page_tei_1
        get_page_tei_2

        pipeline.result.to_a

        expect(get_page_tei_1).to have_been_requested.once
        expect(get_page_tei_2).to have_been_requested.once
      end

      it "returns a lazy enumerator to streams of tei xml data" do
        get_page_tei_1
        get_page_tei_2

        expect(pipeline.result).to be_an_instance_of(Enumerator::Lazy)
      end

      it "yields proper tei data" do
        get_page_tei_1
        get_page_tei_2

        result = pipeline.result

        expect(result.next).to eq({ image_1.id => "<TEI>1</TEI>" })
        expect(result.next).to eq({ image_2.id => "<TEI>2</TEI>" })
      end

    end
  end
end

