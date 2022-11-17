variable "VERSION" {
    default = "0.0.0"
}

target "default" {
    dockerfile = "Dockerfile"
    args = {
        VERSION = "${VERSION}"
    }
    output = ["./dist"]
}
