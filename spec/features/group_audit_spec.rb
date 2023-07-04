require "rails_helper"

describe "View group audit" do
  include PermittedDomainHelper
  let(:super_admin_email) { "test.user@digital.justice.gov.uk" }
  let!(:super_admin) { create(:super_admin, email: super_admin_email) }

  let(:name) { "The Kings of the Moon" }
  let(:description) { "The best group" }
  let!(:person) { create(:person) }
  let(:author) { create(:person) }
  let(:group) { create(:group) }

  let(:group_page) { Pages::Group.new }

  before do
    with_versioning do
      PaperTrail.request.whodunnit = author.id
      group.update(name:) # rubocop:disable Rails/SaveBang
      group.update(description:) # rubocop:disable Rails/SaveBang
    end
  end

  context "when an admin user" do
    before do
      token_log_in_as(super_admin.email)
    end

    it "view audit" do
      group_page.load(slug: group.slug)

      expect(group_page).to have_audit
      group_page.audit.versions.tap do |v|
        expect(v[0]).to have_text "description: #{description}"
        expect(v[1]).to have_text "name: #{name}"
      end
    end

    it "link to author of a change" do
      group_page.load(slug: group.slug)

      group_page.audit.versions.tap do |v|
        expect(v[0]).to have_link author.to_s, href: "/people/#{author.slug}"
      end
    end
  end

  context "when a regular user" do
    before do
      token_log_in_as(person.email)
    end

    it "hide audit" do
      group_page.load(slug: group.slug)
      expect(group_page).not_to have_audit
    end
  end
end
