class Pipeline::Nidaba < Pipeline
  include ActiveSupport::Configurable

  config_accessor :base_url

  def start
    assert_status :initial

    create_batch
    send_images
  end

  def poll
    assert_status :processing

    # todo: implement me
  end

  def result
    assert_status :success

    # todo: implement me
  end

  def batch
    Batch.new(data["batch"])
  end

  private

  def create_batch
    response = RestClient.post(create_batch_url, {})
    self.data["batch"] = JSON.parse(response.body)
    self.save!
  end

  def send_images
    document.images.each do |image|
      response = RestClient.post send_image_url,
        file: File.new(image.image_scan.current_path)
      if response.code == 201
        self["images"] ||= []
        self["images"] << JSON.parse(response.body)
      end
    end
    self.save!
  end

  def assert_status(status)
    if self.status != status.to_s
      raise Pipeline::Error.new, "Expected pipeline with status #{status}"
    end
  end

  def create_batch_url
    "#{self.base_url}/api/v1/batch"
  end

  def send_image_url
    "#{self.base_url}/api/v1/batch/#{batch.id}/pages"
  end

  class Batch
    attr_accessor :id

    def initialize(json)
      @id = json["id"]
    end

    def as_json
      {
        id: @id
      }
    end
  end

end
