variable "VERSION" {}

variable "HOMEBREW_VERSION" {
  default = "${VERSION}"
}

target "default" {
  dockerfile = "Dockerfile"
  args = {
    VERSION = "${VERSION}"
    HOMEBREW_VERSION = "${HOMEBREW_VERSION}"
  }
  output = ["./dist"]
}
