namespace :images do
  task :fix_processed_paths => :environment do
    Image.all.each do |image|
      if image.processed_image.file.present? && image.processed_image.file.file.present?
        if !File.exists? image.processed_image.file.file
          FileUtils.mkdir_p Rails.root.join('public', 'uploads', 'image', 'processed_image', image.id)

          from = image.processed_image.file.file.gsub(/image.processed_image.[^\/]+./, '')

          if File.exists?(from)
            FileUtils.mv \
              from,
              image.processed_image.file.file

            if File.exists? image.processed_image.file.file
              puts "Moved the file for image #{image.id}"
            else
              raise StandardError, "Ooops. Something went wrong (image #{image.id})"
            end
          else
            puts "Skipping for #{image.id}"
          end
        end
      else
        puts "Skipping for #{image.id}"
      end
    end
  end
end
