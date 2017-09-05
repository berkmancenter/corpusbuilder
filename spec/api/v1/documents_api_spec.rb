require 'rails_helper'
require 'airborne'

describe V1::DocumentsAPI, type: :request do
  let(:headers) do
    {
      "Accept" => "application/vnd.corpus-builder-v1+json",
      "X-App-Id" => client_app.id
    }
  end

  let(:client_app) do
    create :app
  end

  context "POST /api/documents" do
    let(:url) { "/api/documents" }
    let(:data_empty_metadata) do
      {
        images: [ { id: 1 }, { id: 2 } ],
        metadata: { }
      }
    end
    let(:data_minimal_correct) do
      {
        images: [ { id: 1 }, { id: 2 } ],
        metadata: { title: "Fancy Book" }.to_json
      }
    end

    it "Fails when no parameters are specified" do
      post url, headers: headers

      expect(response.status).to eq(400)
    end

    it "Fails when at least title in metadata is not provided" do
      post url, params: data_empty_metadata, headers: headers

      expect(response.status).to eq(400)
    end

    it "Returns success when images and minimal metadata is given" do
      post url, params: data_minimal_correct, headers: headers

      expect(response.status).to eq(201)
    end

    it "Creates a document that is in an initial state" do
      post url, params: data_minimal_correct, headers: headers

      new_id = JSON.parse(response.body)["id"]
      document = Document.find new_id

      expect(document.status).to eq("initial")
    end
  end

  context "GET /api/documents/:id/status" do
    def url(id)
      "/api/documents/#{id}/status"
    end

    def request_response_body(id)
      get url(id), headers: headers
      response.body
    end

    let(:client_app2) do
      create :app
    end

    let(:app2_headers) do
      headers.merge('X-App-Id' => client_app2.id)
    end

    let(:wrong_app_request) do
      get url(initial_document.id), headers: app2_headers
      response
    end

    let(:initial_document) do
      create :document, status: Document.statuses[:initial], app_id: client_app.id
    end

    let(:processing_document) do
      create :document, status: Document.statuses[:processing], app_id: client_app.id
    end

    let(:error_document) do
      create :document, status: Document.statuses[:error], app_id: client_app.id
    end

    let(:ready_document) do
      create :document, status: Document.statuses[:ready], app_id: client_app.id
    end

    let(:initial_document_response) do
      JSON.parse request_response_body(initial_document.id)
    end

    let(:processing_document_response) do
      JSON.parse request_response_body(processing_document.id)
    end

    let(:error_document_response) do
      JSON.parse request_response_body(error_document.id)
    end

    let(:ready_document_response) do
      JSON.parse request_response_body(ready_document.id)
    end

    it "returns whatever status the document is in" do
      expect(initial_document_response).to eq({ "status" => "initial" })
      expect(processing_document_response).to eq({ "status" => "processing" })
      expect(error_document_response).to eq({ "status" => "error" })
      expect(ready_document_response).to eq({ "status" => "ready" })
    end

    it "returns 403 forbidden when the current app isn't owning the document" do
      expect(wrong_app_request.status).to eq(403)
    end
  end
end
