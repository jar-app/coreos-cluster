require 'droplet_kit'
require 'logger'
require 'net/http'
require 'erb'
require 'faker'
require 'parallel'

VALID_HOST_NAME_REGEX = /^[a-z-]+$/
CLUSTER_BOOTSTRA_DATA = {
  tags: ['jar-app', 'env-stage'],
  num_nodes: 10,
  region: %w(sfo2 nyc1),
  image: 'coreos-stable',
  size: '512mb'
}.freeze

namespace :cluster do
  desc 'Brings up the core-os cluster'
  task :up do
    # Generate the etcd discover token only once
    user_data = cloud_config
    ssh_key = do_client.ssh_keys.all.first.id
    Parallel.each(CLUSTER_BOOTSTRA_DATA[:num_nodes].times, progress: "Spinng up VMs") do
      region = CLUSTER_BOOTSTRA_DATA[:region].sample
      name = droplet_name
      droplet = DropletKit::Droplet.new(name: name,
                                        user_data: user_data,
                                        region: region,
                                        image: CLUSTER_BOOTSTRA_DATA[:image],
                                        size: CLUSTER_BOOTSTRA_DATA[:size],
                                        tags: CLUSTER_BOOTSTRA_DATA[:tags],
                                        ipv6: true,
                                        ssh_keys: [ssh_key])
      resp = do_client.droplets.create(droplet)
    end
    Rake::Task["cluster:list"].execute
  end

  desc "List droplets in the cluster"
  task :list do
    created_droplets = do_client.droplets.all(tag: CLUSTER_BOOTSTRA_DATA[:tags].first)
    Parallel.each(created_droplets) do |droplet|
      name = "'#{droplet.name}'".ljust(25)
      ip_address = droplet.networks.v4.first ? droplet.networks.v4.first.ip_address : "pending"
      logger.info "Droplet: #{name} ipv4: #{ip_address}"
    end
  end

  desc 'Brings up the coreos cluster'
  task :down do
    begin
      tag = CLUSTER_BOOTSTRA_DATA[:tags].first
      logger.info "Deleting all images with the tag: '#{tag}'"
      do_client.droplets.delete_for_tag(tag_name: tag)
    rescue => e
      logger.error e.message
    end
  end

  desc 'Brings down ALL the coreos nodes'
  task :down_all do
    Parallel.map(do_client.droplets.all, progress: "Shutting down VMs") do |droplet|
      do_client.droplets.delete(id: droplet.id)
      logger.info "Deleted droplet: '#{droplet.name}' in region #{droplet.region.name}"
    end
  end
end

def read_env_var_or_fail(env_var_name)
  ENV[env_var_name] || raise("'#{env_var_name}' not provided!")
end

def do_client
  access_token = read_env_var_or_fail('DIGITAL_OCEAN_ACCESS_TOKEN')
  @do_client ||= DropletKit::Client.new(access_token: access_token)
end

def logger
  @logger ||= Logger.new(STDOUT)
end

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
