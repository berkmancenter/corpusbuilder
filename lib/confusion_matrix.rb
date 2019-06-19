class ConfusionMatrix
  attr_accessor :data

  def initialize(hash_data = {})
    @data = hash_data || {}
  end

  def observe(truth, pred)
    bucket = @data.fetch(truth.to_s, {})
    value = bucket.fetch(pred.to_s, 0)
    bucket[pred.to_s] = value + 1
    @data[truth.to_s] = bucket

    self
  end

  def /(rhs)
    raise ArgumentError, "Division for confusion matrices is supported only for floats" \
      if !rhs.is_a?(Float)

    cm = ConfusionMatrix.new(self.data.clone)
    cm.data.each do |_, preds|
      preds.keys.each do |key|
        preds[key] /= rhs
      end
    end
    cm
  end

  def empty?
    @data.keys.empty?
  end

  def ==(other)
    @data == other.data
  end

  def score(truth, pred)
    @data.fetch(truth.to_s, {}).fetch(pred.to_s, 0)
  end

  def sum_true_for(c)
    values = @data.fetch(c.to_s, {}).values

    values.count > 0 ? values.sum : 0
  end

  def score_percent(truth, pred)
    value = score(truth, pred)
    all = sum_true_for(truth) * 1.0

    value / all
  end

  def predicted_values
    @data.values.map(&:keys).flatten.uniq.sort.reject(&:empty?)
  end

  def true_values
    @data.keys.uniq.sort.reject(&:empty?)
  end

  def all_values
    (predicted_values + true_values).uniq.sort.reject { |c| c == "\n" }
  end

  def sum_true
    @data.keys.inject(0) { |sum, truth| sum + @data.fetch(truth, {}).values.sum }
  end

  def sum_all_errors
    @data.map do |truth, preds|
      preds.map do |pred, value|
        truth != pred ? value : 0
      end
    end.flatten.sum
  end

  def sum_errors_for(truth)
    @data.reject { |k, v| k == truth }.
      values.
      map { |h| h[truth] || 0  }.
      concat([0]).
      sum
  end

  def p_correct_given_true_for(truth)
    correct = score(truth, truth)
    all = (@data[truth] || []).count

    (correct * 1.0) / all
  end

  def p_true_given_pred_for(pred)
    correct = score(pred, pred)
    all = (@data.values.flatten.select { |c| c == pred } || []).count

    (correct * 1.0) / all
  end

  def normalized_edit_distance
    (sum_all_errors * 1.0) / sum_true
  end

  def inspect
    if @data.values.flatten.empty?
      "#<ConfusionMatrix:#{object_id} empty>"
    else
      "#<ConfusionMatrix:#{object_id} sum_all_errors:#{sum_all_errors} normalized_edit_distance:#{normalized_edit_distance}>"
    end
  end

  class << self
    def load(json)
      self.new(JSON.load(json))
    end

    def dump(object)
      object.data.to_json
    end

    def sum(matrices)
      raise ArgumentError if !matrices.is_a?(Array) || \
        matrices.any? { |m| !m.is_a?(ConfusionMatrix) }

      data = matrices.inject({}) do |sum, matrix|
        matrix.data.each do |truth, predictions|
          sum[truth] ||= {}
          predictions.each do |pred, count|
            sum[truth][pred] ||= 0
            sum[truth][pred] += count
          end
        end

        sum
      end

      ConfusionMatrix.new data
    end

    def mean(matrices)
      sum(matrices) / (1.0 * matrices.count)
    end
  end
end
