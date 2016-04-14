require 'rails_helper'

feature 'View group audit' do
  include PermittedDomainHelper
  let(:super_admin_email) { 'test.user@digital.justice.gov.uk' }
  let!(:super_admin) { create(:super_admin, email: super_admin_email) }

  let(:name) { 'The Kings of the Moon' }
  let(:description) { 'The best group' }
  let!(:person) { create(:person) }
  let(:author) { create(:person) }
  let(:group) { create(:group) }

  let(:group_page) { Pages::Group.new }

  before do
    with_versioning do
      PaperTrail.whodunnit = author.id
      group.update name: name
      group.update description: description
    end
  end

  context 'as an admin user' do
    before do
      omni_auth_log_in_as(super_admin.email)
    end

    scenario 'view audit' do
      group_page.load(slug: group.slug)

      expect(group_page).to have_audit
      group_page.audit.versions.tap do |v|
        expect(v[0]).to have_text "description: #{description}"
        expect(v[1]).to have_text "name: #{name}"
      end
    end

    scenario 'link to author of a change' do
      group_page.load(slug: group.slug)

      group_page.audit.versions.tap do |v|
        expect(v[0]).to have_link author.to_s, href: "/people/#{author.slug}"
      end
    end
  end

  context 'as a regular user' do
    before do
      omni_auth_log_in_as(person.email)
    end

    scenario 'hide audit' do
      group_page.load(slug: group.slug)
      expect(group_page).not_to have_audit
    end
  end
end
