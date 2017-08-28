class Pipeline::Nidaba < Pipeline
  include ActiveSupport::Configurable

  config_accessor :base_url

  def start
    assert_status :initial

    RestClient.post(create_batch_url, {})
    # todo: implement me
  end

  def poll
    assert_status :processing

    # todo: implement me
  end

  def result
    assert_status :success

    # todo: implement me
  end

  private

  def assert_status(status)
    if self.status != status.to_s
      raise Pipeline::Error.new, "Expected pipeline with status #{status}"
    end
  end

  def create_batch_url
    "#{self.base_url}/api/v1/batch"
  end

end
