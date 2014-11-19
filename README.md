ruby-tainers
============

A helper for managing docker containers (hence 'tainers)

# Concept

Suppose you want to assemble docker containers (applying configuration to code) in a manner such that:
* Each such container/configuration combination has a deterministic name
* Such that it is only assembled once

With proper usage, this allows for an idempotent set of docker containers on a given host.

## Warum?

It is entirely possible that this is a stupid idea.  However, it happens to be the stupid idea we're trying at
work, so here we are.  It was my stupid idea, for the record.

One thing with docker containers is you could, depending on what they do, set up multiple redundant containers
and run them concurrently.  This deterministic-name idea, driven by the configuration of the container, would
seem to prohibit that.

However, consider: if your container exposes ports, then you cannot have multiple, literally redundant instances.
The ports will differ on the host OS.

What we do here is allow for the user to specify a prefix and a suffix for their container name; thus the name
is deterministically driven by configuration, but includes a user-specified component.  This lets you manage things
in a pretty flexible way while maintaining decent idempotence.

# Name

You can provide a prefix.  If you don't provide one, the prefix defaults to "Tainers".  Your prefix will be forced
to lower case, so it cannot possibly overlap with the default.

You can provide a suffix.  If you don't, none is used.

You provide the configuration for the container, in the same terms you would via the docker remote API.  This is
passed through to the `docker-api` gem, so see there for more details on how this works.

The final name is created by combined prefix with a sha1 hexdigest of the configuration hash, combined with the
suffix (if present).

Thus each distinct configuration gets a different hexdigest, but if a configuration is seen repeatedly, it will
have a consistent hexdigest.

All hail docker, all hail git.

# Operations

Ensure that this container exists

        tainers --prefix foo --suffix bar --json '{"Image": "ubuntu:14.04"}' ensure && echo tis there.

Check that it exists.

        tainers --prefix foo --suffix bar --json '{"Image": "ubuntu:14.04"}' exists && echo yep.

See it's name.

        tainers --prefix foo --suffix bar --json '{"Image": "ubuntu:14.04"}' name

You can use inline JSON, stdin JSON, or JSON in a file for the specification.

## In ruby

The command-line is just one usage; use it in ruby if you want programmatic usage.

        require 'tainers'
        c = Tainers.specify 'prefix' => 'foo',
                            'suffix' =>' bar',
                            'Image' => 'ubuntu:14.04'
        c.ensure if not c.exists?

# Don't wear a tie.

It's an anachronistic absurdity that needs to be abolished.  Direct your respect elsewhere.

