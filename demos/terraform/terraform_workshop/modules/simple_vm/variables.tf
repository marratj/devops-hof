variable project {
    description = "The GCP project to deploy the resources in"
}

variable region {
    description = "The GCP region to deploy the resources in"
}

variable machine_type {

}

variable zone {
}

variable vm_name {

}

variable tags {
    default = ["foo", "bar"]
}

variable vm_count {
    default = 1
}

variable service_account {

}