class Pipeline::Nidaba < Pipeline
  include ActiveSupport::Configurable

  config_accessor :base_url

  def on_error
    document.error!
  end

  def on_processing
    document.processing!
  end

  def start
    assert_status :initial

    if create_batch && send_images
      processing!
    end
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
    begin
      response = RestClient.post(create_batch_url, {})
      self.data["batch"] = JSON.parse(response.body)
      self.save!
      true
    rescue RestClient::RequestFailed
      error!
      false
    end
  end

  def send_images
    all_successful = document.images.map { |i| send_image(i) }.all?
    if all_successful
      true
    else
      error!
      false
    end
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

  def send_image(image)
    begin
      response = RestClient.post send_image_url,
        file: File.new(image.image_scan.current_path)
      self.data["images"] ||= []
      self.data["images"] << JSON.parse(response.body)
      true
    rescue RestClient::RequestFailed
      false
    end
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
