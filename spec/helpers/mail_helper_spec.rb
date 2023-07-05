require "rails_helper"

RSpec.describe MailHelper, type: :helper do
  # mock view path for relative translations
  before do
    @virtual_path = "path.to.view"
  end

  describe "#browser_warning" do
    subject(:warning) { browser_warning }

    it "returns expected text" do
      expect(warning).to include "Internet Explorer 6 and 7 users should copy and paste the link below into Firefox"
    end

    it "applies class for styling" do
      expect(warning).to have_selector ".browser-warning"
    end
  end

  describe "#easy_copy_link_to" do
    subject(:method) { easy_copy_link_to url: "www.example.com" }

    it "returns link" do
      expect(method).to have_link "www.example.com", href: "www.example.com"
    end

    it "wraps link with padded div to ensure easy copy and paste in email clients (including lotus notes)" do
      expect(method).to have_selector "div"
      expect(method).to have_selector('div[style*="padding: 10px 25px"]')
    end
  end

  describe "#app_guidance" do
    it "returns expected text" do
      expect(app_guidance).to include "Find out more about how to use People Finder on the"
    end

    it "includes link to intranet" do
      expect(app_guidance).to have_link "MoJ Intranet", href: "https://intranet.justice.gov.uk/peoplefinder"
    end
  end

  describe "#do_not_reply" do
    it "returns expected text" do
      expect(do_not_reply).to include "This email is automatically generated. Do not reply"
    end
  end
end
