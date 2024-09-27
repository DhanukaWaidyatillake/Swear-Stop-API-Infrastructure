resource "digitalocean_database_cluster" "swear-stop-redis" {
  name = "swear-stop-redis"
  engine = "redis"
  version = "7"
  size = "db-s-1vcpu-1gb"
  region = var.do_region
  node_count = 1
}

# We want to allow access to the database from our Kubernetes cluster
# We can also add custom IP addresses
# If you would like to connect from your local machine,
# simply add your public IP
resource "digitalocean_database_firewall" "swear-stop-redis" {
  cluster_id = digitalocean_database_cluster.swear-stop-redis.id

  rule {
    type  = "k8s"
    value = digitalocean_kubernetes_cluster.swear-stop-infra.id
  }

#   rule {
#     type  = "ip_addr"
#     value = "ADD_YOUR_PUBLIC_IP_HERE_IF_NECESSARY"
#   }
}

output "swear-stop-redis-host" {
  value = digitalocean_database_cluster.swear-stop-redis.host
}

output "swear-stop-redis-port" {
  value = digitalocean_database_cluster.swear-stop-redis.port
}