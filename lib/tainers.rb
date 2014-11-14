require 'digest'
require 'json'

module Tainers
  # call-seq:
  #     Tainers.hash(structure) => consistent hash hexdigest
  #
  # Produces a consistent hash hexdigest string for the input
  # structure, handling arrays, hashes, strings, numbers, nesting
  # of such structures, etc.
  #
  # Hash keys are sorted prior to computing the digest, to ensure
  # that hashes that would be regarded as equal produce the same
  # digest.
  #
  #     Tainers.hash({"a" => "foo", "b" => "bar"})  #=> "5427f704439548cae1911616e2bec3b7cc2dd11c"
  #
  def self.hash structure
    str = structured_string(structure)
    Digest::SHA1.hexdigest str
  end

  private

  def self.consistent_structure structure
    if Hash === structure
      s = structure.keys.sort.inject(["{"]) do |a, key|
        a << consistent_structure(key)
        a << consistent_structure(structure[key])
        a
      end
      s << "}"
      s
    elsif Array === structure
      s = structure.collect {|item| consistent_structure item}
      s.unshift "["
      s << "]"
      s
    else
      structure
    end
  end

  def self.structured_string structure
    consistent_structure(structure).to_json
  end
end
