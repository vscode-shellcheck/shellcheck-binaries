variable "VERSION" {}

target "default" {
  dockerfile = "Dockerfile"
  args = {
    VERSION = "${VERSION}"
  }
  output = ["./dist"]
}
