resource "null_resource" "kadmin" {
  provisioner "local-exec" {
    command = "cd admin && vagrant up"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "kmaster" {
  provisioner "local-exec" {
    command = "cd master && vagrant up"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "kworker-1" {
  provisioner "local-exec" {
    command = "cd worker-1 && vagrant up"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "kworker-2" {
  provisioner "local-exec" {
    command = "cd worker-2 && vagrant up"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}