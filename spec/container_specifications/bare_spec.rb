require 'rspec_helper'

shared_examples_for 'container creator' do
  before do
    expect(subject).to receive(:exists?).and_return(false)
  end

  it 'uses Docker::Container for creation' do
    expect(Docker::Container).to receive(:create).with(specification_args).and_return(container = double)
    expect(creation_operation).to be(subject)
  end

  it 'is okay with a conflict result' do
    expect(Docker::Container).to receive(:create).with(specification_args).and_raise(Excon::Errors::Conflict, "Pickles")
    expect(creation_operation).to be(expected_conflict_result)
  end

  it 'does not handle other exceptions' do
    expect(Docker::Container).to receive(:create).with(specification_args).and_raise(Exception, "You suck.")
    expect { creation_operation }.to raise_error("You suck.")
  end
end


RSpec.describe Tainers::Specification::Bare do
  it 'requires a name' do
    expect { Tainers::Specification::Bare.new 'Image' => 'foo/image:latest' }.to raise_error(/name is required/)
  end

  it 'requires an image' do
    expect { Tainers::Specification::Bare.new 'name' => 'something' }.to raise_error(/Image is required/)
  end

  context 'for a container' do
    let(:name) { "something-#{object_id.to_s}-foo" }
    let(:image) { "some.#{object_id.to_s}.repo:5000/some-image/#{object_id.to_s[0..5]}" }
    let(:container_args) { {'Image' => image, double.to_s => double.to_s } }
    let(:specification_args) { container_args.merge('name' => name) }

    subject do
      Tainers::Specification::Bare.new specification_args
    end

    context 'that does not exist' do
      it 'indicates non-existence' do
        expect(Docker::Container).to receive(:get).with(name).and_raise(Docker::Error::NotFoundError)
        expect(subject.exists?).to be false
      end

      context '#ensure' do
        let(:expected_conflict_result) { subject }
        let(:creation_operation) { subject.ensure }

        it_behaves_like 'container creator'
      end

      context '#create' do
        let(:expected_conflict_result) { false }
        let(:creation_operation) { subject.create }

        it_behaves_like 'container creator'
      end
    end

    context 'that exists' do
      it 'indicates existence' do
        expect(Docker::Container).to receive(:get).with(name).and_return(double)
        expect(subject.exists?).to be true
      end

      it 'does a no-op for #ensure' do
        expect(subject).to receive(:exists?).and_return(true)
        expect(Docker::Container).to receive(:create).never
        expect(subject.ensure).to be(subject)
      end

      it 'does a no-op for #create' do
        expect(subject).to receive(:exists?).and_return(true)
        expect(Docker::Container).to receive(:create).never
        expect(subject.create).to be(false)
      end
    end
  end
end
