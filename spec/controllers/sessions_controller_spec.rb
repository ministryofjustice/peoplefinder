require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'concerns', 'shared_examples_for_session_person_creator.rb')

RSpec.describe SessionsController, type: :controller do
  include PermittedDomainHelper
  it_behaves_like 'session_person_creatable'
end
