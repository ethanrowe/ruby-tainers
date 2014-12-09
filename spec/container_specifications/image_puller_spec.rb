require 'rspec_helper'

shared_examples_for 'specification delegator' do |method|
  let(:callable) do
    subject.method(method.to_sym)
  end

  it "passes through to underlying method" do
    expect(wrapped).to receive(method.to_sym).with(no_args).and_return(result = double)
    expect(callable.call).to be(result)
  end

  it "passes arguments through to underlying method" do
    args = [double, double, double]
    expect(wrapped).to receive(method.to_sym).with(*args).and_return(result = double)
    expect(callable.call(*args)).to be(result)
  end
end

shared_examples_for 'pulling delegator' do |method|
  let(:callable) do
    subject.method(method.to_sym)
  end

  let(:image) do
    "image-#{double.to_s}-foo"
  end

  before do
    allow(wrapped).to receive(:image).with(no_args).and_return(image)
  end

  describe "with no existing image" do
    before do
      expect(Docker::Image).to receive(:get).with(image).and_raise(Docker::Error::NotFoundError)
    end

    describe 'and successful pull' do
      let(:api_image) { double }

      before do
        expect(Docker::Image).to receive(:create).with(image).and_return(api_image)
      end

      it_behaves_like 'specification delegator', method
    end

    describe 'and failed pull' do
      before do
        # Just a general exception on this rather than a specific type;
        # the docker-api gem doesn't give a pretty exception here.
        expect(Docker::Image).to receive(:create).with(image).and_raise("Pull failed!")
        expect(wrapped).to receive(method.to_sym).never
      end

      it "propagates the pull failure exception" do
        expect { callable.call }.to raise_error("Pull failed!")
      end
    end
  end

  describe "with an existing image" do
    before do
      expect(Docker::Image).to receive(:get).with(image).and_return(double)
      expect(Docker::Image).to receive(:create).never
    end

    it_behaves_like 'specification delegator', method
  end
end

describe Tainers::Specification::ImagePuller do
  let(:wrapped) { double }

  subject { Tainers::Specification::ImagePuller.new wrapped }

  describe '#name method' do
    it_behaves_like 'specification delegator', :name
  end

  describe '#exists? method' do
    it_behaves_like 'specification delegator', :exists?
  end

  describe '#create method' do
    it_behaves_like 'pulling delegator', :create
  end

  describe '#ensure method' do
    it_behaves_like 'pulling delegator', :ensure
  end
end
