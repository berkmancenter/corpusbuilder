class ConfusionMatrix
  def initialize(hash_data)
  end

  class << self
    def load(json)
      self.new({})
    end

    def dump(object)
      {}.to_json
    end
  end
end
