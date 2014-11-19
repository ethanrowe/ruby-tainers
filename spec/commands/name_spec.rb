require_relative 'common_examples'

shared_examples_for 'name command' do
  before do
    args << 'name'
  end

  it "writes the name of the container to stdout" do
    expect(specification).to receive(:name).with(no_args).and_return(name = "some-name-" + double.object_id.to_s)
    expect(STDOUT).to receive(:print).with("#{name}\n")
    expect(command_run).to eq(0)
  end
end

describe 'tainers name' do
  it_behaves_like 'a command', 'name command'
end

