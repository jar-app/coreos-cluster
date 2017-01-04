def cloud_config
  ERB.new(File.read('cloud-config.yml.erb')).result
end

def etcd_discover_token
  size = CLUSTER_BOOTSTRA_DATA[:num_nodes]
  token = Net::HTTP.get_response(URI.parse("https://discovery.etcd.io/new?size=#{size}")).body
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