require 'rspec_helper'

shared_examples_for 'a named specification' do
  it 'produces a deterministically named specification' do
    expect(Tainers).to receive(:hash).with(base_args.dup).and_return(hash)
    expect(Tainers::Specification::Bare).to receive(:new).with(base_args.dup.update('name' => name)).and_return(s = double)
    expect(Tainers.specify specify_args).to eq(s)
  end
end

describe 'Tainers::specify' do
  let(:prefix) { nil }
  let(:suffix) { nil }

  let(:base_args) { { double.to_s => double.to_s, double.to_s => double.to_s } }

  let(:specify_args) {
    [['prefix', prefix], ['suffix', suffix]].inject(base_args.dup) do |a, item|
      if item[1].nil?
        a
      else
        a.merge(item[0] => item[1])
      end
    end
  }

  let(:hash) { double.object_id.to_s }

  let(:name) {
    pre = if prefix.nil?
            'Tainers'
          else
              prefix.downcase
          end
    pre = 'Tainers' if pre.nil?
    suf = if suffix.nil?
            ''
          else
            '-' + suffix.downcase
          end
    "#{pre}-#{hash}#{suf}"
  }

  context 'with a prefix' do
    let(:prefix) { "pre#{double.object_id.to_s[0..5]}" }

    it_behaves_like 'a named specification'

    context 'of mixed case' do
      let(:prefix) { "PrE#{double.object_id.to_s[0..5]}" }

      it_behaves_like 'a named specification'

      context 'and a suffix' do
        let(:suffix) { "#{double.object_id.to_s[0..5]}sfx" }
        
        it_behaves_like 'a named specification'

        context 'of mixed case' do
          let(:suffix) { "#{double.object_id.to_s[0..5]}SfX" }

          it_behaves_like 'a named specification'
        end
      end
    end
  end

  context 'with a suffix' do
    let(:suffix) { "#{double.object_id.to_s[1..6]}suffy" }

    it_behaves_like 'a named specification'

    context 'of mixed case' do
      let(:suffix) { "#{double.object_id.to_s[1..6]}sUFFy" }

      it_behaves_like 'a named specification'
    end
  end
end
