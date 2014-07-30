require 'rails_helper'

feature "Editing objectives" do
  before do
    given_i_have_an_account
    and_i_am_logged_in
    and_i_have_an_agreement_as_a_staff_member
  end

  scenario "Seeing my objectives", js: true do
    given_the_agreement_has_some_objectives
    when_i_visit_the_page_for_the_agreement_objectives
    then_i_should_see_the_objectives
  end

  scenario "Adding objectives", js: true do
    when_i_visit_the_page_for_the_agreement_objectives
    and_i_fill_in_an_objective
    and_i_add_another_objective
    and_i_fill_in_an_objective
    and_i_click 'Save'
    then_the_agreement_should_have_the_objectives
  end

  def given_the_agreement_has_some_objectives
    state[:objectives] = 2.times.map {
      create(:objective, agreement: state[:agreement])
    }
  end

  def when_i_visit_the_page_for_the_agreement_objectives
    visit '/'
    click_button 'Objectives'
  end

  def and_i_fill_in_an_objective
    unless state.has_key?(:objective_attributes)
      state[:objective_attributes] = []
    end

    attrs = attributes_for(:objective)
    state[:objective_attributes] << attrs

    within('#objectives .fields:last-child') do
      fill_in 'Type', with: attrs[:objective_type]
      fill_in 'Objective', with: attrs[:description]
      fill_in 'Deliverable', with: attrs[:deliverables]
      fill_in 'Measures / Target', with: attrs[:measurements]
    end
  end

  def and_i_add_another_objective
    click_link 'Add more'
  end

  def then_i_should_see_the_objectives
    expect(page).to have_text("#{state[:me]}’s objectives")
    state[:objectives].each do |objective|
      expect(page).to have_css('textarea', text: objective.objective_type)
      expect(page).to have_css('textarea', text: objective.description)
      expect(page).to have_css('textarea', text: objective.deliverables)
      expect(page).to have_css('textarea', text: objective.measurements)
    end
  end

  def then_the_agreement_should_have_the_objectives
    objectives = state[:agreement].reload.objectives.sort_by(&:id)
    state[:objective_attributes].zip(objectives).each do |attrs, objective|
      expect(objective.objective_type).to eql(attrs[:objective_type])
      expect(objective.description).to eql(attrs[:description])
      expect(objective.deliverables).to eql(attrs[:deliverables])
      expect(objective.measurements).to eql(attrs[:measurements])
    end
  end
end
