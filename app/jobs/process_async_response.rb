class ProcessAsyncResponse < ApplicationJob
  queue_as :default

  def perform(async_response, action_name, params)
    action = action_name.to_s.constantize
    result = action.run!(params).result
    async_response.update_attribute(:payload, result)
    async_response.success!
  rescue => e
    async_response.update_attribute(:payload, e.message)
    async_response.error!
  end
end

