### 0.2.0.pre

* changed dependency on docker-api gem to get to 1.2+; this is intended to allow
  usage of new docker API changes accompanying docker 1.6.

### 0.1.0

* introduced auto-pulling behavior to pull images down when creating a container
* rearranged specifications:
  * `Tainers::Specification::Bare` is consistent with earlier Specification class.
  * `Tainers::Specification::ImagePuller` automatically pulls images as necessary.
* `Tainers::Image::create` takes hash of options

### 0.0.2

* added `Tainers::Specification#create` method
* added `tainers create` CLI command

### 0.0.1

* basic `Tainers::Specification` object
* with #ensure, #name, #exists?
* container hash generation
* container name rules
* basic CLI commands

