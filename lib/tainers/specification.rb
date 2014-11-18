require 'docker'

module Tainers

  # An object representing a container configuration (a "specification"), with
  # methods for checking and/or ensuring existence (by name).
  #
  # While this can be used directly, it is not intended for direct instantiation,
  # instead designed to be used via Tainers::specify, which provides name determination
  # logic for organizing containers by their configuration.
  class Specification

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

    # The name of the container described by this specification.
    def name
      @args['name']
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
  end

  module API
    def self.get_by_name name
      begin
        Docker::Container.get(name)
      rescue Docker::Error::NotFoundError
        nil
      end
    end

    def self.create_or_conflict params
      begin
        Docker::Container.create(params)
        return true
      rescue Excon::Errors::Conflict
        return true
      end
      false
    end
  end
end
