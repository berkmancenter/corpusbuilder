class Annotation < ApplicationRecord
  serialize :areas, Area::ArraySerializer

  enum mode: [
    :comment, :category,
    :h1, :h2, :h3, :h4, :h5, :p,
  ]

  enum status: [ :regular, :conflict ]

  has_and_belongs_to_many :revisions
  belongs_to :editor

  def structural?
    h1? || h2? || h3? || h4? || h5? || p?
  end

  def overlaps?(other)
    areas.any? do |a1|
      other.areas.any? do |a2|
        a1.overlaps?(a2)
      end
    end
  end

  class WithEditor < Grape::Entity
    expose :id
    expose :content
    expose :areas
    expose :mode do |annotation|
      annotation.mode
    end
    expose :status do |annotation|
      annotation.status
    end
    expose :payload
    expose :editor_email
  end
end
