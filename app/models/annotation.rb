class Annotation < ApplicationRecord
  serialize :areas, Area::ArraySerializer

  enum mode: [
    :comment, :category,
    :h1, :h2, :h3, :h4, :h5, :p,
    :biography, :year_birth, :year_death, :age, :person,
    :administrative, :route
  ]

  has_and_belongs_to_many :revisions
  belongs_to :editor

  class WithEditor < Grape::Entity
    expose :content
    expose :areas
    expose :mode do |annotation|
      annotation.mode
    end
    expose :payload
    expose :editor_email
  end
end
