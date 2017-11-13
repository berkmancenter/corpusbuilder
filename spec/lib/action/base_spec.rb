require 'rails_helper'

describe Action::Base do

  class TestAction < Action::Base
    attr_accessor :app, :should_throw

    def execute
      Document.create! title: "Test", app_id: app.id, status: Document.statuses[:initial]
      raise StandardError, "Testy error" if should_throw
    end
  end

  let(:app) { create :app }

  it "rolls back any database changes when an error occurs" do
    TestAction.run app: app, should_throw: true

    expect(Document.count).to eq(0)
  end

  it "commits all changes to the database in case no uncaught errors were thrown" do
    TestAction.run app: app, should_throw: false

    expect(Document.count).to eq(1)
  end
end
