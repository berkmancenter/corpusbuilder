require 'rails_helper'

describe Graphemes::QueryMerge do
  RSpec.shared_examples_for "a proper merge result" do

    it "returns all unchanged on both sides as they were" do
      result_ids = result.map(&:id)

      unchanged.each do |grapheme|
        expect(result_ids).to include(grapheme.id)
      end
    end

    it "returns changed from the left side where right did not change them" do
      result_ids = result.map(&:id)

      changed_left_clean.each do |grapheme|
        expect(result_ids).to include(grapheme.id)
      end
    end

    it "returns changed from the right side where left did not change them" do
      result_ids = result.map(&:id)

      changed_right_clean.each do |grapheme|
        expect(result_ids).to include(grapheme.id)
      end
    end

    it "does not return if left removes and right doesn't change" do
      result_ids = result.map(&:id)

      removed_left_clean.each do |grapheme|
        expect(result_ids).not_to include(grapheme.id)
      end
    end

    it "does not return if right removes and left doesn't change"
    it "returns conflict items for changed on left and right sides"
    it "returns conflict items for changed on left and removed on right"
    it "returns conflict items for removed on left and changed on right"
  end

  let(:result) do
    Graphemes::QueryMerge.run!(
      branch_left: branch_left,
      branch_right: branch_right
    ).result
  end

  let(:client_app) do
    create :app
  end

  let(:editor) do
    create :editor
  end

  let(:document) do
    create :document, status: Document.statuses[:ready], app_id: client_app.id
  end

  let(:master_branch) do
    Branches::Create.run!(
      document_id: document.id,
      name: 'master',
      editor_id: editor.id
    ).result
  end

  let(:development_branch) do
    Branches::Create.run!(
      document_id: document.id,
      name: 'development',
      parent_revision_id: master_branch.revision_id,
      editor_id: editor.id
    ).result
  end

  let(:topic_branch) do
    Branches::Create.run!(
      document_id: document.id,
      name: 'topic',
      parent_revision_id: development_branch.revision_id,
      editor_id: editor.id
    ).result
  end

  let(:surface) do
    create(
      :surface,
      document_id: document.id,
      area: Area.new(ulx: 0, uly: 0, lrx: 100, lry: 20),
      number: 1,
      image_id: image1.id
    )
  end

  let(:image1) do
    create :image, image_scan: File.new(Rails.root.join("spec", "support", "files", "file_2.png")),
      name: "file_1.png",
      order: 1
  end

  let(:first_line) do
    create :zone, surface_id: surface.id, area: Area.new(ulx: 0, uly: 0, lrx: 100, lry: 20)
  end

  let(:graphemes) do
    [
      create(
        :grapheme,
        value: '!',
        zone_id: first_line.id,
        area: Area.new(ulx: 120, uly: 0, lrx: 140, lry: 20),
        certainty: 0.5
      ),
      create(
        :grapheme,
        value: '!',
        zone_id: first_line.id,
        area: Area.new(ulx: 100, uly: 0, lrx: 120, lry: 20),
        certainty: 0.5
      ),
      create(
        :grapheme,
        value: 'o',
        zone_id: first_line.id,
        area: Area.new(ulx: 80, uly: 0, lrx: 100, lry: 20),
        certainty: 0.5
      ),
      create(
        :grapheme,
        value: 'l',
        zone_id: first_line.id,
        area: Area.new(ulx: 60, uly: 0, lrx: 80, lry: 20),
        certainty: 0.5
      ),
      create(
        :grapheme,
        value: 'l',
        zone_id: first_line.id,
        area: Area.new(ulx: 40, uly: 0, lrx: 60, lry: 20),
        certainty: 0.5
      ),
      create(
        :grapheme,
        value: 'e',
        zone_id: first_line.id,
        area: Area.new(ulx: 20, uly: 0, lrx: 40, lry: 20),
        certainty: 0.5
      ),
      create(
        :grapheme,
        value: 'h',
        zone_id: first_line.id,
        area: Area.new(ulx: 10, uly: 0, lrx: 20, lry: 20),
        certainty: 0.5
      )
    ].flatten
  end

  let(:grapheme1) { graphemes.first }
  let(:grapheme2) { graphemes.drop(1).first }
  let(:grapheme3) { graphemes.drop(2).first }
  let(:grapheme4) { graphemes.drop(3).first }
  let(:grapheme5) { graphemes.drop(4).first }
  let(:grapheme6) { graphemes.drop(5).first }
  let(:grapheme7) { graphemes.drop(6).first }

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

  describe "when merging a branch directly inherited" do
    let(:branch_left) { master_branch }
    let(:branch_right) { development_branch }
    let(:changed_left_clean) { [] }
    let(:changed_right_clean) { Grapheme.where(value: ['1', '2']) }
    let(:removed_left_clean) { [] }
    let(:unchanged) { [ grapheme4, grapheme5, grapheme6, grapheme7 ] }

    it_behaves_like "a proper merge result" do
      before(:each) do
        master_branch.revision.graphemes << graphemes
        master_branch.working.graphemes << graphemes

        Documents::Correct.run! document: document,
          branch_name: development_branch.name,
          graphemes: [
            { value: 'a', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 }, surface_number: 1 },
            { value: 'b', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 }, surface_number: 1 },
            { id: grapheme1.id, value: '1', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 } },
            { id: grapheme2.id, value: '2', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 } },
            { id: grapheme3.id, delete: true }
          ]

        Branches::Commit.run! branch: development_branch
      end
    end
  end

  describe "when merging a branch inherited in a direct chain" do
    let(:branch_left) { master_branch }
    let(:branch_right) { topic_branch }
    let(:changed_left_clean) { [] }
    let(:changed_right_clean) { Grapheme.where(value: ['1', '2']) }
    let(:removed_left_clean) { [] }
    let(:unchanged) { [ grapheme4, grapheme5, grapheme6, grapheme7 ] }

    it_behaves_like "a proper merge result" do
      before(:each) do
        master_branch.revision.graphemes << graphemes
        master_branch.working.graphemes << graphemes

        Documents::Correct.run! document: document,
          branch_name: development_branch.name,
          graphemes: [
            { value: 'a', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 }, surface_number: 1 },
            { value: 'b', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 }, surface_number: 1 },
            { id: grapheme3.id, delete: true }
          ]

        Branches::Commit.run! branch: development_branch

        Documents::Correct.run! document: document,
          branch_name: topic_branch.name,
          graphemes: [
            { id: grapheme1.id, value: '1', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 } },
            { id: grapheme2.id, value: '2', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 } }
          ]

        Branches::Commit.run! branch: topic_branch
      end
    end
  end

  describe "when merging a branch with other only having a common ancestor" do
    let(:branch_left) { development_branch }
    let(:branch_right) { topic_branch }
    let(:changed_left_clean) { Grapheme.where(value: '1') }
    let(:changed_right_clean) { Grapheme.where(value: ['1', '2']) }
    let(:removed_left_clean) { [ grapheme6 ] }
    let(:unchanged) { [ grapheme5, grapheme7 ] }

    it_behaves_like "a proper merge result" do
      before(:each) do
        master_branch.revision.graphemes << graphemes
        master_branch.working.graphemes << graphemes

        Documents::Correct.run! document: document,
          branch_name: development_branch.name,
          graphemes: [
            { value: 'a', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 }, surface_number: 1 },
            { value: 'b', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 }, surface_number: 1 },
            { id: grapheme4.id, value: '1', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 } },
            { id: grapheme6.id, delete: true }
          ]

        Branches::Commit.run! branch: development_branch

        Documents::Correct.run! document: document,
          branch_name: topic_branch.name,
          graphemes: [
            { id: grapheme1.id, value: '1', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 } },
            { id: grapheme2.id, value: '2', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 } }
          ]

        Branches::Commit.run! branch: topic_branch

        Documents::Correct.run! document: document,
          branch_name: development_branch.name,
          graphemes: [
            { id: grapheme3.id, delete: true }
          ]

        Branches::Commit.run! branch: development_branch
      end
    end
  end

  describe "when merging a branch with other only having a common ancestor with conflicts" do
    let(:branch_left) { development_branch }
    let(:branch_right) { topic_branch }
    let(:changed_left_clean) { Grapheme.where(value: ['6']).to_a }
    let(:changed_right_clean) { Grapheme.where(value: ['6']) }
    let(:removed_left_clean) { [ grapheme4 ] }
    let(:unchanged) { [ grapheme7 ] }

    it_behaves_like "a proper merge result" do
      before(:each) do
        master_branch.revision.graphemes << graphemes
        master_branch.working.graphemes << graphemes
        development_branch.revision.graphemes << graphemes
        development_branch.working.graphemes << graphemes
        topic_branch.revision.graphemes << graphemes
        topic_branch.working.graphemes << graphemes

        Documents::Correct.run! document: document,
          branch_name: topic_branch.name,
          graphemes: [
            { id: grapheme1.id, value: 'a', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 } },
            { id: grapheme2.id, value: 'b', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 } },
            { id: grapheme6.id, value: '6', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 } },
            { id: grapheme3.id, delete: true },
            { value: '1', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 }, surface_number: 1 },
            { value: '2', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 }, surface_number: 1 }
          ]

        Branches::Commit.run! branch: topic_branch

        Documents::Correct.run! document: document,
          branch_name: development_branch.name,
          graphemes: [
            { id: grapheme1.id, value: '3', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 } },
          ]

        Branches::Commit.run! branch: development_branch

        Documents::Correct.run! document: document,
          branch_name: development_branch.name,
          graphemes: [
            { id: grapheme1.id, value: 'u', area: { ulx: 10, uly: 0, lrx: 20, lry: 10 } },
            { id: grapheme2.id, delete: true },
            { id: grapheme4.id, delete: true },
            { id: grapheme3.id, value: 'w', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 } },
            { id: grapheme5.id, value: '5', area: { ulx: 0, uly: 0, lrx: 10, lry: 10 } }
          ]

        Branches::Commit.run! branch: development_branch
      end

    # it "y" do
    #   byebug
    # end
    end
  end
end
