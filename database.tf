# Define some constant values for the different versions of DigitalOcean databases
locals {
  mysql = {
    engine  = "mysql"
    version = "8"
  }
}

# We need to create a database cluster in DigitalOcean,
# based on Mysql 8, which is the version DigitalOcean provides.
resource "digitalocean_database_cluster" "swear-stop-db" {
  name       = "swear-stop-db"
  engine     = local.mysql.engine  # Replace with `locals.postgres.engine` if using postgres
  version    = local.mysql.version # Replace with `locals.postgres.version` if using postgres
  size       = "db-s-1vcpu-1gb"
  region     = var.do_region
  node_count = 1
}

# We want to create a separate database for our application inside the database cluster.
# This way we can share the cluster resources, but have multiple separate databases.
resource "digitalocean_database_db" "swear-stop-db" {
  cluster_id = digitalocean_database_cluster.swear-stop-db.id
  name       = "swear-stop-db"
}

# We want to create a separate user for our application,
# So we can limit access if necessary
# We also use Native Password auth, as it works better with current Laravel versions
resource "digitalocean_database_user" "swear-stop-db" {
  cluster_id        = digitalocean_database_cluster.swear-stop-db.id
  name              = "swear-stop-user"
  mysql_auth_plugin = "mysql_native_password"
}

# We want to allow access to the database from our Kubernetes cluster
# We can also add custom IP addresses
# If you would like to connect from your local machine,
# simply add your public IP
resource "digitalocean_database_firewall" "swear-stop-db" {
  cluster_id = digitalocean_database_cluster.swear-stop-db.id

  rule {
    type  = "k8s"
    value = digitalocean_kubernetes_cluster.swear-stop-infra.id
  }

  rule {
    type  = "ip_addr"
    value = "192.168.1.2"
  }
}

# We also need to add outputs for the database, to easily be able to reach it.

# Expose the host of the database so we can easily use that when connecting to it.
output "swear-stop-db-database-host" {
  value = digitalocean_database_cluster.swear-stop-db.host
}

# Expose the port of the database, as it is usually different from the default ports of Mysql / Postgres
output "swear-stop-db-database-port" {
  value = digitalocean_database_cluster.swear-stop-db.port
}
