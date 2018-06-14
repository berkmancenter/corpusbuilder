module Documents
  class Import::Nidaba < Import::Base
    def image_paths_glob
      "*rgb*any_to_png*nlbin*.png"
    end

    def metadata_glob
      "metadata*.yaml*"
    end

    def elements_for(image)
      raise NotImplementedError
    end
  end
end
