require "rails_helper"

RSpec.describe Concerns::Acquisition do
  include PermittedDomainHelper

  describe ".acquired_percentage" do
    it "returns 0 when no profiles" do
      expect(Person.acquired_percentage).to eq(0)
    end

    it "returns 0 when one person who has not logged in" do
      create(:person, login_count: 0)
      expect(Person.acquired_percentage).to eq(0)
    end

    it "returns 100 when one person who has logged in" do
      create(:person, login_count: 1)
      expect(Person.acquired_percentage).to eq(100)
    end

    it "returns 50 if two people, one who has logged in, one who has not" do
      create(:person, login_count: 1)
      create(:person, login_count: 0)
      expect(Person.acquired_percentage).to eq(50)
    end

    it "returns 67 when 3 people, two who have logged in, one who has not" do
      create(:person, login_count: 1)
      create(:person, login_count: 1)
      create(:person, login_count: 0)
      expect(Person.acquired_percentage).to eq(67)
    end

    context "when one person created yesterday who has logged in" do
      let(:yesterday) { Time.zone.today - 1.day }

      before do
        create(:person, login_count: 1, created_at: yesterday)
      end

      it "returns 0 when from date is today" do
        expect(Person.acquired_percentage(from: Time.zone.today.to_s)).to eq(0)
      end

      it "returns 100 when from date is yesterday" do
        expect(Person.acquired_percentage(from: yesterday.to_s)).to eq(100)
      end

      it "returns 0 when before date is yesterday" do
        expect(Person.acquired_percentage(before: yesterday.to_s)).to eq(0)
      end

      it "returns 100 when before date is today" do
        expect(Person.acquired_percentage(before: Time.zone.today.to_s)).to eq(100)
      end
    end
  end
end
