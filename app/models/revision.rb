class Revision < ApplicationRecord
  include Workflow

  belongs_to :parent, class_name: 'Revision', required: false
  belongs_to :document

  workflow status: [ :regular, :working, :conflict ]

  has_many :branches, dependent: :destroy
  has_and_belongs_to_many :annotations, dependent: :destroy

  scope :working, -> {
    where(status: [
      Revision.statuses[:working],
      Revision.statuses[:conflict]
    ])
  }

  def self.graphemes_revisions_partition_table_name(id)
    "graphemes_revisions_#{id.gsub(/-/, '_')}"
  end

  def graphemes_revisions_partition_table_name
    self.class.graphemes_revisions_partition_table_name(id)
  end

  def graphemes
    memoized do
      RevisionGraphemes.new(self)
    end
  end

  def conflict_graphemes
    graphemes.where(status: Grapheme.statuses[:conflict])
  end

  def graphemes=(items)
    Revisions::PointAtGraphemes.run!(
      ids: items.map do |item|
        if !item.persisted?
          item.save!
        end

        item.id
      end,
      target: self
    )
    self.clear_memoized
    self.graphemes
  end

  def grapheme_ids
    memoized do
      self.graphemes.map(&:id)
    end
  end

  # An enumerable class allowing the use of the standard
  # Rails style linked table like syntax for the highly
  # optimized CorpusBuilder ways of linking revisions
  # with graphemes
  class RevisionGraphemes
    include Enumerable

    attr_accessor :revision

    def initialize(revision)
      self.revision = revision
    end

    def each(&block)
      Graphemes::QueryPage.run!(
        revision_id: self.revision.id
      ).result.each(&block)
    end

    def <<(graphemes)
      (graphemes.is_a?(Enumerable) ? graphemes : [ graphemes ]).each do |grapheme|
        Revisions::AddGrapheme.run!(
          revision_id: self.revision.id,
          grapheme_id: grapheme.id
        )
      end

      graphemes
    end

    def default_scope
      Grapheme.joins("inner join #{revision.graphemes_revisions_partition_table_name} on #{revision.graphemes_revisions_partition_table_name}.grapheme_id = graphemes.id")
    end

    def select(*args)
      default_scope.select(*args)
    end

    def reorder(*args)
      default_scope.reorder(*args)
    end

    def where(*args)
      default_scope.where(*args)
    end

    def joins(*args)
      default_scope.joins(*args)
    end

    def ==(other_revision_graphemes)
      self.each.to_a == other_revision_graphemes.each.to_a
    end
  end
end
