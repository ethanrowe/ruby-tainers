require 'rspec_helper'
require 'digest'

def hashit str
  Digest::SHA1.hexdigest(str)
end

RSpec.describe 'Tainers.hash' do
  let(:test_number) { self.object_id }
  let(:test_string) { "something-#{self.object_id.to_s}-blah" }

  it 'handles a simple string' do
    expect(Tainers.hash test_string).to eq(hashit('"' + test_string + '"'))
  end

  it 'handles a simple number' do
    expect(Tainers.hash test_number).to eq(hashit(test_number.to_s))
  end

  it 'handles an array of mixed simple type' do
    expected_ary = ['[', test_string, test_number, ']'].to_json
    expect(Tainers.hash [test_string, test_number]).to eq(hashit expected_ary)
  end

  it 'handles a hash of mixed simple type' do
    expected = ["{", "a", test_number, "b", test_string, "c", test_number + 1, "d", test_string + "z", "}"].to_json
    expect(Tainers.hash "c" => test_number + 1,
                        "a" => test_number,
                        "d" => test_string + "z",
                        "b" => test_string).to eq(hashit expected)
  end

  it 'handles a complex structure' do
    expected = [
      "[",
      test_number,
      [
        '{',
        'first', [
          '{',
          1, 'one',
          2, 'two',
          '}',
        ],
        'second', [
          '[',
          'a',
          'b',
          ']',
        ],
        '}',
      ],
      test_string,
      [
        '{',
        'fourth', [
          '[',
          1000,
          500,
          ']',
        ],
        'third', [
          '{',
          ['[', 'a', 'b', ']'], 'ey',
          ['[', 'b', 'a', ']'], 'bee',
          '}',
        ],
        '}',
      ],
      "]",
    ].to_json
    struct = [
      test_number,
      {
        'first' => {2 => 'two', 1 => 'one'},
        'second' => ['a', 'b'],
      },
      test_string,
      {
        'third' => {['b','a'] => 'bee', ['a','b'] => 'ey'},
        'fourth' => [1000, 500],
      },
    ]
    expect(Tainers.hash struct).to eq(hashit expected)
  end
end

