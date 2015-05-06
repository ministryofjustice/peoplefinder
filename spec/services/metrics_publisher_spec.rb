require 'spec_helper'
require 'metrics_publisher'

RSpec.describe MetricsPublisher, type: :service do
  subject { described_class.new(recipient) }
  let(:recipient) { double('Keen') }
  let!(:person_class) { class_double('Person').as_stubbed_const }

  it 'sends completion details' do
    allow(person_class).to receive(:overall_completion).and_return(67)
    allow(person_class).to receive(:bucketed_completion).and_return(
      (0...20)  => 10,
      (20...50) => 20,
      (50...80) => 30,
      (80..100) =>  5
    )
    expected = {
      'mean'    => 67,
      '[0,20)'  => 10,
      '[20,50)' => 20,
      '[50,80)' => 30,
      '[80,100]' =>  5
    }
    expect(recipient).to receive(:publish).with(:completion, expected)

    subject.publish!
  end
end
