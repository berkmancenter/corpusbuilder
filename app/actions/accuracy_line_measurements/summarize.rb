module AccuracyLineMeasurements
  class Summarize < Action::Base
    attr_accessor :line_measurement

    def execute
      line_measurement.update_attributes! \
        confusion_matrix: confusion_matrix,
        status: :ready

      line_measurement.reload
    end

    def confusion_matrix
      memoized do
        alignments.inject(ConfusionMatrix.new) do |cm, data|
          gt, pred = data
          cm.observe (gt || ''), (pred || '')
          cm
        end
      end
    end

    def alignments
      memoized do
        aligns = Shared::NeedlemanWunsch.run!(
          from: ground_truth.chars,
          to: predicted.chars,
          gap_penalty: -1 * ground_truth.chars.count,
          score_fn: -> (left, right) { left == right ? 1 : -1 }
        ).result

        aligns.first.zip(aligns.last)
      end
    end

    def predicted
      memoized do
        line_measurement.transcription
      end
    end

    def ground_truth
      memoized do
        exporter = Documents::Export::ExportLineBoxesKraken.new

        exporter.zone = line_measurement.zone
        exporter.document = line_measurement.zone.surface.document

        exporter.text
      end
    end
  end
end
