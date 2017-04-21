require 'rails_helper'

feature 'Home page' do
  include PermittedDomainHelper

  let(:home_page) { Pages::Home.new }
  let(:unsupported_browser_page) { Pages::UnsupportedBrowser.new }
  let(:ff31) { 'Mozilla/5.0 (Windows NT 5.2; rv:31.0) Gecko/20100101 Firefox/31.0' }
  let(:ie7) { 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.2; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022)' }
  let(:ie6) { 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022)' }

  before do
    create(:department)
  end

  context 'page structure' do
    let(:user_agent) { ff31 }
    before do
      #unstub method to allow user-agent emulation
      allow_any_instance_of(HomeController).to receive(:supported_browser?).and_call_original
      page.driver.headers = { "User-Agent" => user_agent }
      mock_readonly_user
      visit '/'
    end

    context 'using a supported browser', js: true do
      it 'is all there' do
        expect(home_page).to be_displayed
        expect(home_page).to have_page_title
        expect(home_page).to have_search_form
        expect(home_page.page_title).to have_text('Welcome to People Finder')
      end

      it 'displays no warning' do
        expect(home_page).to be_displayed
        expect(home_page).to_not have_unsupported_browser_warning
      end
    end

    context 'using an unsupported browser', js: true do
      let(:user_agent) { ie6 }

      it 'redirects to unsupported browser landing page' do
        expect(unsupported_browser_page).to be_displayed
        expect(unsupported_browser_page).to have_unsupported_browser_continue_link
      end

      context 'but choosing to continue' do
        it 'redirects back to home page but displays a warning' do
          expect(unsupported_browser_page).to be_displayed
          unsupported_browser_page.unsupported_browser_continue_link.click
          expect(home_page).to be_displayed
          expect(home_page).to have_unsupported_browser_warning
        end
      end
    end
  end

  context 'for a regular user' do
    before do
      omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
      visit '/'
    end

    scenario 'can view the page' do
      expect(home_page).to be_displayed
    end
  end

  context 'for a readonly user' do
    before do
      mock_readonly_user
      visit '/'
    end

    scenario 'can view the page' do
      expect(home_page).to be_displayed
    end
  end

end
