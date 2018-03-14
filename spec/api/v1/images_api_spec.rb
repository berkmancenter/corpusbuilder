require 'rails_helper'
require 'airborne'

describe V1::DocumentsAPI, type: :request do
  include AuthenticationSpecHelper

  let(:headers) do
    {
      "Accept" => "application/vnd.corpus-builder-v1+json",
      "X-App-Id" => client_app.id,
      "X-Token" => client_app.encrypted_secret
    }
  end

  let(:client_app) do
    create :app
  end

  context "POST /api/images" do
    it_behaves_like "application authenticated route"

    let(:no_app_request) do
      post url, params: data_minimal_correct, headers: headers.without('X-App-Id')
    end

    let(:no_token_request) do
      post url, params: data_minimal_correct, headers: headers.without('X-Token')
    end

    let(:invalid_token_request) do
      post url, params: data_minimal_correct, headers: headers.merge('X-Token' => bcrypt('-- invalid --'))
    end

    let(:valid_request) do
      post url, params: data_minimal_correct, headers: headers
    end

    let(:valid_response_body) do
      valid_request

      JSON.parse(response.body)
    end

    let(:url) { "/api/images" }

    let(:data_minimal_correct) do
      {
        name: "file_1.png",
        file: Rack::Test::UploadedFile.new(Rails.root.join("spec", "support", "files", "file_1.png"), "image/png")
      }
    end

    let(:images) do
      Image.all
    end

    it "creates a new image in the database" do
      valid_request

      expect(images.count).to eq(1)
      expect(images.first.name).to eq("file_1.png")
      expect(images.first.image_scan.current_path).to include("file_1.png")
    end

    it "returns the id and name of the image in JSON" do
      expect(valid_response_body.first.keys.sort).to eq(["id", "name"])
      expect(valid_response_body.first["name"]).to eq("file_1.png")
      expect(valid_response_body.first["id"]).to eq(images.first.id)
    end

    it "returns 500 when something goes wrong" do
      allow_any_instance_of(Images::Create).to receive(:execute).and_raise(StandardError, "Error message")

      valid_request

      expect(response.status).to eq(500)
      expect(JSON.parse(response.body)).to eq({ "error" => "Oops! Something went wrong" })
    end
  end
end
