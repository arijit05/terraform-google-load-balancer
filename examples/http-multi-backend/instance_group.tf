# ------------------------------------------------------------------------------
# CREATE THE INSTANCE GROUP WITH A SINGLE INSTANCE AND THE BACKEND SERVICE CONFIGURATION
#
# We use the instance group only to highlight the ability to specify multiple types
# of backends for the load balancer
# ------------------------------------------------------------------------------

resource "google_compute_instance_group" "api" {
  provider  = "google-beta"
  project   = "${var.project}"
  name      = "${var.name}-instance-group"
  zone      = "${var.zone}"
  instances = ["${google_compute_instance.api.self_link}"]

  lifecycle {
    create_before_destroy = true
  }

  named_port {
    name = "http"
    port = 5000
  }
}

resource "google_compute_instance" "api" {
  provider     = "google-beta"
  project      = "${var.project}"
  name         = "${var.name}-instance"
  machine_type = "f1-micro"
  zone         = "${var.zone}"

  # We're tagging the instance with the tag specified in the firewall rule
  tags = ["private-app"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  # Make sure we have the flask application running
  metadata_startup_script = "${file("${path.module}/startup_script.sh")}"

  # Launch the instance in the default subnetwork
  network_interface {
    subnetwork = "default"

    # This gives the instance a public IP address for internet connectivity. Normally, you would have a Cloud NAT,
    # but for the sake of simplicity, we're assigning a public IP to get internet connectivity
    # to be able to run startup scripts
    access_config {}
  }
}