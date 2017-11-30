module Documents
  class CompileCorrections < Action::Base
    attr_accessor :grapheme_ids, :text

    validates :grapheme_ids, presence: true
    validates :text, presence: true

    def execute
    end
  end
end
