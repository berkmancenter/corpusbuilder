require 'rails_helper'

describe Documents::Create do
  include ActiveJob::TestHelper

  let(:client_app) do
    create :app
  end

  let(:editor) do
    create :editor
  end

  let(:image1) do
    create :image, image_scan: File.new(Rails.root.join("spec", "support", "files", "file_2.png")),
      name: "file_1.png"
  end

  let(:image2) do
    create :image, image_scan: File.new(Rails.root.join("spec", "support", "files", "file_2.png")),
      name: "file_2.png"
  end

  let(:proper_params) do
    {
      images: [ { id: image1.id }, { id: image2.id } ],
      metadata: {
        title: "A good read",
        languages: [ "ara" ]
      },
      app: client_app,
      editor_email: editor.email
    }
  end

  let(:proper_call) do
    Documents::Create.run proper_params
  end

  it "turns valid when given valid parameters" do
    expect(proper_call.errors).to be_empty
  end

  it "Enqueues the ProcessDocument job" do
    proper_call

    assert_enqueued_jobs 1, only: ProcessDocumentJob
  end
end
