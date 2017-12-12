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

    expect(alignment_top.join).to eq("send")
    expect(alignment_bottom.map { |c| c.nil? ? "-" : c }.join).to eq("a-nd")
  end
end
