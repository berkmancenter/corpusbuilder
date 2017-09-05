require 'rails_helper'

describe Documents::Create do
  include ActiveJob::TestHelper

  let(:client_app) do
    create :app
  end

  let(:proper_params) do
    {
      images: [ { id: 2 }, { id: 2 } ],
      metadata: {
        title: "A good read"
      },
      app: client_app
    }
  end

  let(:proper_call) do
    Documents::Create.run proper_params
  end

  it "turns valid when given valid parameters" do
    expect(proper_call).to be_valid
  end

  it "Enqueues the ProcessDocument job" do
    proper_call

    assert_enqueued_jobs 1, only: ProcessDocumentJob
  end
end
