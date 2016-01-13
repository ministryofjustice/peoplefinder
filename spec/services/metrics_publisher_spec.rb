require 'spec_helper'
require 'metrics_publisher'

RSpec.describe MetricsPublisher, type: :service do
  subject { described_class.new(recipient) }
  let(:recipient) { double('Keen', publish: nil) }
  let!(:person_class) do
    pc = class_double(
      'Person',
      count: 0,
      overall_completion: 0,
      bucketed_completion: {}
    ).as_stubbed_const
    allow(pc).to receive(:where).and_return(pc)
    pc
  end

  it 'sends overall completion details' do
    allow(person_class).to receive(:overall_completion).and_return(67)
    expect(recipient).to receive(:publish).
      with(:completion, a_hash_including('mean' => 67))
    subject.publish!
  end

  it 'sends bucketed completion details' do
    allow(person_class).to receive(:bucketed_completion).and_return(
      (0...20)  => 10,
      (20...50) => 20,
      (50...80) => 30,
      (80..100) =>  5
    )
    expect(recipient).to receive(:publish).
      with(:completion, a_hash_including(
                          '[0,20)'  => 10,
                          '[20,50)' => 20,
                          '[50,80)' => 30,
                          '[80,100]' =>  5
      ))
    subject.publish!
  end

  it 'sends the number of profiles' do
    allow(person_class).to receive(:count).and_return(667)
    expect(recipient).to receive(:publish).
      with(:profiles, a_hash_including('total' => 667))
    subject.publish!
  end

  it 'sends the number of profiles that have not logged in' do
    scope = double(count: 42)
    allow(person_class).to receive(:where).with(login_count: 0).
      and_return(scope)
    expect(recipient).to receive(:publish).
      with(:profiles, a_hash_including('not_logged_in' => 42))
    subject.publish!
  end
end
