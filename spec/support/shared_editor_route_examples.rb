RSpec.shared_examples "editor requiring route" do
  it "returns 400 when editor is not given" do
    no_editor_request

    expect(response.status).to eq(400)
    expect(JSON.parse(response.body)["editor_id"]).to include("is missing")
  end

  pending "when given editor that doesn't seem to exist - asks the network for her/him"
  pending "when the editor doesn't exist in the network - returns 401"
end

