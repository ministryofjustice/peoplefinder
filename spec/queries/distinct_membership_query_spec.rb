require 'rails_helper'

describe DistinctMembershipQuery do

  before(:all) do
    clean_up_indexes_and_tables
    PermittedDomain.find_or_create_by(domain: 'digital.justice.gov.uk')
    pf = create :group, name: 'Peoplefinder Team'
    cccd = create :group, name: 'CCCD'
    jk = create :person, given_name: 'Jeremy', surname: 'Katz'
    js = create :person, given_name: 'Joel', surname: 'Sugarman'
    lc = create :person, given_name: 'Liz', surname: 'Citron'
    dp = create :person, given_name: 'David', surname: 'Plews', slug: 'david-plews'

    create :membership, group_id: pf.id, person_id: jk.id, role: 'Project manager', leader: true
    create :membership, group_id: pf.id, person_id: js.id, role: 'Backend Developer', leader: false
    create :membership, group_id: pf.id, person_id: js.id, role: 'Frontend Developer', leader: false
    create :membership, group_id: pf.id, person_id: dp.id, role: 'Frontend Developer', leader: false

    create :membership, group_id: cccd.id, person_id: lc.id, role: 'Service Manager', leader: true
  end

  after(:all) do
    clean_up_indexes_and_tables
  end

  let(:group) { Group.where(name: 'Peoplefinder Team').first }

  it 'includes all the non leadership members and concatenates role names' do
    query = described_class.new(group: group, leadership: false)
    result = query.call
    expect(result.to_a.size).to eq 2

    expect(result.first.name).to eq 'David Plews'
    expect(result.first.role_names).to eq 'Frontend Developer'
    expect(result.first.slug).to eq 'david-plews'

    expect(result.last.name).to eq 'Joel Sugarman'
    expect(result.last.role_names).to eq 'Backend Developer, Frontend Developer'
  end

  it 'returns only those records with leadership status' do
    query = described_class.new(group: group, leadership: true)
    result = query.call
    expect(result.to_a.size).to eq 1
    expect(result.first.name).to eq 'Jeremy Katz'
    expect(result.first.role_names).to eq 'Project manager'
  end

  it 'returns an arel' do
    query = described_class.new(group: group, leadership: true)
    expect(query.call).to be_instance_of(Person::ActiveRecord_Relation)
  end

  it 'can be chained' do
    result = described_class.new(group: group, leadership: false).call.where(given_name: 'David')
    expect(result.to_a.size).to eq 1
    expect(result.first.name).to eq 'David Plews'
  end
end
