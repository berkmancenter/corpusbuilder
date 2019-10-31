module Documents::Import
  class Archive < Action::Base
    attr_accessor :path

    def execute
      Dir.mktmpdir do |dir|
        copy_archive dir
        extract_archive dir

        [:images, :documents, :surfaces, :zones, :graphemes, :revisions, :branches].each do |collection|
          import_json collection, dir
        end

        import_revisions_graphemes dir
        copy_images dir
      end
    end

    def archive_name
      File.basename path
    end

    def copy_archive(dir:)
      FileUtils.cp path, dir
    end

    def extract_archive(dir:)
      TTY::Command.new.run!("uzip #{archive_name}", chdir: dir)
    end

    def import_json(collection, dir:)
      File.read(Pathname.new(dir).join("#{collection}.json").to_s).tap do |raw|
        JSON.parse(raw).tap do |data|
          collection.to_s.camelize.singularize.constantize.create! data
        end
      end
    end

    def import_revisions_graphemes(dir:)
      File.read(Pathname.new(dir).join("#{collection}.json").to_s).tap do |raw|
        JSON.parse(raw).tap do |data|
          data.each do |revision_id, grapheme_ids|
            Revision.find(revision_id).tap do |revision|
              Revisions::CreatePartition.run! \
                revision: revision

              Revisions::PointAtGraphemes.run! \
                ids: grapheme_ids,
                target: revision
            end
          end
        end
      end
    end

    def copy_images(dir:)
      ["image_scan", "hocr", "processed_image"].each do |type|
        TTY::Command.new.run!("rsync -a #{type}/ #{Rails.root.join("public", "uploads", "image")}/", chdir: dir)
      end
    end
  end
end
