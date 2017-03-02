require 'rails_helper'

describe ProfileChangeAggregator do

  describe '#aggregate_raw_changes' do
    context 'just one record in the group' do
      it 'produces raw changes identical to the one record in the group' do
        agg = described_class.new([qn1])
        expect(agg.aggregate_raw_changes).to eq qn1.changes_hash['data']['raw']
      end
    end

    context 'two records changing different fields' do
      it 'produces raw changes that are merged from the two records' do
        agg = described_class.new([qn1, qn2])
        expect(agg.aggregate_raw_changes).to eq merged_qn1_qn2_changes
      end

      def merged_qn1_qn2_changes
        {
          'primary_phone_number' => ['999', '020 27835 2232'],
          'description' => ['', 'All animals are equal, but some are more equal than others'],
          'works_tuesday' => [true, false],
          'works_thursday' => [true, false],
          'secondary_phone_number' => ['', '0759 049 3001'],
          'slug' => ['sr2', 'stephen-richards']
        }
      end
    end

    context 'three records changing the same fields' do
      it 'produces raw changes that reflect the first value and the last value when the same field is updated serveral times' do
        agg = described_class.new([qn1, qn2, qn3])
        expect(agg.aggregate_raw_changes).to eq merged_qn1_qn2_qn3_changes
      end

      def merged_qn1_qn2_qn3_changes
        {
          'primary_phone_number' => ['999', '0734 52516'],
          'location_in_building' => ['', '10.51'],
          'description' => ['', 'All animals are equal'],
          'works_tuesday' => [true, false],
          'works_thursday' => [true, false],
          'secondary_phone_number' => ['', '0777 15 16 568'],
          'slug' => ['sr2', 'philip-stephen-richards']
        }
      end
    end

    context 'two records that change the value of one field back to the original' do
      it 'removes the fields that were changed back to the original value' do
        agg = described_class.new([qn1, qn4])
        expect(agg.aggregate_raw_changes).to eq merged_qn1_qn4_changes
      end

      def merged_qn1_qn4_changes
        {
          'description' => ['', 'All animals are equal-ish'],
          'works_thursday' => [true, false]
        }
      end
    end

    context 'changes to meberships' do
      context 'just one change' do
        it 'produces the same change set' do
          agg = described_class.new([mqn1])
          expect(agg.aggregate_raw_changes).to eq mqn1.changes_hash['data']['raw']
        end
      end

      context 'two changes for two different memberships' do
        it 'merges the two changes sets' do
          agg = described_class.new([mqn1, mqn2])
          expect(agg.aggregate_raw_changes).to eq merged_mqn1_mqn2_changes
        end

        def merged_mqn1_mqn2_changes
          {
            'primary_phone_number' => ['020 27835 2232', '07159 048 3001'],
            'membership_6' => {
              'role' => ['This is a new role in a new group', 'This is a editted role in a new group'],
              'leader' => [false, true],
              'subscribed' => [false, true]
            },
            'membership_2055' => {
              'role' => ['Software Developer', 'Backend Developer'],
              'leader' => [false, true],
              'subscribed' => [false, true]
            }
          }
        end
      end

      context 'multiple changes for the same membership' do
        it 'does a deep merge on the changes for each membership' do
          agg = described_class.new([mqn1, mqn2, mqn3])
          expect(agg.aggregate_raw_changes).to eq merged_mqn1_mqn2_mqn3_changes
        end

        def merged_mqn1_mqn2_mqn3_changes
          {
            'primary_phone_number' => ['020 27835 2232', '999'],
            'membership_6' => {
              'role' => ['This is a new role in a new group', 'Superhero'],
              'leader' => [false, true],
              'subscribed' => [false, true]
            },
            'membership_2055' => {
              'role' => ['Software Developer', 'Senior Software Developer'],
              'leader' => [false, true],
              'subscribed' => [false, true]
            }
          }
        end
      end
    end

    def qn1
      build :queued_notification, changes_json: {
        'json_class'=>'ProfileChangesPresenter',
        'data'=> {
          'raw'=> {
            'primary_phone_number' => ['999', '020 27835 2232'],
            'description' => ['', 'All animals are equal, but some are more equal than others'],
            'works_tuesday' => [true, false],
            'works_thursday' => [true, false]
          }
        }
      }.to_json
    end

    def qn2
      build :queued_notification, changes_json: {
        'json_class'=>'ProfileChangesPresenter',
        'data'=> {
          'raw'=> {
            'secondary_phone_number' => ['', '0759 049 3001'],
            'slug' => ['sr2', 'stephen-richards']
          }
        }
      }.to_json
    end

    def qn3
      build :queued_notification, changes_json: {
        'json_class'=>'ProfileChangesPresenter',
        'data'=> {
          'raw'=> {
            'primary_phone_number' => ['020 27835 2232', '0734 52516'],
            'description' => ['', 'All animals are equal'],
            'secondary_phone_number' => ['759 049 3001', '0777 15 16 568'],
            'location_in_building' => ['', '10.51'],
            'slug' => ['stephen-richards', 'philip-stephen-richards'],
            'works_tuesday' => [true, false],
            'works_thursday' => [true, false]
          }
        }
      }.to_json
    end

    def qn4
      build :queued_notification, changes_json: {
        'json_class'=>'ProfileChangesPresenter',
        'data'=> {
          'raw'=> {
            'primary_phone_number' => ['020 27835 2232', '999'],
            'description' => ['', 'All animals are equal-ish'],
            'works_tuesday' => [false, true],
            'works_thursday' => [true, false]
          }
        }
      }.to_json
    end

    def mqn1
      build :queued_notification, changes_json: {
        'json_class'=>'ProfileChangesPresenter',
        'data'=> {
          'raw'=> {
            'primary_phone_number' => ['020 27835 2232', '07159 048 3001'],
            'membership_6' => {
              'role' => ['This is a new role in a new group', 'This is a editted role in a new group'],
              'leader' => [false, true],
              'subscribed' => [false, true]
            }
          }
        }
      }.to_json
    end

    def mqn2
      build :queued_notification, changes_json: {
        'json_class'=>'ProfileChangesPresenter',
        'data'=> {
          'raw'=> {
            'membership_2055' => {
              'role' => ['Software Developer', 'Backend Developer'],
              'leader' => [false, true],
              'subscribed' => [false, true]
            }
          }
        }
      }.to_json
    end

    def mqn3
      build :queued_notification, changes_json: {
        'json_class'=>'ProfileChangesPresenter',
        'data'=> {
          'raw'=> {
            'primary_phone_number' => ['07159 048 3001', '999'],
            'membership_2055' => {
              'role' => ['Backend Developer', 'Senior Software Developer'],
              'leader' => [false, true],
              'subscribed' => [false, true]
            },
            'membership_6' => {
              'role' => ['This is a editted role in a new group', 'Superhero'],
              'leader' => [false, true],
              'subscribed' => [false, true]
            }
          }
        }
      }.to_json
    end
  end

  describe 'private method eliminate_noops' do

    let(:aggregator) { described_class.new([]) }

    it 'eliminates noops at the top level' do
      changes = {
        'surname'=>['Bonstart', 'Bonstart-Smythe'],
        'primary_phone_number'=>['020 7835 2232', '020 7835 2232'],
        'alternative_phone_number'=>['', ''],
        'email'=>['step.bonstart@digital.justice.gov.uk', 'step.bonstart-smythe@digital.justice.gov.uk'],
        'description'=>['Mon-Wed only', 'Tuesday, Wednesday, Friday, Saturday'],
        'works_monday'=>[true, true]
      }

      expected_changes = {
        'surname'=>['Bonstart', 'Bonstart-Smythe'],
        'email'=>['step.bonstart@digital.justice.gov.uk', 'step.bonstart-smythe@digital.justice.gov.uk'],
        'description'=>['Mon-Wed only', 'Tuesday, Wednesday, Friday, Saturday']
      }
      actual_changes = aggregator.__send__(:eliminate_noops, changes)
      expect(actual_changes).to eq expected_changes
    end

    it 'considers empty string and nil to be the same' do
      changes = {
        'surname'=>['Bonstart', 'Bonstart-Smythe'],
        'primary_phone_number'=>['020 7835 2232', '020 7835 2232'],
        'alternative_phone_number'=>[nil, ''],
        'email'=>['step.bonstart@digital.justice.gov.uk', 'step.bonstart-smythe@digital.justice.gov.uk'],
        'description'=>['Mon-Wed only', 'Tuesday, Wednesday, Friday, Saturday'],
        'works_monday'=>[true, true]
      }

      expected_changes = {
        'surname'=>['Bonstart', 'Bonstart-Smythe'],
        'email'=>['step.bonstart@digital.justice.gov.uk', 'step.bonstart-smythe@digital.justice.gov.uk'],
        'description'=>['Mon-Wed only', 'Tuesday, Wednesday, Friday, Saturday']
      }
      actual_changes = aggregator.__send__(:eliminate_noops, changes)
      expect(actual_changes).to eq expected_changes
    end

    it 'eliminates noops in membership hashes' do
      changes = {
        'surname'=>['Bonstart', 'Bonstart-Smythe'],
        'primary_phone_number'=>['020 7835 2232', '020 7835 2232'],
        'alternative_phone_number'=>[nil, ''],
        'email'=>['step.bonstart@digital.justice.gov.uk', 'step.bonstart-smythe@digital.justice.gov.uk'],
        'membership_6'=>{ 'group_id'=>[1, 6], 'role' => %w(dogsbody dogsbody), 'leader'=>[false, true], 'subscribed'=>[false, true] },
        'description'=>['Mon-Wed only', 'Tuesday, Wednesday, Friday, Saturday'],
        'works_monday'=>[true, true]
      }

      expected_changes = {
        'surname'=>['Bonstart', 'Bonstart-Smythe'],
        'email'=>['step.bonstart@digital.justice.gov.uk', 'step.bonstart-smythe@digital.justice.gov.uk'],
        'membership_6'=>{ 'group_id'=>[1, 6], 'leader'=>[false, true], 'subscribed'=>[false, true] },
        'description'=>['Mon-Wed only', 'Tuesday, Wednesday, Friday, Saturday']
      }
      actual_changes = aggregator.__send__(:eliminate_noops, changes)
      expect(actual_changes).to eq expected_changes
    end

    it 'considers empty strings and nil to be the same in membership hashes' do
      changes = {
        'surname'=>['Bonstart', 'Bonstart-Smythe'],
        'primary_phone_number'=>['020 7835 2232', '020 7835 2232'],
        'alternative_phone_number'=>[nil, ''],
        'email'=>['step.bonstart@digital.justice.gov.uk', 'step.bonstart-smythe@digital.justice.gov.uk'],
        'membership_6'=>{ 'group_id'=>[1, 6], 'role' => ['', nil], 'leader'=>[false, false], 'subscribed'=>[false, true] },
        'description'=>['Mon-Wed only', 'Tuesday, Wednesday, Friday, Saturday'],
        'works_monday'=>[true, true]
      }

      expected_changes = {
        'surname'=>['Bonstart', 'Bonstart-Smythe'],
        'email'=>['step.bonstart@digital.justice.gov.uk', 'step.bonstart-smythe@digital.justice.gov.uk'],
        'membership_6'=>{ 'group_id'=>[1, 6], 'subscribed'=>[false, true] },
        'description'=>['Mon-Wed only', 'Tuesday, Wednesday, Friday, Saturday']
      }
      actual_changes = aggregator.__send__(:eliminate_noops, changes)
      expect(actual_changes).to eq expected_changes
    end

  end
end
