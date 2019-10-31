module Documents::Export
  class Archive < Action::Base
    attr_accessor :document_id, :path, :name

    def execute
      Dir.mktmpdir do |dir|
        copy_image_files dir: dir

        [:images, :documents, :surfaces, :zones, :graphemes, :revisions, :branches].each do |collection|
          write_json collection, dir: dir
        end

        write_revisions_graphemes  dir: dir

        FileUtils.cp zip_archive(dir: dir), destination
      end

      puts "Wrote #{destination}"
    end

    def filename
      name.nil? ? document.id : name
    end

    def destination
      Pathname.new(path.to_s).join("#{filename}.zip").to_s
    end

    def write_json(collection, dir:)
      File.open Pathname.new(dir).join("#{collection}.json"), "w" do |file|
        file << JSON.dump(data(collection))
      end
    end

    def data(collection)
      self.send(collection).map(&:attributes)
    end

    def copy_image_files(dir:)
      images.each do |image|
        FileUtils.mkdir_p Pathname.new(dir).join("image_scan", image.id)
        FileUtils.mkdir_p Pathname.new(dir).join("hocr", image.id)
        FileUtils.mkdir_p Pathname.new(dir).join("processed_image", image.id)

        [:image_scan, :hocr, :processed_image].each do |type|
          image.send(type).file.file.tap do |path|
            FileUtils.cp(
              path,
              Pathname.new(dir).join(path.gsub("#{Rails.root}/public/uploads/image/", "")).to_s
            )
          end
        end
      end
    end

    def zip_archive(dir:)
      TTY::Command.new.run!("zip -r -9 document.zip ./*", chdir: dir)

      Pathname.new(dir).join("document.zip").to_s
    end

    def write_revisions_graphemes(dir:)
      data = document.revisions.map do |rev|
        [rev.id, rev.graphemes.select(:id).map(&:id)]
      end.to_h

      File.open Pathname.new(dir).join("revisions_graphemes.json"), "w" do |file|
        file << JSON.dump(data)
      end
    end

    def document
      memoized do
        Document.find document_id
      end
    end

    def documents
      [document]
    end

    def images
      document.images
    end

    def surfaces
      document.surfaces
    end

    def zones
      Zone.where surface: document.surfaces
    end

    def graphemes
      Grapheme.where zone: zones
    end

    def revisions
      document.revisions
    end

    def branches
      document.branches
    end
  end
end
