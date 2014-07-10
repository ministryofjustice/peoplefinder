require 'rails_helper'

RSpec.describe 'People Search', elastic: true do
  before(:all) do
    @alice = create(:person, given_name: 'Alice', surname: 'Andrews')
    @bob = create(:person, given_name: 'Bob', surname: 'Browning', location: 'Petty France 10th floor', description: 'weekends only')
    @digital_services = create(:group, name: 'Digital Services')
    @bob.memberships.create(group: @digital_services, role: 'Cleaner')
    Person.import
    sleep 1
  end

  after(:all) do
    clean_up_indexes_and_tables
  end

  it 'should search by surname' do
    results = search_for('Andrews')
    expect(results).to include(@alice)
    expect(results).to_not include(@bob)
  end

  it 'should search by name' do
    results = search_for('Alice')
    expect(results).to include(@alice)
    expect(results).to_not include(@bob)
  end

  it 'should search by given_name' do
    results = search_for('Bob Browning')
    expect(results).to_not include(@alice)
    expect(results).to include(@bob)
  end

  it 'should search by group name and membership role' do
    results = search_for('Cleaner at digiTAL Services')
    expect(results).to_not include(@alice)
    expect(results).to include(@bob)
  end

  it 'should search by description and location' do
    results = search_for('weekends at petty france office')
    expect(results).to_not include(@alice)
    expect(results).to include(@bob)
  end

  def search_for(query)
    Person.search(query).records
  end
end
