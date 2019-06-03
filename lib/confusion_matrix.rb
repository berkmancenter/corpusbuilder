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

  def predicted_values
    @data.values.flatten.uniq.sort.reject(&:empty?)
  end

  def true_values
    @data.keys.flatten.uniq.sort.reject(&:empty?)
  end

  def all_values
    (predicted_values + true_values).uniq.sort
  end

  def sum_true
    @data.keys.inject(0) { |sum, truth| sum + @data[truth].count }
  end

  def sum_all_errors
    true_values.inject(0) { |sum, truth| sum + sum_errors_for(truth) }
  end

  def sum_errors_for(truth)
    (@data[truth] || []).inject(0) do |sum, pred|
      sum + (truth == pred ? 0 : 1)
    end
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
      "(empty)"
    else
      table = Tabulo::Table.new(predicted_values + ['']) do |t|
        t.add_column('') do |pred|
          if pred == ''
            'Ø'
          else
            pred
          end
        end
        all_values.each do |truth|
          t.add_column(truth) { |pred| score(truth, pred) }
        end
        t.add_column('Ø') { |pred| score('', pred) }
      end

      <<-STR

#{table}
#{table.horizontal_rule}
normalized edit distance: #{normalized_edit_distance}
      STR
    end
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
