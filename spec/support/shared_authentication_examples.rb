RSpec.shared_examples "application authenticated route" do
  context " - without the X-App-Id" do
    it "returns status 403" do
      no_app_request

      expect(response.status).to eq(403)
    end

    it "returns the message about missing X-App-Id header" do
      no_app_request

      expect(JSON.parse(response.body)).to eq({ "error" => "Missing X-App-ID header" })
    end
  end

  context " - with the X-App-Id provided" do
    context "without the X-Token" do
      it "returns status 403" do
        no_token_request

        expect(response.status).to eq(403)
      end

      it "returns the message about the missing X-Token header" do
        no_token_request

        expect(JSON.parse(response.body)).to eq({ "error" => "Missing X-Token header" })
      end
    end

    context "with the X-Token" do
      context "when it is invalid" do
        it "returns 403" do
          invalid_token_request

          expect(response.status).to eq(403)
        end

        it "returns message about the invalid X-Token header" do
          invalid_token_request

          expect(JSON.parse(response.body)).to eq({ "error" => "Invalid X-Token header" })
        end
      end

      context "when it is valid" do
        it "returns 200 or 201 for a valid request" do
          valid_request

          expect(response.status).to be_between(200, 201).inclusive
        end
      end
    end
  end
end
