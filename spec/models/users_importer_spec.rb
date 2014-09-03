require 'rails_helper'

RSpec.describe UsersImporter, type: :model do

  it 'creates a user for each name and email address' do
    csv = <<END
Alice,alice@example.com,
Bob,bob@example.com,
Charlie,charlie@example.com,
END

    importer = described_class.new(StringIO.new(csv))
    importer.import

    alice = User.where(email: 'alice@example.com').first
    bob = User.where(email: 'bob@example.com').first
    charlie = User.where(email: 'charlie@example.com').first

    expect(alice.name).to eql('Alice')
    expect(bob.name).to eql('Bob')
    expect(charlie.name).to eql('Charlie')
  end

  it 'creates management relationships based on manager email' do
    csv = <<END
Alice,alice@example.com,
Bob,bob@example.com,alice@example.com
Charlie,charlie@example.com,bob@example.com
END

    importer = described_class.new(StringIO.new(csv))
    importer.import

    alice = User.where(email: 'alice@example.com').first
    bob = User.where(email: 'bob@example.com').first
    charlie = User.where(email: 'charlie@example.com').first

    expect(alice.manager).to be_nil
    expect(bob.manager).to eql(alice)
    expect(charlie.manager).to eql(bob)
  end

  it 'is order-independent' do
    csv = <<END
Bob,bob@example.com,alice@example.com
Alice,alice@example.com,
END

    importer = described_class.new(StringIO.new(csv))
    importer.import

    alice = User.where(email: 'alice@example.com').first
    bob = User.where(email: 'bob@example.com').first

    expect(bob.manager).to eql(alice)
  end

  it 'uses a transaction so that nothing is created in the even of an error' do
    csv = <<END
Alice,alice@example.com,
Bob,bob@example.com,alice@example.com
Bob,junk!!!!!,alice@example.com
END

    importer = described_class.new(StringIO.new(csv))

    expect {
      importer.import
    }.not_to change(User, :count)
  end
end
