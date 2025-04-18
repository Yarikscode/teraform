variable "name_prefix" {
  description = "(Optional) - Name prefix for project."
  type        = string
  default     = "project"
}

variable "folder_id" {
  description = "(Optional) - Yandex Cloud Folder ID where resources will be created."
  type        = string
}

variable "zone" {
  description = "(Optional) - Yandex Cloud Zone for provisoned resources."
  type        = string
  default     = "ru-central1-a"
}

variable "image_id" {
  description = "(Optional) - Boot disk image id. If not provided, it defaults to Ubuntu 22.04 LTS image id"
  type        = string
  default     = "fd8ba9d5mfvlncknt2kd"
}

variable "instance_resources_cores" {
  description = <<EOF
    (Optional) Specifies the resources allocated to an instance.
      - `platform_id`: The type of virtual machine to create.If not provided, it defaults to `standard-v3`.
      - `cores': number of cores(should be number)
  EOF
  type = string

  }

variable "instance_resources_memory" {
  description = <<EOF
    (Optional) Specifies the resources allocated to an instance.
      - `platform_id`: The type of virtual machine to create.If not provided, it defaults to `standard-v3`.
      - `memory': count of memory(should be number)
  EOF
  type = string

  }

variable "instance_resources" {
  description = <<EOF
    (Optional) Specifies the resources allocated to an instance.
      - `platform_id`: The type of virtual machine to create.If not provided, it defaults to `standard-v3`.
      - `disk`: Configuration for the instance disk.
        - `disk_type`: The type of disk for the instance. If not provided, it defaults to `network-ssd`.
        - `disk_size`: The size of the disk (in GiB) allocated to the instance. If not provided, it defaults to 15 GiB.
  EOF

  type = object({
    platform_id = optional(string, "standard-v3")
    disk = optional(object({
      disk_type = optional(string, "network-ssd")
      disk_size = optional(number, 15)
    }), {})
  })
  default = {}
}

variable "subnets" {
  description = "(Optional) - A map of subnet names to their CIDR block ranges."
  type        = map(list(string))
  default = {
    "private-subnet" = ["192.168.10.0/24"],
    "private-subnet2" = ["192.168.11.0/24"],
  }
}
