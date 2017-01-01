require 'droplet_kit'
require 'logger'
require 'net/http'
require 'erb'
require 'faker'
require 'parallel'

CLUSTER_BOOTSTRA_DATA = {
  tags: ['jar-app', 'env-stage'],
  num_nodes: 10,
  region: %w(sfo2 nyc3),
  image: 'coreos-stable',
  size: '512mb'
}.freeze

namespace :cluster do
  desc 'Brings up the core-os cluster'
  task :up do
    ssh_key = do_client.ssh_keys.all.first.id
    Parallel.map(CLUSTER_BOOTSTRA_DATA[:num_nodes].times) do
      region = CLUSTER_BOOTSTRA_DATA[:region].sample
      name = Faker::Hipster.words(2).join('-').downcase
      droplet = DropletKit::Droplet.new(name: name,
                                        user_data: user_data,
                                        region: region,
                                        image: CLUSTER_BOOTSTRA_DATA[:image],
                                        size: CLUSTER_BOOTSTRA_DATA[:size],
                                        tags: CLUSTER_BOOTSTRA_DATA[:tags],
                                        ipv6: true,
                                        ssh_keys: [ssh_key])
      do_client.droplets.create(droplet)
      logger.info "Created droplet: '#{name}' in region: '#{region}'"
    end
  end

  desc 'Brings up the coreos cluster'
  task :down do
    tag = CLUSTER_BOOTSTRA_DATA[:tags].first
    logger.info "Deleting all images with the tag: '#{tag}'"
    do_client.droplets.delete_for_tag(tag_name: tag)
  end

  desc 'Brings down ALL the coreos nodes'
  task :down_all do
    Parallel.map(do_client.droplets.all) do |droplet|
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

def user_data
  ERB.new(File.read('cloud-config.yml.erb')).result
end

def etcd_discover_token
  Net::HTTP.get_response(URI.parse('https://discovery.etcd.io/new')).body
end
