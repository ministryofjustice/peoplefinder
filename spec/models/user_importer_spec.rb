require 'rails_helper'

RSpec.describe UserImporter, type: :model do

  it 'creates a user for each name and email address' do
    csv = <<END
name,email,job_title,manager_email
Alice,alice@example.com,Permanent Secretary,
Bob,bob@example.com,Director General,
Charlie,charlie@example.com,Director,
END

    importer = described_class.new(StringIO.new(csv))
    importer.import

    alice = User.where(email: 'alice@example.com').first
    bob = User.where(email: 'bob@example.com').first
    charlie = User.where(email: 'charlie@example.com').first

    expect(alice.name).to eql('Alice')
    expect(bob.name).to eql('Bob')
    expect(charlie.name).to eql('Charlie')

    expect(alice.job_title).to eql('Permanent Secretary')
    expect(bob.job_title).to eql('Director General')
    expect(charlie.job_title).to eql('Director')

    expect(alice).to be_participant
    expect(User.participants.map(&:name).sort).to eql(%w[Alice Bob Charlie])
  end

  it 'creates management relationships based on manager email' do
    csv = <<END
name,email,job_title,manager_email
Alice,alice@example.com,,
Bob,bob@example.com,,alice@example.com
Charlie,charlie@example.com,,bob@example.com
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
name,email,job_title,manager_email
Bob,bob@example.com,,alice@example.com
Alice,alice@example.com,,
END

    importer = described_class.new(StringIO.new(csv))
    importer.import

    alice = User.where(email: 'alice@example.com').first
    bob = User.where(email: 'bob@example.com').first

    expect(bob.manager).to eql(alice)
  end

  it 'uses a transaction so that nothing is created in the even of an error' do
    csv = <<END
name,email,job_title,manager_email
Alice,alice@example.com,,
Bob,bob@example.com,,alice@example.com
Bob,junk!!!!!,,alice@example.com
END

    importer = described_class.new(StringIO.new(csv))

    expect {
      importer.import
    }.not_to change(User, :count)
  end

  it 'updates existing users' do
    bob = create(:user, email: 'bob@example.com', name: 'Robert')
    csv = <<END
name,email,job_title,manager_email
Alice,alice@example.com,Permanent Secretary,
Bob,bob@example.com,Director General,alice@example.com
END

    importer = described_class.new(StringIO.new(csv))
    importer.import

    alice = User.where(email: 'alice@example.com').first

    expect(User.where(email: 'bob@example.com').count).to eql(1)

    bob.reload
    expect(bob.name).to eql('Bob')
    expect(bob.manager).to eql(alice)
    expect(bob.job_title).to eql('Director General')
  end

  it 'normalises email case' do
    csv = <<END
name,email,job_title,manager_email
Alice,ALICE@EXAMPLE.COM,,
Bob,Bob@example.com,,Alice@example.com
END

    importer = described_class.new(StringIO.new(csv))
    importer.import

    alice = User.where(email: 'alice@example.com').first
    bob = User.where(email: 'bob@example.com').first

    expect(alice).not_to be_nil
    expect(bob).not_to be_nil
    expect(bob.manager).to eql(alice)
  end
end
