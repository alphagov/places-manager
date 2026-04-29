require "govspeak_utils"

RSpec.describe GovspeakUtils do
  describe ".govspeak_or_string" do
    it "returns simple strings unchanged" do
      expect(described_class.govspeak_or_string("Hello")).to eq("Hello")
    end

    it "returns govspeak transformed into html" do
      expect(described_class.govspeak_or_string("#### Hi\n Hello")).to eq("<h4 id=\"hi\">Hi</h4>\n<p>Hello</p>\n")
    end

    it "returns invalid govspeak as an empty string" do
      expect(described_class.govspeak_or_string("#### Hi\n Hello\n<script>console.log()</script>")).to eq("")
    end
  end
end
