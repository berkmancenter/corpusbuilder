require 'rails_helper'

describe Revisions::QueryClosestRoot do
  RSpec.shared_examples_for "returning closest common root action" do
    it "returns a proper common root" do
      expect(result.id).to eq(correct_root.id)
    end
  end

  let(:result) do
    Revisions::QueryClosestRoot.run!(
      revision1: revision1,
      revision2: revision2
    ).result
  end

  let(:document) do
    create :document
  end

  describe "when given a revision and its ancestor" do
    it_behaves_like "returning closest common root action"

    let(:first_revision) do
      create :revision, document_id: document.id
    end

    let(:revision1) do
      create :revision, document_id: document.id, parent_id: first_revision.id
    end

    let(:revision2) do
      create :revision, document_id: document.id, parent_id: revision1.id
    end

    let(:correct_root) do
      revision1
    end
  end

  describe "when given a revision and itself again" do
    it_behaves_like "returning closest common root action"

    let(:first_revision) do
      create :revision, document_id: document.id
    end

    let(:revision1) do
      create :revision, document_id: document.id, parent_id: first_revision.id
    end

    let(:revision2) do
      revision1
    end

    let(:correct_root) do
      revision1
    end
  end

  describe "when given two revisions only having a common root down the ancestors path" do
    it_behaves_like "returning closest common root action"

    let(:first_revision) do
      create :revision, document_id: document.id
    end

    let(:revision1_parent) do
      create :revision, document_id: document.id, parent_id: correct_root.id
    end

    let(:revision2_parent) do
      create :revision, document_id: document.id, parent_id: correct_root.id
    end

    let(:revision1) do
      create :revision, document_id: document.id, parent_id: revision1_parent.id
    end

    let(:revision2) do
      create :revision, document_id: document.id, parent_id: revision2_parent.id
    end

    let(:correct_root) do
      create :revision, document_id: document.id, parent_id: first_revision.id
    end
  end
end

