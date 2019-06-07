module AdminHelper
  def summary_matrix(confusion_matrix:, mode: :score)
    data = confusion_matrix.data.to_json

    tag.div class: :summary_matrix, :'data-summary' => data do
      tag.canvas style: 'width: 100%'
    end
  end
end
