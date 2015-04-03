require 'rails_helper'

feature 'View person audit' do
  let(:super_admin_email)  { 'test.user@digital.justice.gov.uk' }
  let!(:super_admin)  { create(:super_admin, email: super_admin_email) }

  let(:description)  { 'The best person' }
  let(:phone_number) { '55555555555' }
  let!(:person)      { with_versioning { create(:person) } }
  let(:profile_page) { Pages::Profile.new }

  let(:sample_image) {
    File.open(File.join(Engine.root, 'spec', 'fixtures', 'placeholder.png'))
  }

  let(:author) { create(:person) }

  context 'modern versioning' do
    before do
      with_versioning do
        PaperTrail.whodunnit = author.id
        person.update description: description
        person.update primary_phone_number: phone_number
        person.update image: sample_image
      end
    end

    context 'as an admin user' do
      before do
        omni_auth_log_in_as(super_admin.email)
      end

      scenario 'view audit' do
        profile_page.load(slug: person.slug)

        expect(profile_page).to have_audit
        profile_page.audit.versions.tap do |v|
          expect(v[0]).to have_text "image => placeholder.png"
          expect(v[1]).to have_text "primary_phone_number => #{phone_number}"
          expect(v[2]).to have_text "description => #{description}"
          expect(v[3]).to have_text "email => #{person.email}"
        end
      end

      scenario 'link to author of a change' do
        profile_page.load(slug: person.slug)

        profile_page.audit.versions.tap do |v|
          expect(v[0]).to have_link author.to_s, href: "/people/#{author.slug}"
        end
      end

      scenario 'show IP address of author of a change' do
        Version.last.update ip_address: '1.2.3.4'
        profile_page.load(slug: person.slug)

        profile_page.audit.versions.tap do |v|
          expect(v[0]).to have_text '1.2.3.4'
        end
      end

      scenario 'show browser used by author of a change' do
        ua = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'
        Version.last.update user_agent: ua
        profile_page.load(slug: person.slug)

        profile_page.audit.versions.tap do |v|
          expect(v[0]).to have_text 'Internet Explorer 6.0'
        end
      end
    end

    context 'as a regular user' do
      before do
        omni_auth_log_in_as(person.email)
      end

      scenario 'hide audit' do
        profile_page.load(slug: person.slug)
        expect(profile_page).not_to have_audit
      end
    end
  end

  context 'legacy versioning as an admin' do
    before do
      with_versioning do
        PaperTrail.whodunnit = 'Michael Mouse'
        person.update description: description
      end

      omni_auth_log_in_as(super_admin.email)
    end

    scenario 'show text for change author' do
      profile_page.load(slug: person.slug)

      expect(profile_page).to have_audit
      profile_page.audit.versions.tap do |v|
        expect(v[0]).to have_text 'Michael Mouse'
      end
    end
  end
end
