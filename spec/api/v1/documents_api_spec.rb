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

  context "POST /api/documents" do
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

    let(:url) { "/api/documents" }

    let(:head_revision) do
      create :revision, document_id: document.id
    end

    let(:master_branch) do
      create :branch, revision_id: head_revision.id
    end

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
    it_behaves_like "application authenticated route"

    let(:no_app_request) do
      get url(initial_document.id), headers: headers.without('X-App-Id')
    end

    let(:no_token_request) do
      get url(initial_document.id), headers: headers.without('X-Token')
    end

    let(:invalid_token_request) do
      get url(initial_document.id), headers: headers.merge('X-Token' => bcrypt('-- invalid --'))
    end

    let(:valid_request) do
      get url(initial_document.id), headers: headers
    end

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
      headers.merge('X-App-Id' => client_app2.id, 'X-Token' => client_app2.encrypted_secret)
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

  context "GET /api/documents/:id/:revision/tree" do
    it_behaves_like "application authenticated route"

    let(:no_app_request) do
      get url(document.id), headers: headers.without('X-App-Id')
    end

    let(:no_token_request) do
      get url(document.id), headers: headers.without('X-Token')
    end

    let(:invalid_token_request) do
      get url(document.id), headers: headers.merge('X-Token' => bcrypt('-- invalid --'))
    end

    let(:valid_request) do
      master_branch
      development_branch
      surfaces
      graphemes

      get url(document.id), headers: headers
    end

    let(:valid_request_result) do
      valid_request

      JSON.parse(response.body)
    end

    let(:document) do
      create :document, status: Document.statuses[:ready], app_id: client_app.id
    end

    let(:standard_area) do
      Area.new(ulx: 0, uly: 0, lrx: 100, lry: 20)
    end

    let(:image1) do
      create :image, image_scan: File.new(Rails.root.join("spec", "support", "files", "file_2.png")),
        name: "file_1.png",
        order: 1
    end

    let(:image2) do
      create :image, image_scan: File.new(Rails.root.join("spec", "support", "files", "file_2.png")),
        name: "file_2.png",
        order: 2
    end

    let(:image3) do
      create :image, image_scan: File.new(Rails.root.join("spec", "support", "files", "file_2.png")),
        name: "file_3.png",
        order: 3
    end

    let(:surfaces) do
      [
        create(:surface, document_id: document.id, area: standard_area, number: 1, image_id: image1.id),
        create(:surface, document_id: document.id, area: standard_area, number: 2, image_id: image2.id),
        create(:surface, document_id: document.id, area: standard_area, number: 3, image_id: image3.id)
      ]
    end

    let(:graphemes) do
      master_graphemes + development_graphemes
    end

    let(:first_line) do
      create :zone, surface_id: surfaces.first.id, area: Area.new(ulx: 0, uly: 0, lrx: 100, lry: 20)
    end

    let(:master_graphemes) do
      [
        head_revision.graphemes << create(:grapheme, value: 'o', zone_id: first_line.id, area: Area.new(ulx: 80, uly: 0, lrx: 100, lry: 20)),
        head_revision.graphemes << create(:grapheme, value: 'l', zone_id: first_line.id, area: Area.new(ulx: 60, uly: 0, lrx: 80, lry: 20)),
        head_revision.graphemes << create(:grapheme, value: 'l', zone_id: first_line.id, area: Area.new(ulx: 40, uly: 0, lrx: 60, lry: 20)),
        head_revision.graphemes << create(:grapheme, value: 'e', zone_id: first_line.id, area: Area.new(ulx: 20, uly: 0, lrx: 40, lry: 20)),
        head_revision.graphemes << create(:grapheme, value: 'h', zone_id: first_line.id, area: Area.new(ulx: 0, uly: 0, lrx: 20, lry: 20))
      ]
    end

    let(:development_graphemes) do
      [
        second_revision.graphemes << create(:grapheme, value: 'ó', zone_id: first_line.id, area: Area.new(ulx: 80, uly: 0, lrx: 100, lry: 20)),
        second_revision.graphemes << create(:grapheme, value: 'ł', zone_id: first_line.id, area: Area.new(ulx: 60, uly: 0, lrx: 80, lry: 20)),
        second_revision.graphemes << Grapheme.where("area <@ ?", Area.new(ulx: 0, uly: 0, lrx: 60, lry: 20).to_s)
      ]
    end

    let(:head_revision) do
      create :revision, document_id: document.id
    end

    let(:second_revision) do
      create :revision, document_id: document.id, parent_id: head_revision.id
    end

    let(:master_branch) do
      create :branch, name: 'master', revision_id: head_revision.id
    end

    let(:development_branch) do
      create :branch, name: 'development', revision_id: second_revision.id
    end

    def url(id, revision = nil)
      revision ||= master_branch.name

      "/api/documents/#{id}/#{revision}/tree"
    end

    context "when revision doesn't exist" do
      let(:bad_branch_request) do
        get url(document.id, 'idontexist'), headers: headers
      end

      let(:bad_revision_request) do
        get url(document.id, document.id), headers: headers
      end

      it "returns status 422 with proper message when given bad branch name" do
        bad_branch_request

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Branch doesn\'t exist' })
      end

      it "returns status 422 with proper message when given bad revision id" do
        bad_revision_request

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Revision doesn\'t exist' })
      end
    end

    context "when given existing branch name" do
      let(:good_branch_request) do
        get url(document.id, master_branch.name), headers: headers
      end

      it "responds with HTTP 200" do
        good_branch_request

        expect(response.status).to eq(200)
      end
    end

    context "when given existing revision id" do
      let(:good_revision_request) do
        get url(document.id, head_revision.id), headers: headers
      end

      it "responds with HTTP 200" do
        good_revision_request

        expect(response.status).to eq(200)
      end
    end

    context "when no surface or area is given" do
      it "contains the id of the document" do
        expect(valid_request_result).to have_key("id")
        expect(valid_request_result["id"]).to eq(document.id)
      end

      it "returns all surfaces" do
        expect(valid_request_result).to have_key("surfaces")
        expect(valid_request_result["surfaces"].count).to eq(surfaces.count)
      end

      it "returns proper surfaces with their numbers" do
        expect(valid_request_result["surfaces"].map { |s| s["number"] }).to eq(surfaces.map(&:number))
      end

      it "returns proper surfaces with their areas" do
        expect(valid_request_result["surfaces"].first).to have_key("area")
        expect(valid_request_result["surfaces"].first["area"]).to have_key("ulx")
        expect(valid_request_result["surfaces"].first["area"]).to have_key("uly")
        expect(valid_request_result["surfaces"].first["area"]).to have_key("lrx")
        expect(valid_request_result["surfaces"].first["area"]).to have_key("lry")
        expect(valid_request_result["surfaces"].first["area"]["ulx"]).to eq(0)
        expect(valid_request_result["surfaces"].first["area"]["uly"]).to eq(0)
        expect(valid_request_result["surfaces"].first["area"]["lrx"]).to eq(100)
        expect(valid_request_result["surfaces"].first["area"]["lry"]).to eq(20)
      end

      it "returns proper surfaces with their graphemes" do
        expect(valid_request_result["surfaces"].first).to have_key("graphemes")
        expect(valid_request_result["surfaces"].first["graphemes"].map { |g| g["value"] }.join).to eq("hello")
      end

      it "returns surfaces with only number, area and graphemes" do
        expect(valid_request_result["surfaces"].first.keys.sort).to eq(["area", "graphemes", "number"])
      end
    end
  end
end
