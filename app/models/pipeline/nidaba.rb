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

    if create_batch && send_images && send_metadata
      processing!
    else
      error!
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
    is_rest_successful? do
      response = RestClient.post(create_batch_url, {})
      self.data["batch"] = JSON.parse(response.body)
      self.save!
    end
  end

  def send_images
    all_successful = document.images.map { |i| send_image(i) }.all?
    if all_successful
      true
    else
      false
    end
  end

  def send_metadata
    is_rest_successful? do
      Dir.mktmpdir do |dir|
        temp_metadata = metadata_file(dir)
        response = RestClient.post send_metadata_url, file: temp_metadata
        self.data["metadata"] = JSON.parse(response.body)
      end
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

  def send_metadata_url
    "#{self.base_url}/api/v1/batch/#{batch.id}/pages?auxiliary=1"
  end

  def send_image(image)
    is_rest_successful? do
      response = RestClient.post send_image_url,
        file: File.new(image.image_scan.current_path)
      self.data["images"] ||= []
      self.data["images"] << JSON.parse(response.body)
    end
  end

  def metadata_file(dir)
    file = File.new(File.join(dir, "metadata.yml"), "w+")
    file.puts(
      {
        title: document.title,
        author: document.author,
        authority: document.authority,
        date: document.date,
        editor: document.editor,
        license: document.license,
        notes: document.notes,
        publisher: document.publisher
      }.to_yaml
    )
    file
  end

  def is_rest_successful?(&block)
    begin
      block.call
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
