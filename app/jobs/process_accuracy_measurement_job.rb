class ProcessAccuracyMeasurementJob < ApplicationJob
  queue_as :default

  def perform(measurement:)
    AccuracyMeasurements::Process.run! measurement: measurement
  end
end

