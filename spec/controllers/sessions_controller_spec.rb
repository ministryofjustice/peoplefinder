require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'concerns', 'session_person_creator_spec.rb')

RSpec.describe SessionsController, type: :controller do
  include PermittedDomainHelper
  it_behaves_like 'session_person_creatable'
end
