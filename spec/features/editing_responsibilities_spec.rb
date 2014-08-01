require 'rails_helper'

feature "Editing responsibilities" do
  before do
    given_i_have_an_account
    and_i_am_logged_in
    and_i_have_an_agreement_as_a_staff_member
  end

  scenario "Seeing my responsibilities", js: true do
    given_the_agreement_has_some_responsibilities
    when_i_visit_the_page_for_the_agreement_responsibilities
    then_i_should_see_the_responsibilities
  end

  scenario "Adding responsibilities", js: true do
    when_i_visit_the_page_for_the_agreement_responsibilities
    and_i_fill_in_a_responsibility
    and_i_add_another_responsibility
    and_i_fill_in_a_responsibility
    and_i_click 'Save'
    then_the_agreement_should_have_the_responsibilities
  end

  def given_the_agreement_has_some_responsibilities
    state[:responsibilities] = 2.times.map {
      create(:budgetary_responsibility, agreement: state[:agreement])
    }
  end

  def when_i_visit_the_page_for_the_agreement_responsibilities
    visit "/"
    click_button "Responsibilities"
  end

  def and_i_fill_in_a_responsibility
    unless state.key?(:responsibility_attributes)
      state[:responsibility_attributes] = []
    end
    attrs = attributes_for(:budgetary_responsibility)
    state[:responsibility_attributes] << attrs

    within('#budgetary-responsibilities .fields:last-child') do
      fill_in "Type", with: attrs[:budget_type]
      fill_in "Value", with: attrs[:value]
      fill_in "Description", with: attrs[:description]
    end
  end

  def and_i_add_another_responsibility
    click_link 'Add more'
  end

  def then_i_should_see_the_responsibilities
    expect(page).to have_text("#{state[:me]}’s responsibilities")
    state[:responsibilities].each do |responsibility|
      expect(page).to have_field('Type', with: responsibility.budget_type)
      expect(page).to have_field('Value', with: responsibility.value)
      expect(page).to have_css('textarea', text: responsibility.description)
    end
  end

  def then_the_agreement_should_have_the_responsibilities
    responsibilities = state[:agreement].reload.budgetary_responsibilities.sort_by(&:id)
    state[:responsibility_attributes].zip(responsibilities).each do |attrs, responsibility|
      expect(responsibility.budget_type).to eql(attrs[:budget_type])
      expect(responsibility.value).to eql(attrs[:value])
      expect(responsibility.description).to eql(attrs[:description])
    end
  end
end
