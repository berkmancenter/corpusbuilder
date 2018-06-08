module Documents::Export
  class ExportUnicharsetTesseract < Action::Base
    attr_accessor :dir_path

    def execute
      IO.write unicharset_file_path, file_lines.to_a.join("\n")
    end

    def file_lines
      Enumerator.new do |out|
        lines = unique_characters.each_with_index.map do |char, ix|
          script = Unicode::Scripts.scripts(char).first
          props = Unicode::Categories.categories(char)

          isalpha = is_alpha(props)
          islower = is_lower(props)
          isupper = is_upper(props)
          isdigit = is_digit(props)
          ispunctuation = is_punct(props)

          props = [ isalpha, islower, isupper, isdigit, ispunctuation].reverse.inject("") do |state, is|
            "#{state}#{bool_to_si(is)}"
          end

          "#{char} #{props.to_i(2)} #{script} #{ix + 1}"
        end

        out << lines.count + 1
        out << "NULL 0 Common 0"
        lines.each { |o| out << o }
      end
    end

    def unique_characters
      memoized do
        list = []

        IO.popen(cat_box_files) do |stdout|
          stdout.each do |line|
            list << line.first
          end
        end

        list.uniq.sort
      end
    end

    def cat_box_files
      "cat #{ File.join(dir_path, "*.gt.txt") }"
    end

    def unicharset_file_path
      File.join dir_path, "unicharset"
    end

    def bool_to_si(b)
      b ? "1" : "0"
    end

    def is_digit(props)
      (props & ["Nd", "No", "Nl"]).count > 0
    end

    def is_letter(props)
      (props & ["LC", "Ll", "Lm", "Lo", "Lt", "Lu"]).count > 0
    end

    def is_alpha(props)
      is_letter(props)
    end

    def is_lower(props)
      (props & ["Ll"]).count > 0
    end

    def is_upper(props)
      (props & ["Lu"]).count > 0
    end

    def is_punct(props)
      (props & ["Pc", "Pd", "Pe", "Pf", "Pi", "Po", "Ps"]).count > 0
    end
  end
end
