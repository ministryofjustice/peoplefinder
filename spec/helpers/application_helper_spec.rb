require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  let(:stubbed_time) { Time.new(2012, 10, 31, 2, 2, 2, "+01:00") }
  let(:originator) { Version.public_user }

  describe "#pluralize_with_delimiter" do
    it "handles singular correctly" do
      expect(pluralize_with_delimiter(1, "person")).to eq "1 person"
    end

    it "handles plural correctly" do
      expect(pluralize_with_delimiter(2000, "person")).to eq "2,000 people"
    end
  end

  describe "#govspeak" do
    it "renders Markdown starting from h3" do
      source = "# Header\n\nPara para"
      fragment = Capybara::Node::Simple.new(govspeak(source))

      expect(fragment).to have_selector("h3", text: "Header")
    end
  end

  describe "#bold_tag" do
    subject(:tag) { bold_tag("bold text", options) }

    let(:options) { {} }

    it "applies span around the term" do
      expect(tag).to have_selector("span", text: "bold text")
    end

    it "applies bold-term class to span around the term" do
      expect(tag).to have_selector("span.bold-term", text: "bold text")
    end

    it "appends bold-term to other classes passed in" do
      options[:class] = "my-other-class"
      expect(tag).to include("bold-term", "my-other-class")
    end
  end

  describe "#call_to" do
    it "returns an a with a tel: href" do
      generated = call_to("07700900123")
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="tel:07700900123"]', text: "07700900123")
    end

    it "strips extraneous characters from href" do
      generated = call_to("07700 900 123")
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="tel:07700900123"]')
    end

    it "preserves significant non-numeric characters in href" do
      generated = call_to("+447700900123,,1234#*")
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="tel:+447700900123,,1234#*"]')
    end

    it "returns nil if telephone number is nil" do
      expect(call_to(nil)).to be_nil
    end
  end

  describe "#role_translate" do
    let(:current_user) { build(:person) }

    it 'uses the "mine" translation when the user is the current user' do
      allow(I18n).to receive(:t)
        .with("foo.bar.mine", hash_including(name: current_user))
        .and_return("translation")
      expect(role_translate(current_user, "foo.bar")).to eq("translation")
    end

    it 'uses the "other" translation when the user is not the current user' do
      allow(I18n).to receive(:t)
        .with("foo.bar.other", hash_including(name: current_user))
        .and_return("translation")
      expect(role_translate(build(:person), "foo.bar")).to eq("translation")
    end
  end
end
