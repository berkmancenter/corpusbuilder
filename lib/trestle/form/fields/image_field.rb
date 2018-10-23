module Trestle
  class Form
    module Fields
      class ImageField < Field
        def initialize(builder, template, name, url, options={}, html_options={}, &block)
          super(builder, template, name, options, &block)

          @url = url
        end

        def field
          @template.content_tag :div do
            builder.raw_file_field(name, options) + @template.image_tag(@url)
          end
        end
      end
    end
  end
end

Trestle::Form::Builder.register(:image_field, Trestle::Form::Fields::ImageField)
