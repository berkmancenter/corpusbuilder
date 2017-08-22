require 'rails_helper'

describe Documents::Create do
  include ActiveJob::TestHelper

  let(:proper_params) do
    {
      images: [ { id: 2 }, { id: 2 } ],
      metadata: {
        title: "A good read"
      }
    }
  end

  let(:proper_call) do
    Documents::Create.run proper_params
  end

  it "Enqueues the ProcessDocument job" do
    proper_call

    assert_enqueued_jobs(1)
  end
end
