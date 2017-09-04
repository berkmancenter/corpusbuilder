require 'rails_helper'

describe Area do
  describe Area::Serializer do
    let(:database_box) do
      "((4,2),(1,1))"
    end

    context "loading" do
      # we're always getting the (ur, ll) points back
      # from Postgres

      let(:area) do
        Area::Serializer.load database_box
      end

      it "parses properly from database ur-ll order to ul-lr" do
        expect(area.ulx).to eq(1)
        expect(area.uly).to eq(2)
        expect(area.lrx).to eq(4)
        expect(area.lry).to eq(1)
      end
    end

    context "dumping" do
      # Postgres expects points in the ur-ll diagonal
      # so we expect the serializer to correctly convert
      # from the ul-lr diagonal that's being used in app
      # that is being forced e. g. by the TEI format

      let(:area_dump) do
        Area::Serializer.dump Area.new(ulx: 1, uly: 2, lrx: 4, lry: 1)
      end

      it "dumps correctly into the ur-ll order from ul-lr" do
        expect(area_dump).to eq(database_box)
      end
    end
  end
end
