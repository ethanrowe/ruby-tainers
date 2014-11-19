require_relative 'common_examples'

shared_examples_for 'exists command' do
  before do
    args << 'exists'
  end

  it 'returns 0 for an existing container' do
    expect(specification).to receive(:exists).with(no_args).and_return(true)
    expect(command_run).to eq(0)
  end

  it 'returns 1 for a non-existent container' do
    expect(specification).to receive(:exists).with(no_args).and_return(false)
    expect(command_run).to eq(1)
  end
end

describe 'tainers exists' do
  it_behaves_like 'a command', 'exists command'
end

