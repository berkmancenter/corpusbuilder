require 'rails_helper'

describe Shared::NeedlemanWunsch do
  it "returns the result as in examples references in the algorithm description" do
    alignment_top, alignment_bottom = Shared::NeedlemanWunsch.run!(
      from: "send".chars,
      to: "and".chars,
      gap_penalty: -10,
      score_fn: -> (left, right) {
        left == right ? 1 : -1
      }
    ).result

    expect(alignment_top.map { |c| c.nil? ? "-" : c }.join).to eq("send")
    expect(alignment_bottom.map { |c| c.nil? ? "-" : c }.join).to eq("-and")
  end

  it "returns the result as in wikipedia example" do
    alignment_top, alignment_bottom = Shared::NeedlemanWunsch.run!(
      from: "GCATGCU".chars,
      to: "GATTACA".chars,
      gap_penalty: -1,
      score_fn: -> (left, right) {
        left == right ? 1 : -1
      }
    ).result

    expect(alignment_top.map { |c| c.nil? ? "-" : c }.join).to eq("GCA-TGCU")
    expect(alignment_bottom.map { |c| c.nil? ? "-" : c }.join).to eq("G-ATTACA")
  end
end
