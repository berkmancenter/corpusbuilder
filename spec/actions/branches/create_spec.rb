require 'rails_helper'

describe Branches::Create do
  let(:document) do
    create :document
  end

  let(:editor) do
    create :editor
  end

  let(:creation) do
    Branches::Create.run! document_id: document.id,
      editor_id: editor.id,
      name: 'master'
  end

  let(:branch) do
    Branch.first
  end

  it "creates the working revision too" do
    creation

    expect(Revision.where(parent_id: branch.revision_id)).to be_present
  end
end
