require 'rails_helper'

feature 'Navigating between sections of the site' do
  context 'As a middle-ranking person' do
    let(:me) { create(:user, name: "Bob", manager: create(:user)) }
    let!(:direct_report) { create(:user, name: "Charlie", manager: me) }
    let(:token) { me.tokens.create }

    scenario 'Visiting dashboard with no reviews' do
      # /reviews

      visit token_url(token)

      expect_no_back_link
      expect_page_header 'SCS 360° Appraisals'
      expect_tabs
      expect_page_subheader 'Feedback participants'
    end

    scenario 'Visiting dashboard with reviews' do
      # /reviews

      create :review, subject: me
      visit token_url(token)

      expect_no_back_link
      expect_page_header 'SCS 360° Appraisals'
      expect_tabs
      expect_page_subheader 'Feedback received'
    end

    scenario 'Viewing a review I have received' do
      # /reviews/[n]

      create :submitted_review, subject: me, author_name: 'Momotaro'
      visit token_url(token)
      click_link 'View feedback'

      expect_back_link '/reviews'
      expect_page_header 'Feedback for you'
      expect_no_tabs
      expect_page_subheader 'Given by Momotaro'
    end

    scenario 'Visiting dashboard for direct reports' do
      # /users

      visit token_url(token)
      click_link 'Your direct reports'

      expect_no_back_link
      expect_page_header 'SCS 360° Appraisals'
      expect_tabs
      expect_page_subheader 'Your direct reports'
    end

    scenario 'Viewing direct report with no reviews' do
      # /users/[n]/reviews

      visit token_url(token)
      click_link 'Your direct reports'
      click_link 'Charlie'

      expect_back_link '/users'
      expect_page_header 'Feedback for Charlie'
      expect_no_tabs
      expect_page_subheader 'Feedback participants'
    end

    scenario 'Viewing direct report with reviews' do
      # /users/[n]/reviews

      create :submitted_review, subject: direct_report, author_name: 'Momotaro'
      visit token_url(token)
      click_link 'Your direct reports'
      click_link 'Charlie'

      expect_back_link '/users'
      expect_page_header 'Feedback for Charlie'
      expect_no_tabs
      expect_page_subheader 'Feedback received'
    end

    scenario 'Viewing a review a direct report has received' do
      # /users/[n]/reviews/[m]

      create :submitted_review, subject: direct_report, author_name: 'Momotaro'
      visit token_url(token)
      click_link 'Your direct reports'
      click_link 'Charlie'
      click_link 'View feedback'

      expect_back_link '/users'
      expect_back_link "/users/#{direct_report.to_param}/reviews"
      expect_page_header 'Feedback for Charlie'
      expect_no_tabs
      expect_page_subheader 'Given by Momotaro'
    end

    scenario 'Viewing my feedback requests' do
      # /replies

      create :review, author_email: me.email
      visit token_url(token)
      click_link 'Feedback requests'

      expect_no_back_link
      expect_page_header 'SCS 360° Appraisals'
      expect_tabs
      expect_page_subheader 'Requests for feedback'
    end

    scenario 'Submitting feedback' do
      # /submissions/[n]/edit

      create :accepted_review,
        author_email: me.email,
        subject: direct_report
      visit token_url(token)
      click_link 'Feedback requests'
      click_link 'Add feedback'

      expect_back_link '/replies'
      expect_page_header 'Feedback for Charlie'
      expect_no_tabs
    end

    scenario 'Viewing feedback I gave' do
      # /reviews/[n]

      create :submitted_review,
        author_email: me.email,
        subject: direct_report
      visit token_url(token)
      click_link 'Feedback requests'
      click_link 'View feedback'

      expect_back_link '/replies'
      expect_page_header 'Feedback for Charlie'
      expect_no_tabs
      expect_page_subheader 'Given by you'
    end

    context 'After the end of the review period' do
      scenario 'Viewing reviews I have received', closed_review_period: true do
        # /results/reviews

        create :submitted_review, subject: me, author_name: 'Momotaro'
        visit token_url(token)

        expect_no_back_link
        expect_page_header 'SCS 360° Appraisals'
        expect_tabs
        expect_page_subheader 'All your feedback'
      end

      scenario 'Visiting dashboard for direct reports', closed_review_period: true do
        # /results/users

        visit token_url(token)
        click_link 'Your direct reports'

        expect_no_back_link
        expect_page_header 'SCS 360° Appraisals'
        expect_tabs
        expect_page_subheader 'Feedback for your direct reports'
      end

      scenario 'Viewing reviews for a direct report', closed_review_period: true do
        # /results/users/[n]/reviews

        create :submitted_review, subject: direct_report, author_name: 'Momotaro'
        visit token_url(token)
        click_link 'Your direct reports'
        click_link 'Charlie'

        expect_back_link '/results/users'
        expect_page_header 'All feedback for Charlie'
        expect_no_tabs
      end
    end
  end

  def expect_back_link(path)
    expect(page).to have_css(".top-left a[href$='#{path}']")
  end

  def expect_no_back_link
    expect(page).not_to have_css(".top-left a")
  end

  def expect_page_header(text)
    expect(page).to have_selector('h1', text: text)
  end

  def expect_page_subheader(text)
    expect(page).to have_selector('h2', text: text)
  end

  def expect_tabs
    expect(page).to have_selector('ul#tab_navigation li a')
  end

  def expect_no_tabs
    expect(page).not_to have_selector('ul#tab_navigation')
  end
end
