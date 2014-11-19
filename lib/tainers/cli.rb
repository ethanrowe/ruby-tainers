require 'optparse'
require 'json'

module Tainers
  module CLI
    def self.run parameters
      spec, parameters = parse(parameters)
      cmd = Command.new(spec)
      cmd_name = parameters.shift
      cmd.send("#{cmd_name}_command".to_sym, *parameters)
    end

    def self.parse parameters
      options = {}
      options[:spec_source] = from_stdin
      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: tainers [opts] COMMAND"
        opts.separator ""
        opts.separator "Manipulate Tainer-managed containers, taking their specification in JSON (from STDIN by default)."
        opts.separator ""
        opts.separator "Specific options:"

        opts.on('-j JSON', '--json JSON', String, "Take container specification from the given JSON parameter.") do |j|
          options[:spec_source] = from_json(j)
        end

        opts.on('-f FILEPATH', '--file FILEPATH', String, "Take container specification from JSON in the given file.") do |f|
          options[:spec_source] = from_file(f)
        end

        opts.on('-p PREFIX', '--prefix PREFIX', String, "Use PREFIX as container name prefix (overriding whatever is in spec)") do |p|
          options['prefix'] = p
        end

        opts.on('-s SUFFIX', '--suffix SUFFIX', String, "Use SUFFIX as container name suffix (overriding whatever is in spec)") do |s|
          options['suffix'] = s
        end
      end

      # Stop on first non-option param
      non_param = []
      args = opt_parser.order(parameters) {|p| non_param << p; opt_parser.terminate}
      spec = options.delete(:spec_source).call
      spec.update(options)
      [spec, non_param + args]
    end

    def self.from_stdin
      Proc.new do
        JSON.parse(STDIN.read)
      end
    end

    def self.from_file file
      Proc.new do
        File.open(file, "r") do |f|
          JSON.parse(f.read)
        end
      end
    end

    def self.from_json json
      Proc.new do
        JSON.parse json
      end
    end

    class Command
      attr_reader :specification

      def initialize(spec={})
        @specification = Tainers.specify(spec)
      end

      def ensure_command
        return 0 if specification.ensure
        255
      end

      def exists_command
        return 0 if specification.exists?
        1
      end

      def name_command
        STDOUT.print "#{specification.name}\n"
        0
      end
    end
  end
end
