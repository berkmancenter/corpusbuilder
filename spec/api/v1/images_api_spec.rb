require 'rails_helper'
require 'airborne'

describe V1::DocumentsAPI, type: :request do
  include AuthenticationSpecHelper

  let(:editor) { create :editor }

  let(:headers) do
    {
      "Accept" => "application/vnd.corpus-builder-v1+json",
      "X-App-Id" => client_app.id,
      "X-Token" => client_app.encrypted_secret,
      "X-Editor-Id" => editor.id
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
      perform_enqueued_jobs do
        valid_request
      end

      expect(images.count).to eq(1)
      expect(images.first.name).to eq("file_1.png")
      expect(images.first.image_scan.current_path).to include("file_1.png")
    end
  end
end
