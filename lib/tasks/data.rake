namespace :data do
  task :infer_zones_positions => :environment do
    zones = Zone.all
    progress = ProgressBar.create(:title => "Infering position weights for zones / lines", :total => zones.count)

    zones.each_with_index do |zone, ix|
      Zones::InferPositions.run! zone: zone

      progress.increment
    end
  end

  task :infer_zones_direction => :environment do
    zones = Zone.all
    progress = ProgressBar.create(:title => "Infering directions for zones / lines", :total => zones.count)

    zones.each_with_index do |zone, ix|
      Zones::InferDirection.run! zone: zone

      progress.increment
    end
  end
end
