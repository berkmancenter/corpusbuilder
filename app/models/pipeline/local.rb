class Pipeline::Local < Pipeline
  def start
    assert_status :initial

    processing!
  end

  def result
    assert_status :success

    document.images.lazy.map do |image|
      {
        image.id => HocrParser.parse(image.hocr.read)
      }
    end
  end

  def forward
    assert_status :processing

    op = stage.to_sym

    begin
      if self.send(op) == :done
        next_stage!
      end
    rescue
      # todo: provide the mechanism of number of tries
      return :error
    end

    if stage == "done"
      return :success
    end
  end

  def stage
    self.data.fetch("stage", "preprocess")
  end

  def preprocess
    next_image, one_after = document.images.lazy.select do |i|
      !i.preprocessed?
    end.take(2).to_a

    if next_image.present?
      Images::Preprocess.run!(
        image: next_image
      )
      return one_after.present? ? :more : :done
    else
      return :done
    end
  end

  def segment
    # todo: implement this step
    :done
  end

  def ocr
    next_image, one_after = document.images.lazy.select do |i|
      !i.ocred?
    end.take(2).to_a

    if next_image.present?
      # todo: implement switching between backends
      Images::OCR.run!(
        image: next_image,
        backend: :tesseract
      )
      return one_after.present? ? :more : :done
    else
      return :done
    end

  end

  def cleanup!
    # todo: implement this step
  end

  def next_stage!
    stages = [ "preprocess", "segment", "ocr", "done" ]

    new_index = stages.index(stage) + 1

    self.data["stage"] = stages[new_index]
    self.save!
  end
end
