require 'rails_helper'
require 'airborne'

describe V1::DocumentsAPI, type: :request do
  context "POST /api/documents" do
    let(:headers) do
      {
        "Accept" => "application/vnd.corpus-builder-v1+json"
      }
    end
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
end
