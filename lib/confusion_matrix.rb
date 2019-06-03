class ConfusionMatrix
  attr_accessor :data

  def initialize(hash_data = {})
    @data = hash_data
  end

  def observe(truth, prediction)
    data[truth.to_s] ||= []
    data[truth.to_s] << prediction
  end

  def ==(other)
    @data == other.data
  end

  def score(truth, prediction)
    (@data[truth.to_s] || []).select { |c| c == prediction.to_s }.count
  end

  class << self
    def load(json)
      self.new(JSON.load(json))
    end

    def dump(object)
      object.data.to_json
    end

    def merge(matrices)
      raise ArgumentError if !matrices.is_a?(Array) || \
        matrices.any? { |m| !m.is_a?(ConfusionMatrix) }

      data = matrices.inject({}) do |sum, matrix|
        matrix.data.each do |truth, predictions|
          sum[truth] ||= []
          sum[truth].concat(predictions)
        end

        sum
      end

      ConfusionMatrix.new data
    end
  end
end
