require 'rails_helper'

describe Area do
  let(:y_bad_area) do
    Area.new(ulx: 1, uly: 3, lrx: 4, lry: 2)
  end

  let(:x_bad_area) do
    Area.new(ulx: 4, uly: 2, lrx: 1, lry: 3)
  end

  it "throws an error when lry is smaller or equal to uly" do
    expect { y_bad_area }.to raise_error(ArgumentError)
  end

  it "throws an error when lrx is smaller or equal to ulx" do
    expect { x_bad_area }.to raise_error(ArgumentError)
  end

  describe Area::Serializer do
    let(:database_box) do
      "((4,3),(1,2))"
    end

    context "loading" do
      # we're always getting the (ur, ll) points back
      # from Postgres
      #
      # moreover, it's all being stored in the database
      # treating the Y axis as pointing upwards

      let(:area) do
        Area::Serializer.load database_box
      end

      it "parses properly from database ur-ll order to ul-lr" do
        expect(area.ulx).to eq(1)
        expect(area.uly).to eq(2)
        expect(area.lrx).to eq(4)
        expect(area.lry).to eq(3)
      end
    end

    context "dumping" do
      # Postgres expects points in the ur-ll diagonal
      # so we expect the serializer to correctly convert
      # from the ul-lr diagonal that's being used in app
      # that is being forced e. g. by the TEI format

      let(:area_dump) do
        Area::Serializer.dump Area.new(ulx: 1, uly: 2, lrx: 4, lry: 3)
      end

      let(:y_bad_area_dump) do
        Area::Serializer.dump Area.new(ulx: 1, uly: 3, lrx: 4, lry: 2)
      end

      let(:x_bad_area_dump) do
        Area::Serializer.dump Area.new(ulx: 4, uly: 2, lrx: 1, lry: 3)
      end

      it "dumps correctly into the ur-ll order from ul-lr" do
        expect(area_dump).to eq(database_box)
      end

      it "throws an error when lry is smaller or equal to uly" do
        expect { y_bad_area_dump }.to raise_error(ArgumentError)
      end

      it "throws an error when lrx is smaller or equal to ulx" do
        expect { x_bad_area_dump }.to raise_error(ArgumentError)
      end
    end
  end
end
