RSpec.shared_examples "authorization on document checking route" do
  it "returns 403 forbidden when the current app isn't owning the document" do
    wrong_app_request

    expect(response.status).to eq(403)
  end
end

