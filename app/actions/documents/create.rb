module Documents
  class Create < Action::Base
    attr_accessor :images, :metadata, :app, :editor_email

    validates :app, presence: true
    validates :images, presence: true
    validates :metadata, presence: true
    validates :editor_email, presence: true

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

      document.images << images

      Branches::Create.run! parent_revision_id: nil,
        editor_id: editor.id,
        name: 'master',
        document_id: document.id

      ProcessDocumentJob.
        set(wait: 5.seconds).
        perform_later(document)

      document
    end

    private

    def editor
      Editor.where(email: editor_email).first
    end
  end
end
