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

  let(:standard_area) do
    Area.new(ulx: 0, uly: 0, lrx: 100, lry: 20)
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
    it_behaves_like "authorization on document checking route"

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
  end

  context "/api/documents/:id/:revision/tree" do
    let(:document) do
      create :document, status: Document.statuses[:ready], app_id: client_app.id
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

    let(:surface_2_line) do
      create :zone, surface_id: surfaces.take(2).last.id, area: Area.new(ulx: 0, uly: 0, lrx: 100, lry: 20)
    end

    let(:surface_2_graphemes) do
      [
        head_revision.graphemes << create(:grapheme, value: 'd', zone_id: surface_2_line.id, area: Area.new(ulx: 80, uly: 0, lrx: 100, lry: 20), certainty: 0.5),
        head_revision.graphemes << create(:grapheme, value: 'l', zone_id: surface_2_line.id, area: Area.new(ulx: 60, uly: 0, lrx: 80, lry: 20), certainty: 0.4),
        head_revision.graphemes << create(:grapheme, value: 'r', zone_id: surface_2_line.id, area: Area.new(ulx: 40, uly: 0, lrx: 60, lry: 20), certainty: 0.3),
        head_revision.graphemes << create(:grapheme, value: 'o', zone_id: surface_2_line.id, area: Area.new(ulx: 20, uly: 0, lrx: 40, lry: 20), certainty: 0.2),
        head_revision.graphemes << create(:grapheme, value: 'w', zone_id: surface_2_line.id, area: Area.new(ulx: 0, uly: 0, lrx: 20, lry: 20), certainty: 0.1)
      ].flatten
    end

    let(:master_graphemes) do
      [
        head_revision.graphemes << create(:grapheme, value: 'o', zone_id: first_line.id, area: Area.new(ulx: 80, uly: 0, lrx: 100, lry: 20), certainty: 0.5),
        head_revision.graphemes << create(:grapheme, value: 'l', zone_id: first_line.id, area: Area.new(ulx: 60, uly: 0, lrx: 80, lry: 20), certainty: 0.4),
        head_revision.graphemes << create(:grapheme, value: 'l', zone_id: first_line.id, area: Area.new(ulx: 40, uly: 0, lrx: 60, lry: 20), certainty: 0.3),
        head_revision.graphemes << create(:grapheme, value: 'e', zone_id: first_line.id, area: Area.new(ulx: 20, uly: 0, lrx: 40, lry: 20), certainty: 0.2),
        head_revision.graphemes << create(:grapheme, value: 'h', zone_id: first_line.id, area: Area.new(ulx: 0, uly: 0, lrx: 20, lry: 20), certainty: 0.1)
      ].flatten
    end

    let(:development_graphemes) do
      [
        second_revision.graphemes << create(:grapheme, value: 'ó', zone_id: first_line.id, area: Area.new(ulx: 80, uly: 0, lrx: 100, lry: 20), certainty: 0.6),
        second_revision.graphemes << create(:grapheme, value: 'ł', zone_id: first_line.id, area: Area.new(ulx: 60, uly: 0, lrx: 80, lry: 20), certainty: 0.7),
        second_revision.graphemes << Grapheme.where("area <@ ?", Area.new(ulx: 0, uly: 0, lrx: 60, lry: 20).to_s)
      ].flatten
    end

    let(:head_revision) do
      create :revision, document_id: document.id
    end

    let(:second_revision) do
      create :revision, document_id: document.id, parent_id: head_revision.id
    end

    let(:master_branch) do
      create :branch, name: 'master', revision_id: head_revision.id, editor_id: editor.id
    end

    let(:development_branch) do
      create :branch, name: 'development', revision_id: second_revision.id, editor_id: editor.id
    end

    let(:editor) do
      create :editor
    end

    context "GET" do
      it_behaves_like "application authenticated route"
      it_behaves_like "revision accepting route"

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

      let(:only_surface_request) do
        master_branch
        development_branch
        surfaces
        graphemes
        surface_2_graphemes

        get url(document.id, 'master'), headers: headers, params: { surface_number: 2 }
      end

      let(:surface_snippet_request) do
        master_branch
        development_branch
        surfaces
        graphemes
        surface_2_graphemes

        _params = {
          surface_number: 2,
          area: {
            ulx: 20,
            uly: 0,
            lrx: 60,
            lry: 20
          }
        }

        get url(document.id, 'master'), headers: headers, params: _params
      end

      let(:area_no_surface_request) do
        master_branch

        _params = {
          area: {
            ulx: 20,
            uly: 0,
            lrx: 60,
            lry: 20
          }
        }

        get url(document.id, 'master'), headers: headers, params: _params
      end

      let(:valid_request_result) do
        valid_request

        JSON.parse(response.body)
      end

      let(:only_surface_request_result) do
        only_surface_request

        JSON.parse(response.body)
      end

      let(:surface_snippet_request_result) do
        surface_snippet_request

        JSON.parse(response.body)
      end


      def url(id, revision = nil)
        revision ||= master_branch.name

        "/api/documents/#{id}/#{revision}/tree"
      end

      let(:bad_branch_request) do
        get url(document.id, 'idontexist'), headers: headers
      end

      let(:bad_revision_request) do
        get url(document.id, document.id), headers: headers
      end

      let(:good_branch_request) do
        get url(document.id, master_branch.name), headers: headers
      end

      let(:good_revision_request) do
        get url(document.id, head_revision.id), headers: headers
      end

      let(:success_status) { 200 }

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
          expect(valid_request_result["surfaces"].first["graphemes"].count).to eq(5)
          expect(valid_request_result["surfaces"].first["graphemes"].first).to have_key("id")
          expect(valid_request_result["surfaces"].first["graphemes"].map { |g| g["value"] }.join).to eq("hello")
          expect(valid_request_result["surfaces"].first["graphemes"].map { |g| g["certainty"] }).to eq(["0.1", "0.2", "0.3", "0.4", "0.5"])
        end

        it "returns surfaces with only number, area and graphemes" do
          expect(valid_request_result["surfaces"].first.keys.sort).to eq(["area", "graphemes", "number"])
        end
      end

      context "when only a surface is given" do
        it "returns only the data for the surface in question" do
          expect(only_surface_request_result["surfaces"].count).to eq(1)
        end

        it "returns only the graphemes attached to a given surface" do
          expect(only_surface_request_result["surfaces"].first["graphemes"].map { |g| g["value"] }.join).to eq("world")
        end
      end

      context "when a surface and an area is given" do
        it "returns only the graphemes attached to a given surface and within a given area" do
          expect(surface_snippet_request_result["surfaces"].first["graphemes"].map { |g| g["value"] }.join).to eq("or")
        end
      end

      context "when an area is given but no surface" do
        it "returns 422 with the proper error message" do
          area_no_surface_request

          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)).to eq({ "error" => "Cannot specify an area without a surface number" })
        end
      end
    end

    context "PUT" do
      it_behaves_like "authorization on document checking route"
      it_behaves_like "revision accepting route"

      let(:wrong_app) do
        create :app
      end

      let(:bad_branch_request) do
        master_branch
        development_branch
        surfaces
        graphemes

        put url(document.id, 'idontexist'),
          headers: headers,
          params: minimal_valid_params
      end

      let(:bad_revision_request) do
        master_branch
        development_branch
        surfaces
        graphemes

        put url(document.id, Grapheme.first.id),
          headers: headers,
          params: minimal_valid_params
      end

      let(:good_branch_request) do
        master_branch
        development_branch
        surfaces
        graphemes

        put url(document.id, master_branch.name),
          headers: headers,
          params: minimal_valid_params
      end

      let(:good_revision_request) do
        master_branch
        development_branch
        surfaces
        graphemes

        put url(document.id, master_branch.revision_id),
          headers: headers,
          params: minimal_valid_params
      end

      let(:success_status) { 200 }

      let(:wrong_app_request) do
        put url(document.id),
          headers: headers.merge('X-App-Id' => wrong_app.id, 'X-Token' => wrong_app.encrypted_secret),
          params: minimal_valid_params
      end

      let(:minimal_valid_params) do
        {
          graphemes: [
            { value: 'u', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 }, surface_number: 1 }
          ]
        }
      end

      def url(id, revision = 'master')
        "/api/documents/#{id}/#{revision}/tree"
      end

      def area_to_params(area)
        {
          ulx: area.ulx,
          uly: area.uly,
          lrx: area.lrx,
          lry: area.lry
        }
      end

      let(:grapheme1) { master_graphemes.first }
      let(:grapheme2) { master_graphemes.drop(1).first }
      let(:grapheme3) { master_graphemes.drop(2).first }

      context "pointing at existing graphemes" do
        let(:given_graphemes) do
          [
            {
              id: grapheme1.id,
              area: area_to_params(grapheme1.area),
              surface_number: 1,
              value: '1'
            },
            {
              id: grapheme2.id,
              area: area_to_params(grapheme2.area),
              surface_number: 1,
              value: '2'
            },
            {
              id: grapheme3.id,
              area: area_to_params(grapheme3.area),
              surface_number: 1,
              value: '3'
            }
          ]
        end

        let(:minimal_valid_params) do
          {
            graphemes: given_graphemes
          }
        end

        let(:valid_request) do
          master_branch
          development_branch
          surfaces
          graphemes

          put url(document.id),
            headers: headers,
            params: minimal_valid_params
        end

        it "creates new graphemes" do
          valid_request

          created_ones = given_graphemes.inject(Grapheme.where(id: '-1')) do |sum, spec|
            sum = sum.or(Grapheme.where(area: Area.new(ulx: spec[:area][:ulx],
                                                       uly: spec[:area][:uly],
                                                       lrx: spec[:area][:lrx],
                                                       lry: spec[:area][:lry]),
                                        value: spec[:value]).
                                  where.not(id: spec[:id]))
            sum
          end

          expect(created_ones.count).to eq(given_graphemes.count)
        end

        it "breakes connection between given graphemes and the revision" do
          valid_request

          expect(master_branch.graphemes.where(id: given_graphemes.map { |g| g[:id] }).count).to eq(0)
        end
      end

      context "removing graphemes" do
        let(:given_graphemes) do
          [
            {
              id: grapheme1.id,
              delete: true
            }
          ]
        end

        let(:minimal_valid_params) do
          {
            graphemes: given_graphemes
          }
        end

        let(:valid_request) do
          master_branch
          development_branch
          surfaces
          graphemes

          put url(document.id),
            headers: headers,
            params: minimal_valid_params
        end

        it "removes given graphemes connections from the revision" do
          valid_request

          expect(master_branch.graphemes.where(id: grapheme1.id)).to be_empty
        end

        it "keeps the graphemes in the database" do
          valid_request

          expect(Grapheme.where(id: grapheme1.id)).to be_present
        end
      end

      context "providing new graphemes" do
        let(:given_graphemes) do
          [
            {
              area: area_to_params(grapheme1.area),
              surface_number: 1,
              value: '1'
            },
            {
              area: area_to_params(grapheme2.area),
              surface_number: 1,
              value: '2'
            },
            {
              area: area_to_params(grapheme3.area),
              surface_number: 1,
              value: '3'
            }
          ]
        end

        let(:minimal_valid_params) do
          {
            graphemes: given_graphemes
          }
        end

        let(:valid_request) do
          master_branch
          development_branch
          surfaces
          graphemes

          put url(document.id),
            headers: headers,
            params: minimal_valid_params
        end

        it "creates new graphemes" do
          valid_request

          created_ones = given_graphemes.inject(Grapheme.where(id: '-1')) do |sum, spec|
            sum = sum.or(Grapheme.where(area: Area.new(ulx: spec[:area][:ulx],
                                                       uly: spec[:area][:uly],
                                                       lrx: spec[:area][:lrx],
                                                       lry: spec[:area][:lry]),
                                        value: spec[:value]))
            sum
          end

          expect(created_ones.count).to eq(given_graphemes.count)
        end

        it "points new graphemes at a given revision only" do
          valid_request

          created_ones = given_graphemes.inject(Grapheme.where(id: '-1')) do |sum, spec|
            sum = sum.or(Grapheme.where(area: Area.new(ulx: spec[:area][:ulx],
                                                       uly: spec[:area][:uly],
                                                       lrx: spec[:area][:lrx],
                                                       lry: spec[:area][:lry]),
                                        value: spec[:value]))
            sum
          end

          expect(created_ones.map { |g| g.revision_ids }.flatten.uniq.count).to eq(1)
        end
      end
    end
  end

  context "GET /api/documents/:id/:revision/diff" do
    it_behaves_like "application authenticated route"
    it_behaves_like "revision accepting route"

    let(:editor) do
      create :editor
    end

    let(:head_revision) do
      master_branch.revision
    end

    let(:surfaces) do
      [
        create(:surface, document_id: document.id, area: standard_area, number: 1, image_id: image1.id)
      ]
    end

    let(:first_line) do
      create :zone, surface_id: surfaces.first.id, area: Area.new(ulx: 0, uly: 0, lrx: 100, lry: 20)
    end

    let(:master_graphemes) do
      [
        head_revision.graphemes << create(:grapheme, value: 'o', zone_id: first_line.id, area: Area.new(ulx: 80, uly: 0, lrx: 100, lry: 20), certainty: 0.5),
        head_revision.graphemes << create(:grapheme, value: 'l', zone_id: first_line.id, area: Area.new(ulx: 60, uly: 0, lrx: 80, lry: 20), certainty: 0.4),
        head_revision.graphemes << create(:grapheme, value: 'l', zone_id: first_line.id, area: Area.new(ulx: 40, uly: 0, lrx: 60, lry: 20), certainty: 0.3),
        head_revision.graphemes << create(:grapheme, value: 'e', zone_id: first_line.id, area: Area.new(ulx: 20, uly: 0, lrx: 40, lry: 20), certainty: 0.2),
        head_revision.graphemes << create(:grapheme, value: 'h', zone_id: first_line.id, area: Area.new(ulx: 0, uly: 0, lrx: 20, lry: 20), certainty: 0.1)
      ].flatten
    end

    let(:grapheme1) { master_graphemes.first }
    let(:grapheme2) { master_graphemes.drop(1).first }
    let(:grapheme3) { master_graphemes.drop(2).first }

    let(:success_status) { 200 }

    let(:master_branch) do
      create :branch, name: 'master',
        revision_id: create(:revision, document_id: document.id ).id,
        editor_id: editor.id
    end

    let(:development_branch) do
      create :branch, name: 'development',
        revision_id: create(:revision, document_id: document.id, parent_id: master_branch.revision_id).id,
        editor_id: editor.id
    end

    let(:document) do
      create :document, status: Document.statuses[:ready], app_id: client_app.id
    end

    let(:no_app_request) do
      get url(document.id), headers: headers.without('X-App-Id')
    end

    let(:no_token_request) do
      get url(document.id), headers: headers.without('X-Token')
    end

    let(:invalid_token_request) do
      get url(document.id), headers: headers.merge('X-Token' => bcrypt('-- invalid --'))
    end

    let(:good_revision_request) do
      get url(document.id, master_branch.revision_id), headers: headers
    end

    let(:good_branch_request) do
      get url(document.id, master_branch.name), headers: headers
    end

    let(:bad_branch_request) do
      get url(document.id, 'idontexist'), headers: headers
    end

    let(:bad_revision_request) do
      get url(document.id, document.id), headers: headers
    end

    let(:additions) do
      [
        { value: 'a', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 }, surface_number: 1 },
        { value: 'b', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 }, surface_number: 1 }
      ]
    end

    let(:changes) do
      [
        { id: grapheme1.id, value: 'a', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 } },
        { id: grapheme2.id, value: 'b', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 } }
      ]
    end

    let(:removals) do
      [
        { id: grapheme3.id, delete: true }
      ]
    end

    def make_changes
      Documents::Correct.run! document: document,
        branch_name: 'development',
        graphemes: (additions + changes + removals)
    end

    let(:valid_request) do
      master_branch
      development_branch
      make_changes

      get url(document.id, 'development'), headers: headers
    end

    let(:valid_response) do
      valid_request

      JSON.parse response.body
    end

    def url(id, revision = 'master')
      "/api/documents/#{id}/#{revision}/diff"
    end

    it "returns all new graphemes with the status of addition" do
      expect(valid_response.select { |g| g["status"] == "right" }.count).to eq(2)
    end

    it "returns old graphemes with the status of deletion" do
      expect(valid_response.select { |g| g["status"] == "left" }.count).to eq(3)
    end
  end

  context "GET /api/documents/:id/branches" do
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
      get url(document.id), headers: headers
    end

    let(:valid_with_data_request) do
      master_branch && development_branch && topic1_branch

      valid_request
    end

    let(:with_data_response) do
      valid_with_data_request

      JSON.parse(response.body)
    end

    let(:editor1) do
      create :editor, email: "editor1@university.com"
    end

    let(:editor2) do
      create :editor, email: "editor2@university.com"
    end

    let(:editor3) do
      create :editor, email: "editor3@university.com"
    end

    let(:master_branch) do
      branch(:master, editor1)
    end

    let(:development_branch) do
      branch(:development, editor2)
    end

    let(:topic1_branch) do
      branch(:topic1, editor3)
    end

    def branch(name, editor)
      create :branch, name: name, editor_id: editor.id, revision_id: create(:revision, document_id: document.id).id
    end

    def url(id)
      "/api/documents/#{id}/branches"
    end

    let(:document) do
      create :document, status: Document.statuses[:ready], app_id: client_app.id
    end

    it "lists all branches with their name, revision_id and editor id who is an owner" do
      expect(with_data_response).to have_key("branches")
      expect(with_data_response["branches"].map { |b| b["name"] }).to eq([master_branch.name, development_branch.name, topic1_branch.name])
      expect(with_data_response["branches"].map { |b| b["editor"]["email"] }).to eq([editor1.email, editor2.email, editor3.email])
      expect(with_data_response["branches"].map { |b| b["editor"]["id"] }).to eq([editor1.id, editor2.id, editor3.id])
      expect(with_data_response["branches"].first["revision_id"]).to be_present
      expect(with_data_response["branches"].map { |b| b["revision_id"] }.sort).to eq(Revision.all.map(&:id).sort)
    end
  end

  context "POST /api/documents/:id/branches" do
    it_behaves_like "application authenticated route"
    it_behaves_like "revision accepting route"
    it_behaves_like "authorization on document checking route"
    it_behaves_like "editor requiring route"

    let(:no_app_request) do
      post url(document.id), headers: headers.without('X-App-Id'), params: minimal_valid_params
    end

    let(:no_token_request) do
      post url(document.id), headers: headers.without('X-Token'), params: minimal_valid_params
    end

    let(:invalid_token_request) do
      post url(document.id), headers: headers.merge('X-Token' => bcrypt('-- invalid --')), params: minimal_valid_params
    end

    let(:valid_request) do
      good_branch_request
    end

    let(:wrong_app) do
      create :app
    end

    let(:wrong_app_request) do
      post url(document.id),
        headers: headers.merge('X-App-Id' => wrong_app.id, 'X-Token' => wrong_app.encrypted_secret),
        params: minimal_valid_params.merge(revision: master_branch.name)
    end

    let(:good_revision_request) do
      post url(document.id),
        headers: headers,
        params: minimal_valid_params.merge(revision: master_branch.revision_id)
    end

    let(:good_branch_request) do
      post url(document.id),
        headers: headers,
        params: minimal_valid_params.merge(revision: master_branch.name)
    end

    let(:bad_branch_request) do
      post url(document.id), headers: headers, params: minimal_valid_params.merge(revision: 'idontexist')
    end

    let(:bad_revision_request) do
      post url(document.id), headers: headers, params: minimal_valid_params.merge(revision: document.id)
    end

    let(:no_editor_request) do
      post url(document.id),
        headers: headers,
        params: minimal_valid_params.merge(revision: master_branch.name).without(:editor_id)
    end

    let(:master_branch) do
      create :branch, name: 'master',
        revision_id: create(:revision, document_id: document.id ).id,
        editor_id: editor.id
    end

    let(:topic_branch) do
      create :branch, name: 'topic',
        revision_id: create(:revision, document_id: document.id ).id,
        editor_id: editor.id
    end

    let(:master_child_branch) do
      Branch.joins(:revision).where(revisions: { parent_id: master_branch.revision_id }).first
    end

    let(:minimal_valid_params) do
      {
        parent_revision: master_branch.name,
        editor_id: another_editor.id,
        name: 'topic'
      }
    end

    let(:success_status) { 201 }

    let(:editor) do
      create :editor
    end

    let(:another_editor) do
      create :editor
    end

    let(:document) do
      create :document,
        status: Document.statuses[:ready],
        app_id: client_app.id
    end

    def url(id)
      "/api/documents/#{id}/branches"
    end

    it "creates a new branch with editor set to a given editor id" do
      valid_request

      expect(master_child_branch.editor_id).to eq(another_editor.id)
    end

    it "refuses to create a duplicated branch name within the document" do
      topic_branch
      valid_request

      expect(response.status).to eq(400)
      expect(Branch.where(name: 'topic').count).to eq(1)
    end
  end

end
