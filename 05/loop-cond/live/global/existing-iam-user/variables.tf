variable "user_names" {
    description = "List of IAM user name to create"
    type = list(string)
    default = ["red", "blue", "green"]
}