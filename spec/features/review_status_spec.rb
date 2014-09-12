require 'rails_helper'

feature 'Review status' do
  let(:me) { create(:user, manager: create(:user)) }

  before do
    token = create(:token, user: me)
    visit token_path(token)
  end

  scenario 'viewing the status of my feedback' do
    create :review,
      subject: me, author_name: 'Foxtrot', status: :no_response,
      relationship: :peer
    create :review,
      subject: me, author_name: 'Golf', status: :started,
      relationship: :supplier
    create :review,
      subject: me, author_name: 'Hotel', status: :submitted,
      relationship: :customer

    visit reviews_path

    expect(page).to have_text('Foxtrot Peer Pending')
    expect(page).to have_text('Golf Supplier Started')
    expect(page).to have_text('Hotel Customer/stakeholder Completed')
  end

  scenario "viewing the status of my managees' feedback" do
    managee = create(:user, name: 'Joe Worker', manager: me)

    create :review,
      subject: managee, author_name: 'Foxtrot', status: :no_response,
      relationship: :peer
    create :review,
      subject: managee, author_name: 'Golf', status: :started,
      relationship: :supplier
    create :review,
      subject: managee, author_name: 'Hotel', status: :submitted,
      relationship: :customer

    visit users_path
    click_link managee.name

    expect(page).to have_text('Foxtrot Peer Pending')
    expect(page).to have_text('Golf Supplier Started')
    expect(page).to have_text('Hotel Customer/stakeholder Completed')
  end
end
