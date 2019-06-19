require 'rails_helper'

describe ConfusionMatrix do
  let(:hash) do
    {
      'a' => { 'a' => 3, 'b' => 1 }, # ['a', 'a', 'a', 'b'],
      'b' => { 'b' => 2, 'a' => 2 }, # ['b', 'b', 'a', 'a'],
      'c' => { 'c' => 2, '' => 2, 'b' => 1 }, # ['c', 'c', '', '', 'b'],
      ''  => { 'a' => 1 } # ['a']
    }
  end

  let(:json) { JSON.dump(hash) }
  let(:matrix) { ConfusionMatrix.load(json) }

  describe "init by hash" do
    it "works" do
      expect(ConfusionMatrix.new(hash)).to \
        eq(ConfusionMatrix.load(json))
    end
  end

  describe "sum" do
    it "sums matrices correctly" do
      matrix1 = ConfusionMatrix.new
      matrix2 = ConfusionMatrix.new

      matrix1.observe 'a', 'a'
      matrix1.observe 'a', 'a'
      matrix1.observe 'a', ''
      matrix1.observe 'b', ''
      matrix1.observe 'c', 'c'
      matrix1.observe 'c', 'b'
      matrix1.observe '', 'b'

      matrix2.observe 'a', 'a'
      matrix2.observe 'a', 'b'
      matrix2.observe 'b', 'b'
      matrix2.observe 'c', 'c'
      matrix2.observe '', 'c'

      summed = ConfusionMatrix.sum([matrix1, matrix2])

      expect(summed.score('a','a')).to eq(3)
      expect(summed.score('a','b')).to eq(1)
      expect(summed.score('a','c')).to eq(0)
      expect(summed.score('a','')).to eq(1)

      expect(summed.score('b','a')).to eq(0)
      expect(summed.score('b','b')).to eq(1)
      expect(summed.score('b','c')).to eq(0)
      expect(summed.score('b','')).to eq(1)

      expect(summed.score('c','a')).to eq(0)
      expect(summed.score('c','b')).to eq(1)
      expect(summed.score('c','c')).to eq(2)
      expect(summed.score('c','')).to eq(0)
    end
  end

  describe "mean" do
    it "works" do
      matrix1 = ConfusionMatrix.new
      matrix2 = ConfusionMatrix.new

      matrix1.observe 'a', 'a'
      matrix1.observe 'a', 'a'
      matrix1.observe 'a', ''
      matrix1.observe 'b', ''
      matrix1.observe 'c', 'c'
      matrix1.observe 'c', 'b'
      matrix1.observe '', 'b'

      matrix2.observe 'a', 'a'
      matrix2.observe 'a', 'b'
      matrix2.observe 'b', 'b'
      matrix2.observe 'c', 'c'
      matrix2.observe '', 'c'

      mean = ConfusionMatrix.mean([matrix1, matrix2])

      expect(mean.score('a','a')).to eq(1.5)
      expect(mean.score('a','b')).to eq(0.5)
      expect(mean.score('a','c')).to eq(0)
      expect(mean.score('a','')).to eq(0.5)

      expect(mean.score('b','a')).to eq(0)
      expect(mean.score('b','b')).to eq(0.5)
      expect(mean.score('b','c')).to eq(0)
      expect(mean.score('b','')).to eq(0.5)

      expect(mean.score('c','a')).to eq(0)
      expect(mean.score('c','b')).to eq(0.5)
      expect(mean.score('c','c')).to eq(1)
      expect(mean.score('c','')).to eq(0)
    end
  end

  describe "loading from JSON string" do
    it 'works' do
      matrix = ConfusionMatrix.load(json)

      expect(matrix.score('a','a')).to eq(3)
      expect(matrix.score('a','b')).to eq(1)
      expect(matrix.score('a','c')).to eq(0)
      expect(matrix.score('a','')).to eq(0)

      expect(matrix.score('b','a')).to eq(2)
      expect(matrix.score('b','b')).to eq(2)
      expect(matrix.score('b','c')).to eq(0)
      expect(matrix.score('b','')).to eq(0)

      expect(matrix.score('c','a')).to eq(0)
      expect(matrix.score('c','b')).to eq(1)
      expect(matrix.score('c','c')).to eq(2)
      expect(matrix.score('c','')).to eq(2)

      expect(matrix.score('','a')).to eq(1)
      expect(matrix.score('','b')).to eq(0)
      expect(matrix.score('','c')).to eq(0)
      expect(matrix.score('','')).to eq(0)
    end
  end

  describe "dumping into a JSON string" do
    it 'works' do
      matrix = ConfusionMatrix.load(json)

      expect(ConfusionMatrix.dump(matrix)).to eq(json)
    end
  end

  describe "normalized_edit_distance" do
    it "works" do
      matrix1 = ConfusionMatrix.new

      matrix1.observe 'a', 'a'
      matrix1.observe 'a', 'a'
      matrix1.observe 'a', ''
      matrix1.observe 'b', ''
      matrix1.observe 'c', 'c'
      matrix1.observe 'c', 'b'
      matrix1.observe '', 'b'

      expect(matrix1.sum_all_errors).to eq(4)
      expect(matrix1.sum_true).to eq(7)
      expect(matrix1.normalized_edit_distance).to \
        eq(4 / 7.0)
    end
  end

  describe 'sum_errors_for' do
    it 'works for single observation' do
      expect(
        ConfusionMatrix.new({"b"=>{"a"=>1}}).sum_errors_for("a")
      ).to eq(1)
    end
  end
end
