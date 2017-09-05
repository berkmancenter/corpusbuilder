class Pipeline::Nidaba < Pipeline
  include ActiveSupport::Configurable

  config_accessor :base_url

  def on_error
    document.error!
  end

  def on_processing
    document.processing!
  end

  def on_success
    document.ready!
  end

  def start
    assert_status :initial

    if create_batch && send_images && create_tasks
      processing!
    else
      error!
    end
  end

  def poll
    assert_status :processing

    case check_batch
    when :success
      success!
    when :error
      error!
    end
  end

  def result
    assert_status :success

    self.pages.lazy.map do |page|
      url = page.values.first
      id = images.find do |image|
        image.keys.first == page.keys.first
      end.values.first
      {
        id => RestClient.get(url).body
      }
    end
  end

  def batch_id
    data.fetch("batch", {}).fetch("id", nil)
  end

  def pages
    data.fetch("pages", [])
  end

  def images
    data.fetch("images", [])
  end

  private

  def create_batch
    is_rest_successful? do
      response = RestClient.post(create_batch_url, {})
      self.data["batch"] = JSON.parse(response.body)
      self.save!
    end
  end

  def create_tasks
    tasks.map { |create| create.call }.all?
  end

  def send_images
    document.images.map { |i| send_image(i) }.all?
  end

  def check_batch
    response = RestClient.get(batch_url)
    batch = JSON.parse(response.body)
    states = batch["chains"].values.map do |task|
      task["state"]
    end.uniq
    if states.include? "FAILURE"
      return :error
    elsif states.include? "PENDING"
      return :processing
    else
      pages = batch["chains"].values.select do |task|
        task["task"].first == "ocr"
      end.map do |task|
        { task["root_documents"].first => task["result"] }
      end
      self.data["pages"] = pages
      self.save!
      return :success
    end
  rescue RestClient::RequestFailed
    return :processing
  end

  def tasks
    # improve: incorporate other ocr backends
    # for different languages
    [
      task(:img, :any_to_png),
      task(:binarize, :nlbin, {
        border: 0.1,
        escale: 1,
        high: 90,
        low: 5,
        perc: 80,
        range: 20,
        threshold: 0.5,
        zoom: 0.5
      }),
      task(:segmentation, :tesseract),
      task(:ocr, :kraken)
    ]
  end

  def task(type, name, options = {})
    Proc.new do
      is_rest_successful? do
        RestClient.post task_url(type, name), options
        self.data["tasks"] ||= []
        self.data["tasks"] << { type: type, name: name }
      end
    end
  end

  def task_url(type, name)
    "#{self.base_url}/api/v1/batch/#{batch_id}/tasks/#{type}/#{name}"
  end

  def batch_url
    "#{self.base_url}/api/v1/batch/#{batch_id}"
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
    "#{self.base_url}/api/v1/batch/#{batch_id}/pages"
  end

  def send_metadata_url
    "#{self.base_url}/api/v1/batch/#{batch_id}/pages?auxiliary=1"
  end

  def send_image(image)
    is_rest_successful? do
      response = RestClient.post send_image_url,
        file: File.new(image.image_scan.current_path)
      data = JSON.parse(response.body)
      self.data["images"] ||= []
      self.data["images"] << {
        data["url"] => image.id
      }
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
end
