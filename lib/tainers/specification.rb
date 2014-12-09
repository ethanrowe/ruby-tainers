require 'docker'

module Tainers
  module Specification

    # An object representing a container configuration (a "specification"), with
    # methods for checking and/or ensuring existence (by name).
    #
    # While this can be used directly, it is not intended for direct instantiation,
    # instead designed to be used via Tainers::specify, which provides name determination
    # logic for organizing containers by their configuration.
    class Bare

      # Creates a new container specification that uses the same parameters supported
      # by the Docker::Container::create singleton method.  These parameters align
      # with that of the docker daemon remote API.
      #
      # Note that it requires a container name, and an Image.  Without an Image, there's
      # nothing to build.  The name is essential to the purpose of the entire Tainers project.
      def initialize args={}
        raise ArgumentError, 'A name is required' unless valid_name? args['name']

        raise ArgumentError, 'An Image is required' unless valid_image? args['Image']

        # Maketh a copyeth of iteth
        @args = {}.merge(args)
      end

      # Ensures that the container named by this specification exists, creating the
      # container if necessary.
      #
      # Note that this only ensures that a container with the proper name exists; it does not
      # ensure that the existing container has a matching configuration.
      #
      # Returns true if the container reliably exists (it has been shown to exist, or was
      # successfully created, or failed to create due to a name conflict).  All other cases
      # should result in exceptions.
      def ensure
        return self if exists?
        return self if Tainers::API.create_or_conflict(@args)
        return nil
      end

      # Creates the container named by this specification, if it does
      # not already exist.
      #
      # Returns true (self, actually) if the invocation resulted in the
      # creation of a new container; false otherwise.
      #
      # A false condition could result from:
      # - The container already existing
      # - The container being simultaneously created by another
      #   actor, with your invocation losing the race.
      # 
      # A failure to create due to operational or semantic issues
      # should result in an exception.  Therefore, any non-exceptional
      # case should mean that a container of the expected name exists,
      # though in the false result case there is no firm guarantee
      # that the existing container has the requested configuration e.
      def create
        return false if exists?
        return self if Tainers::API.create(@args)
        false
      end

      # The name of the container described by this specification.
      def name
        @args['name']
      end

      # The image of the container described by this specification.
      # Note that this is a string (a tag or image ID) and not a more
      # complex object.
      def image
        @args['Image']
      end

      # True if the container of the appropriate name already exists.  False if not.
      def exists?
        ! Tainers::API.get_by_name(name).nil?
      end

      private

      def valid_name? name
        ! (name.nil? or name == '')
      end

      def valid_image? image
        ! (image.nil? or image == '')
      end
    end # class Bare

    module Delegator
      def self.delegates(method_name)
        method_name = method_name.to_sym
        define_method(method_name) do |*args|
          chain.send(method_name, *args)
        end
      end

      def initialize(chain)
        @chain = chain
      end

      attr_reader :chain

      delegates :create
      delegates :ensure
      delegates :exists?
      delegates :name
    end

    # Tainer specification that automatically pulls the image
    # as needed prior to container creation operations.
    #
    # Wrap it around a bare specification to use it:
    #
    #     t1 = Tainers::Specification::Bare.new('Image' =>' foo')
    #     t2 = Tainers::Specification::ImagePuller.new(t1)
    #     # This doesn't pull image "foo"
    #     t1.ensure
    #     # But this will, if necessary
    #     t2.ensure
    #
    # Note that the #ensure and #create methods have the pulling
    # behavior; no others do.
    class ImagePuller
      include Delegator

      def self.ensure_image(image)
        if ! Tainers::API.image_exists?(image)
          Tainers::API.pull_image image
        end
        true
      end

      def self.pulls_and_delegates(method_name)
        method_name = method_name.to_sym
        define_method(method_name) do |*args|
          self.class.ensure_image(chain.image)
          chain.send(method_name, *args)
        end
      end
      
      pulls_and_delegates :create
      pulls_and_delegates :ensure
    end
  end # module Specification

  module API
    def self.image_exists? name
      begin
        return true if Docker::Image.get(name)
      rescue Docker::Error::NotFoundError
        return false
      end
    end

    def self.pull_image name
      Docker::Image.create(name)
    end

    def self.get_by_name name
      begin
        Docker::Container.get(name)
      rescue Docker::Error::NotFoundError
        nil
      end
    end

    def self.create params
      begin
        Docker::Container.create(params.dup)
        return true
      rescue Excon::Errors::Conflict
        return false
      end
    end

    def self.create_or_conflict params
      create params
      true
    end
  end # module API

  # Returns an image-pulling container specification
  # from the given parameters.
  #
  # Enforces the naming conventions such that the
  # name for the container will have prefix, suffix,
  # and spec-derived hash as documented elsewhere.
  #
  # The result will be an instance of Tainers::Specification::ImagePuller.
  def self.specify args={}
    Specification::ImagePuller.new(
      Specification::Bare.new named_parameters_for(args)
    )
  end

  def self.named_parameters_for params
    p = params.dup
    prefix = p.delete('prefix')
    prefix = if prefix.nil? || prefix == ''
               'Tainers'
             else
               prefix.downcase
             end
    suffix = p.delete('suffix')
    suffix = if suffix.nil?
               ''
             else
               "-#{suffix.downcase}"
             end
    digest = hash(p)
    p['name'] = "#{prefix}-#{digest}#{suffix}"
    p
  end
end
