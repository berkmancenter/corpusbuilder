require 'rails_helper'

describe HocrParser do
  describe "The parse method" do
    let(:parse_result) do
      HocrParser.parse(result_hocr)
    end

    let(:result_hocr) do
      file = File.open("spec/support/files/output.hocr")
      result = file.read
      file.close
      result
    end

    it "returns the Parser::Result when fed with proper data" do
      expect(parse_result).to be_an_instance_of(HocrParser)
    end

    context "result" do
      let(:surfaces) do
          parse_result.elements.select { |el| el.name == "surface" }
      end

      let(:zones) do
          parse_result.elements.select { |el| el.name == "zone" }
      end

      let(:graphemes) do
          parse_result.elements.select { |el| el.name == "grapheme" }
      end

      it "contains the elements enumerator" do
        expect(parse_result.elements).to be_an_instance_of(Enumerator::Lazy)
      end

      it "contains a proper number of surface elements" do
        expect(surfaces.count).to eq(1)
      end

      it "contains a proper number of grapheme elements" do
        expect(graphemes.count).to eq(1772)
      end
    end
  end
end

