require "rails_helper"

describe "View person audit" do
  include PermittedDomainHelper

  let(:super_admin_email) { "test.user@digital.justice.gov.uk" }
  let!(:super_admin) { create(:super_admin, email: super_admin_email) }

  let(:description)  { "The best person" }
  let(:phone_number) { "55555555555" }
  let!(:person)      { with_versioning { create(:person) } }
  let(:profile_page) { Pages::Profile.new }

  let(:profile_photo) { create(:profile_photo) }

  let(:author) { create(:person) }

  context "with modern versioning" do
    before do
      with_versioning do
        PaperTrail.request.whodunnit = author.id
        person.update(description:) # rubocop:disable Rails/SaveBang
        person.update primary_phone_number: phone_number # rubocop:disable Rails/SaveBang
        person.update profile_photo_id: profile_photo.id # rubocop:disable Rails/SaveBang
      end
    end

    context "with an admin user" do
      before do
        token_log_in_as(super_admin.email)
      end

      it "view audit" do
        profile_page.load(slug: person.slug)

        expect(profile_page).to have_audit
        profile_page.audit.versions.tap do |v|
          expect(v[0]).to have_text "profile_photo_id: #{profile_photo.id}"
          expect(v[1]).to have_text "primary_phone_number: #{phone_number}"
          expect(v[2]).to have_text "description: #{description}"
          expect(v[3]).to have_text "email: #{person.email}"
        end
      end

      it "link to author of a change" do
        profile_page.load(slug: person.slug)

        profile_page.audit.versions.tap do |v|
          expect(v[0]).to have_link author.to_s, href: "/people/#{author.slug}"
        end
      end

      it "show IP address of author of a change" do
        Version.last.update! ip_address: "1.2.3.4"
        profile_page.load(slug: person.slug)

        profile_page.audit.versions.tap do |v|
          expect(v[0]).to have_text "1.2.3.4"
        end
      end

      it "show browser used by author of a change" do
        ua = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"
        Version.last.update! user_agent: ua
        profile_page.load(slug: person.slug)

        profile_page.audit.versions.tap do |v|
          expect(v[0]).to have_text "Internet Explorer 6.0"
        end
      end
    end

    context "with a regular user" do
      before do
        token_log_in_as(person.email)
      end

      it "hide audit" do
        profile_page.load(slug: person.slug)
        expect(profile_page).not_to have_audit
      end
    end
  end

  context "with legacy versioning as an admin" do
    before do
      with_versioning do
        PaperTrail.request.whodunnit = "Michael Mouse"
        person.update! description:
      end

      token_log_in_as(super_admin.email)
    end

    it "show text for change author" do
      profile_page.load(slug: person.slug)

      expect(profile_page).to have_audit
      profile_page.audit.versions.tap do |v|
        expect(v[0]).to have_text "Michael Mouse"
      end
    end
  end
end
