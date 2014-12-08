require_relative 'common_examples'

shared_examples_for 'create command' do
  before do
    args << 'create'
  end

  it "creates container and exits with 0 on creation" do
    expect(specification).to receive(:create).with(no_args).and_return(true)
    expect(command_run).to eq(0)
  end

  it "creates container and exits with 1 on non-creation" do
    expect(specification).to receive(:create).with(no_args).and_return(false)
    expect(command_run).to eq(1)
  end
end

describe 'tainers create' do
  it_behaves_like "a command", "create command"
end

