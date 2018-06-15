module Documents
  class Import::Base < Action::Base
    attr_accessor :archive_path, :app, :editor_email

    finally :remove_temp_directory

    def execute
      pages.each do |page|
        Documents::Create.run! image_ocr_result: page.elements,
          document: document, image_id: page.image.id
      end

      document
    end

    def elements_for(image)
      raise NotImplementedError
    end

    def image_paths_glob
      raise NotImplementedError
    end

    def metadata
      raise NotImplementedError
    end

    def metadata_path
      Dir.glob(metedata_glob).first
    end

    def remove_temp_directory
      FileUtils.remove_entry working_path
    end

    def working_path
      memoized do
        Dir.mktmpdir
      end
    end

    def pages
      memoized do
        images.map do |image|
          Page.new image, elements_for(image)
        end
      end
    end

    def images
      memoized do
        image_paths.map do |path|
          File.open(path) do |image_file|
            image = Images::Create.run! file: image_file,
              name: path.basename
            image.processed_image = File.open(image.image_scan.file.file)
            image.save!
            image
          end
        end
      end
    end

    def absolute_archive_path
      File.expand_path archive_path
    end

    def image_paths
      memoized do
        tar_output = `tar xjf #{absolute_archive_path} -C #{working_path}`
        tar_success = $?

        if !tar_success
          raise StandardError, "There was an error when extracting an archive. Output: #{tar_output}"
        end

        Dir.glob "#{working_path}/#{image_paths_glob}"
      end
    end

    def document
      memoized do
        Documents::Create.run! images: images,
          metadata: metadata,
          app: app,
          editor_email: editor_email,
          backend: :import
      end
    end

    class Page
      attr_accessor :image, :elements

      def initialize(image, elements)
        @image = image
        @elements = elements
      end
    end
  end
end
