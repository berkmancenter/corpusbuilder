require 'rails_helper'

describe Area do
  let(:y_bad_area) do
    Area.new(ulx: 1, uly: 3, lrx: 4, lry: 2)
  end

  let(:x_bad_area) do
    Area.new(ulx: 4, uly: 2, lrx: 1, lry: 3)
  end

  let :json_boxes do
    [
      { "ulx" => "542.1545062142953",
        "uly" => "870.516171024891",
        "lrx" => "557.1969436462867",
        "lry" => "893.0798271728779" },
      { "ulx" => "560.9575530042845",
        "uly" => "834.7903821239117",
        "lrx" => "656.853091633229",
        "lry" => "902.4813505678725" },
      { "ulx" => "671.8955290652203",
        "uly" => "834.7903821239117",
        "lrx" => "769.6713723731638",
        "lry" => "906.2419599258703" },
      { "ulx" => "786.5941144841539",
        "uly" => "840.4312961609085",
        "lrx" => "835.4820361381256",
        "lry" => "906.2419599258703" },
      { "ulx" => "859.9259969651115",
        "uly" => "862.9949523088953",
        "lrx" => "874.9684343971028",
        "lry" => "893.0798271728779" },
      { "ulx" => "876.8487390761017",
        "uly" => "840.4312961609085",
        "lrx" => "987.7867151370375",
        "lry" => "904.3616552468715" },
      { "ulx" => "1008.4700666060255",
        "uly" => "853.5934289139008",
        "lrx" => "1023.5125040380168",
        "lry" => "891.199522493879" },
      { "ulx" => "1029.1534180750136",
        "uly" => "829.1494680869149",
        "lrx" => "1110.0065192719667",
        "lry" => "900.6010458888736" }
    ]
  end

  it "throws an error when lry is smaller or equal to uly" do
    expect { y_bad_area }.to raise_error(ArgumentError)
  end

  it "throws an error when lrx is smaller or equal to ulx" do
    expect { x_bad_area }.to raise_error(ArgumentError)
  end

  it "supports values given in strings in span_boxes" do
    expect { Area.span_boxes(json_boxes) }.not_to raise_error

    span = Area.span_boxes(json_boxes)

    expect(span.ulx).to eq(542)
    expect(span.uly).to eq(829)
    expect(span.lrx).to eq(1110)
    expect(span.lry).to eq(906)
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
