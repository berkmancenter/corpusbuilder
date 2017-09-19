module Documents
  class Correct < Action::Base
    attr_accessor :document, :graphemes, :revision_id, :branch_name

    def execute
      @graphemes.each do |spec|
        Graphemes::Create.run! revision: revision,
          area: Area.new(ulx: spec[:area][:ulx],
                         uly: spec[:area][:uly],
                         lrx: spec[:area][:lrx],
                         lry: spec[:area][:lry]),
          value: spec[:value],
          surface_number: spec[:surface_number]

      end

      revision.grapheme_ids = revision.grapheme_ids - existing_ids
    end

    private

    def existing_ids
      @graphemes.map { |g| g.fetch(:id, nil) }.reject(&:nil?).uniq
    end

    def revision
      @_revision ||= if @revision_id.present?
        Revision.find(@revision_id)
      else
        Revision.where(
          id: @document.branches.where(name: @branch_name).select("branches.revision_id")
        ).first
      end
    end
  end
end
