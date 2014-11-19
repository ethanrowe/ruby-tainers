require 'rspec_helper'
require 'json'
require 'tempfile'

shared_examples_for 'prefix and suffix' do |command_group|
  let(:param_prefix) { "opt-" + double.object_id.to_s }
  let(:param_suffix) { "opt-" + double.object_id.to_s }

  context 'with --prefix' do
    before do
      args << '--prefix'
      args << param_prefix
      expected_specification['prefix'] = param_prefix
    end

    it_behaves_like command_group

    context 'and --suffix' do
      before do
        args << '--suffix'
        args << param_suffix
        expected_specification['suffix'] = param_suffix
      end

      it_behaves_like command_group
    end
  end

  context 'with --suffix' do
    before do
      args << '--suffix'
      args << param_suffix
      expected_specification['suffix'] = param_suffix
    end

    it_behaves_like command_group
  end
end

shared_examples_for 'a command' do |command_group|
  let :provided_specification do
    {
      'Image' => double.object_id.to_s,
      double.to_s => double.to_s,
      'prefix' => "spec-" + double.object_id.to_s,
      'suffix' => "spec-" + double.object_id.to_s
    }
  end

  let :expected_specification do
    provided_specification.dup
  end

  let(:args) { [] }

  let(:json) { provided_specification.to_json }

  let(:specification) { double }

  let :command_run do
    Tainers::CLI.run args
  end

  before do
    expect(Tainers).to receive(:specify).with(expected_specification).and_return(specification)
  end

  context 'given JSON specification in parameters' do
    context 'via -j' do
      before do
        args << '-j'
        args << json
      end

      it_behaves_like "prefix and suffix", command_group
    end

    context 'via --json' do
      before do
        args << '--json'
        args << json
      end

      it_behaves_like "prefix and suffix", command_group
    end
  end

  context 'given JSON specification in a file' do
    let(:file) do 
      f = Tempfile.new('tainers-test-spec')
      f.write(json)
      f.close
      f
    end

    let(:path) { file.path }

    after do
      file.unlink
    end

    context 'via -f' do
      before do
        args << '-f'
        args << path
      end

      it_behaves_like "prefix and suffix", command_group
    end

    context 'via --file' do
      before do
        args << '--file'
        args << path
      end

      it_behaves_like "prefix and suffix", command_group
    end
  end

  context 'given JSON specification on STDIN' do
    before do
      expect(STDIN).to receive(:read).and_return(json)
    end

    it_behaves_like "prefix and suffix", command_group
  end
end

