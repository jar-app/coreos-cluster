def cloud_config(etcd_member_name)
  ERB.new(File.read('cloud-config.yml.erb')).result(binding)
end

def etcd_discover_token
  size = CLUSTER_BOOTSTRA_DATA[:num_nodes]
  @token ||= Net::HTTP.get_response(URI.parse("https://discovery.etcd.io/new?size=#{size}")).body
end

def droplet_name
  name = nil
  loop do
    name = Faker::Hipster.words(2).join('-').downcase
    break if (name =~ VALID_HOST_NAME_REGEX) === 0
  end
  name
end

# Waits until all cluster members are up
def wait_for_cluster_bootstrap
  retry_interval = 1
  loop do
    ready_droplets = created_cluster_droplets.collect { |droplet| droplet.status == "active" }
    num_ready = ready_droplets.select { |ready| ready }.size
    break if num_ready == CLUSTER_BOOTSTRA_DATA[:num_nodes]
    logger.debug "Only #{num_ready} droplet(s) ready. Retrying in #{retry_interval}s"
    sleep retry_interval
  end
end


# All droplets created for the cluster
def created_cluster_droplets
  do_client.droplets.all(tag: CLUSTER_BOOTSTRA_DATA[:tags].first)
end


def remote_ca_file_path
  "/home/core/ca.pem"
end

def remote_cert_file_path
  "/home/core/coreos.pem"
end

def remote_key_file_path
  "/home/core/coreos-key.pem"
end

def client_advertise_urls
  ["https://0.0.0.0:2379", "https://0.0.0.0:4001"]
end
