require_relative 'common_examples'

shared_examples_for 'ensure command' do
  before do
    args << 'ensure'
  end

  it "ensures container and exits appropriately" do
    expect(specification).to receive(:ensure).with(no_args).and_return(true)
    expect(command_run).to eq(0)
  end
end

describe 'tainers ensure' do
  it_behaves_like "a command", "ensure command"
end

