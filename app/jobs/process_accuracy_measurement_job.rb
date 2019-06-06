class ProcessAccuracyMeasurementJob < ApplicationJob
  queue_as :default

  def perform(measurement:)
    if measurement.scheduled?
      measurement.ocring!
    end

    if measurement.ocred?
      measurement.summarizing!
    end

    AccuracyMeasurements::Process.run! measurement: measurement
  end
end

