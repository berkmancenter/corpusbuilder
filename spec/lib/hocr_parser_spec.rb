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

      it "parses the certainty values properly for graphemes" do
        expect(graphemes.uniq { |g| g.grouping }.map(&:certainty).to_a.select { |v| v != 1 }).to eq([0.06, 0.96, 0.82, 0.92, 0.85, 0.93, 0.93, 0.96, 0.96, 0.93, 0.5, 0.92, 0.92, 0.93, 0.91, 0.89, 0.92, 0.61, 0.92, 0.72, 0.67, 0.65, 0.56, 0.56, 0.49, 0.4, 0.31, 0.29, 0.9, 0.57, 0.87, 0.77, 0.16, 0.9, 0.49, 0.89, 0.93, 0.52, 0.92, 0.92, 0.91, 0.9, 0.88, 0.91, 0.91, 0.56, 0.93, 0.63, 0.93, 0.64, 0.9, 0.88, 0.89, 0.92, 0.96, 0.96, 0.91, 0.93, 0.93, 0.93, 0.96, 0.67, 0.67, 0.9, 0.9, 0.92, 0.91, 0.92, 0.96, 0.95, 0.92, 0.93, 0.91, 0.91, 0.93, 0.92, 0.81, 0.87, 0.92, 0.84, 0.89, 0.92, 0.96, 0.92, 0.91, 0.88, 0.92, 0.89, 0.26, 0.91, 0.75, 0.9, 0.34, 0.93, 0.91, 0.93, 0.89, 0.93, 0.88, 0.91, 0.92, 0.91, 0.92, 0.91, 0.93, 0.92, 0.5, 0.92, 0.93, 0.89, 0.56, 0.93, 0.91, 0.85, 0.92, 0.93, 0.91, 0.8, 0.93, 0.27, 0.92, 0.87, 0.4, 0.81, 0.92, 0.9, 0.8, 0.92, 0.92, 0.92, 0.92, 0.8, 0.93, 0.92, 0.93, 0.9, 0.93, 0.82, 0.93, 0.91, 0.92, 0.61, 0.48, 0.85, 0.88, 0.93, 0.91, 0.91, 0.93, 0.94, 0.96, 0.94, 0.73, 0.55, 0.08, 0.94, 0.69, 0.92, 0.93, 0.92, 0.92, 0.92, 0.93, 0.91, 0.52, 0.93, 0.92, 0.4, 0.86, 0.93, 0.96, 0.85, 0.96, 0.92, 0.9, 0.87, 0.58, 0.93, 0.93, 0.92, 0.92, 0.9, 0.92, 0.92, 0.92, 0.86, 0.9, 0.9, 0.95, 0.86, 0.8, 0.8, 0.87, 0.88, 0.59, 0.7, 0.9, 0.89, 0.9, 0.39, 0.89, 0.92, 0.92, 0.93, 0.91, 0.93, 0.89, 0.91, 0.61, 0.9, 0.51, 0.91, 0.91, 0.93, 0.92, 0.92, 0.96, 0.92, 0.91, 0.93, 0.91, 0.93, 0.91, 0.93, 0.89, 0.9, 0.93, 0.96, 0.95, 0.96, 0.94, 0.91, 0.9, 0.95, 0.31, 0.95, 0.92, 0.93, 0.8, 0.56, 0.9, 0.9, 0.78, 0.94, 0.89, 0.91, 0.74, 0.93, 0.88, 0.32, 0.93, 0.91, 0.93, 0.85, 0.86, 0.85, 0.92, 0.47, 0.47, 0.93, 0.14, 0.91, 0.93, 0.96, 0.86, 0.81, 0.93, 0.96, 0.92, 0.93, 0.92, 0.89, 0.89, 0.9, 0.88, 0.89, 0.92, 0.93, 0.89, 0.92, 0.87, 0.93, 0.8, 0.88, 0.88, 0.84, 0.92, 0.38, 0.93, 0.91, 0.7, 0.8, 0.72, 0.9, 0.9, 0.92, 0.93, 0.95, 0.96, 0.43, 0.93, 0.78, 0.92, 0.93, 0.89, 0.93, 0.96, 0.91, 0.93, 0.93, 0.9, 0.9, 0.91, 0.92, 0.77, 0.93, 0.93, 0.91, 0.92, 0.49, 0.7, 0.87, 0.91, 0.92, 0.37, 0.91, 0.81, 0.6, 0.92, 0.93, 0.68, 0.92, 0.86, 0.9, 0.77, 0.95, 0.95, 0.93, 0.96, 0.92, 0.93, 0.92, 0.14, 0.92, 0.45, 0.93, 0.89, 0.91, 0.53, 0.96, 0.37, 0.8, 0.65, 0.49, 0.89, 0.91, 0.91, 0.92, 0.9, 0.93, 0.44, 0.92, 0.9, 0.85, 0.85, 0.9, 0.88, 0.82, 0.96, 0.84, 0.93, 0.91, 0.91, 0.93, 0.9, 0.93, 0.9, 0.93, 0.34, 0.63, 0.9, 0.93, 0.9, 0.92, 0.87, 0.93, 0.85, 0.65, 0.84, 0.93, 0.53, 0.91, 0.71, 0.92, 0.92, 0.92, 0.81, 0.92, 0.89, 0.93, 0.92, 0.56, 0.95, 0.9, 0.91, 0.9, 0.87, 0.9, 0.78])
      end

      it "contains a proper number of surface elements" do
        expect(surfaces.count).to eq(1)
      end

      it "contains a proper number of zone elements" do
        expect(zones.count).to eq(30)
      end

      it "contains a proper number of grapheme elements" do
        # check if we have graphemes from the hocr + directionality
        # ones along with pop-directionality. the latter is one less as the last
        # line doesn't need it
        expect(graphemes.count).to eq(1772 + 30*2 - 1)
      end

      it "contains proper number of pop-directionality graphemes" do
        expect(graphemes.select { |el| el.value == 0x202c.chr }.count).to eq(zones.count - 1)
      end

      it "contains proper number of rtl-directionality graphemes" do
        # we know we have 2 rtl marks in the hocr itself
        expect(graphemes.select { |el| el.value == 0x200f.chr }.count).to eq(zones.count + 2)
      end

      it "contains proper number of ltr-directionality graphemes" do
        # we know we have 8 paragraphs in the test hocr file none of which
        # are marked ltr:
        expect(graphemes.select { |el| el.value == 0x200e.chr }.count).to eq(0)
      end

      it "doesn't yield grapheme if it didn't see the zone first" do
        tester = Proc.new do
          parse_result.elements.inject(false) do |saw, el|
            if el.name == "zone"
              saw = true
            end

            if el.name == "grapheme" && !saw
              raise "All graphemes should belong to some zone"
            end

            saw
          end
        end

        expect(tester.call).to be_truthy
      end
    end
  end
end

