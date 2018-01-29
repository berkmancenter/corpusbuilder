class Annotation < ApplicationRecord
  serialize :areas, Area::ArraySerializer
end
