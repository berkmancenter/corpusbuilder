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

  describe "merge" do
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

      matrix1.observe 'a', 'a'
      matrix1.observe 'a', 'b'
      matrix1.observe 'b', 'b'
      matrix1.observe 'c', 'c'
      matrix1.observe '', 'c'

      summed = ConfusionMatrix.merge([matrix1, matrix2])

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

  describe 'sum_errors_for' do
    it 'works for single observation' do
      expect(
        ConfusionMatrix.new({"b"=>{"a"=>1}}).sum_errors_for("a")
      ).to eq(1)
    end
  end
end
