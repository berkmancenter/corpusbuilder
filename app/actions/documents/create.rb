module Documents
  class Create < Action::Base
    attr_accessor :images, :metadata, :app

    def validate
      if @app.nil?
        fail "Can't create document without pointing at an app that should own it"
      end
    end

    def execute
      document = Document.create! title: @metadata[:title],
        author: @metadata[:author],
        authority: @metadata[:authority],
        date: @metadata[:date],
        editor: @metadata[:editor],
        license: @metadata[:license],
        notes: @metadata[:notes],
        publisher: @metadata[:publisher],
        status: Document.statuses[:initial],
        app_id: @app.id

      ProcessDocumentJob.
        set(wait: 5.seconds).
        perform_later(document)

      document
    end
  end
end
