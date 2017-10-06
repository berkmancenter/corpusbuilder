RSpec.shared_examples "editor requiring route" do
  context "with the X-Editor-Id" do
    context "when it doesn't exist in the database" do
      it "returns status 403" do
        inexistant_editor_request

        expect(response.status).to eq(403)
      end
    end

    context "when it is valid" do
      it "returns 200 or 201" do
        valid_editor_request

        expect(response.status).to be_between(200, 201).inclusive
      end
    end
  end

  context "without the X-Editor-Id" do
    it "returns status 403" do
      no_editor_request

      expect(response.status).to eq(403)
    end
  end
end
