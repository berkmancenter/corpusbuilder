module Documents
  class Create < Action::Base
    attr_accessor :images, :metadata

    def execute
      Document.create! title: @metadata[:title],
        author: @metadata[:author],
        authority: @metadata[:authority],
        date: @metadata[:date],
        editor: @metadata[:editor],
        license: @metadata[:license],
        notes: @metadata[:notes],
        publisher: @metadata[:publisher],
        status: Document.statuses[:initial]
    end
  end
end
