require_relative './rake_helper'
require_relative './cluster_helper'

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
    Rake::Task["cluster:etcd:encrypt"].execute
  end

  desc "List droplets in the cluster"
  task :list do
    Parallel.each(created_cluster_droplets) do |droplet|
      name = "'#{droplet.name}'"[0...25].ljust(25)
      ip_address = droplet.networks.v4.first ? droplet.networks.v4.first.ip_address : "pending"
      logger.info "Droplet: #{name} ipv4: #{ip_address}"
    end
  end

  desc 'Brings up the coreos cluster'
  task :down do
    begin
      tag = CLUSTER_BOOTSTRA_DATA[:tags].first
      logger.info "Deleting all images with the tag: '#{tag}'"
      resp = do_client.droplets.delete_for_tag(tag_name: tag)
    rescue => e
      logger.error e.message
    end
  end

  desc 'Brings down ALL the coreos nodes'
  task :down_all do
      num_deleted = 0
      Parallel.map(do_client.droplets.all, progress: "Shutting down VMs", in_threads: 10) do |droplet|
        begin
          do_client.droplets.delete(id: droplet.id)
          num_deleted = num_deleted + 1
        rescue => e
          logger.error e.message
        end
      end
      logger.info "Deleted #{num_deleted} total VM(s)"
    end
end
