class ExceptionHandler
  def self.process(exception, env)
    data = {
      method: env['REQUEST_METHOD'],
      uri: env['REQUEST_URI'],
      params: env['grape.request.params'],
      headers: env['grape.request.headers']
    }
    ExceptionNotifier.notify_exception(exception, { data: data })
  end
end
