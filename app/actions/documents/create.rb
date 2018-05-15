module Documents
  class Create < Action::Base
    attr_accessor :images, :metadata, :app, :editor_email, :backend

    validates :app, presence: true
    validates :images, presence: true
    validates :metadata, presence: true
    validates :editor_email, presence: true

    validate :editor_exists
    #validate :proper_languages_provided

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
        backend: (backend || 'tesseract'),
        app_id: @app.id

      document.images << image_records

      # producing image.count SQL UPDATE statements but since we're here
      # in a background job and books have at most 1k - 2k pages we can
      # worry about it if it turns out being too costly.
      #
      # (speeding it up by defering the commit by wrapping inside the transaction)
      Image.connection.transaction do
        image_records.each_with_index do |image, index|
          image.update_attribute(:order, index + 1)
        end
      end

      Branches::Create.run! parent_revision_id: nil,
        editor_id: editor.id,
        name: 'master',
        document_id: document.id

      ProcessDocumentJob.
        perform_later(document)

      document
    end

    private

    def image_records
      @_image_records ||= Image.find(image_ids).
              index_by(&:id).
              slice(*image_ids).
              values
    end

    def image_ids
      @_image_ids ||= images.map { |image| image[:id] }
    end

    def editor
      @_editor ||= Editor.where(email: editor_email).first
    end

    def editor_exists
      if !editor.present?
        errors.add(:editor_email, "doesn't specify an editor that exists in the system")
      end
    end

    def languages
      metadata[:languages]
    end

    def proper_languages_provided
      if languages.blank? || !languages.is_a?(Enumerable)
        return errors.add(:metadata, "doesn't specify the list of languages")
      end

      if languages.any? { |lang| LanguageList::LanguageInfo.find(lang).nil? }
        errors.add(:metadata, "contains incorrectly specified languages - they should be best described using ISO-639-3 codes")
      end
    end
  end
end
