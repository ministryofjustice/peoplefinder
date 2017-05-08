shared_examples_for "user_agent_helpable" do

  it { is_expected.to respond_to :user_agent }
  it { is_expected.to respond_to :supported_browser? }

end
