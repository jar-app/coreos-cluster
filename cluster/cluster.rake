require_relative 'cluster_helper'
require_relative 'etcd/etcd_helper'
require_relative 'flanneld/flanneld_helper'

namespace 'cluster' do
  desc 'Brings up the core-os cluster'
  task :up do
    # Generate the etcd discover token only once
    Etcd::Helper.etcd_discover_token(CLUSTER_BOOTSTRAP_DATA['num_nodes'])
    ssh_key = do_client.ssh_keys.all.first.id
    Parallel.each(CLUSTER_BOOTSTRAP_DATA['num_nodes'].times, progress: 'Spinng up VMs') do |vm_num|
      region = CLUSTER_BOOTSTRAP_DATA['regions'].sample
      name = Cluster::Helper.droplet_name
      user_data = vm_num.zero? ? Cluster::Helper.master_cloud_config(name) : Cluster::Helper.cloud_config(name)
      droplet = DropletKit::Droplet.new(name: name,
                                        user_data: user_data,
                                        region: region,
                                        image: CLUSTER_BOOTSTRAP_DATA['image'],
                                        size: CLUSTER_BOOTSTRAP_DATA['size'],
                                        tags: CLUSTER_BOOTSTRAP_DATA['tags'],
                                        ipv6: true,
                                        ssh_keys: [ssh_key])
      resp = do_client.droplets.create(droplet)
    end
    Rake::Task['cluster:list'].execute
    Rake::Task['cluster:etcd:encrypt'].invoke
    Rake::Task['cluster:kubernetes:install'].invoke
  end

  desc 'List droplets in the cluster'
  task :list do
    Parallel.each(Cluster::Helper.created_cluster_droplets) do |droplet|
      name = "'#{droplet.name}'"[0...25].ljust(25)
      ip_address = droplet.networks.v4.first ? droplet.networks.v4.first.ip_address : 'pending'
      logger.info "Droplet: #{name} ipv4: #{ip_address}"
    end
  end

  desc 'Brings up the coreos cluster'
  task :down do
    begin
      tag = CLUSTER_BOOTSTRAP_DATA['tags'].first
      logger.info "Deleting all images with the tag: '#{tag}'"
      resp = do_client.droplets.delete_for_tag(tag_name: tag)
    rescue => e
      logger.error e.message
    end
  end

  desc 'Reboots all machines in the cluster'
  task :reboot do
    Parallel.each(Cluster::Helper.created_cluster_droplets, progress: 'Rebooting all machines in the cluster') do |droplet|
      do_client.droplet_actions.reboot(droplet_id: droplet.id)
    end
  end

  desc 'SSH into the first cluster member'
  task :ssh do
    droplets = Cluster::Helper.created_cluster_droplets
    if droplets && droplets.first
      droplet = droplets.first
      ip_address = droplet.networks.v4.first ? droplet.networks.v4.first.ip_address : nil
      return logger.error "Network not available on node: #{droplet.name}" unless ip_address
      system("ssh core@#{ip_address}")
    else
      logger.error 'No droplet available'
    end
  end

  desc 'Brings down ALL the coreos nodes'
  task :down_all do
    num_deleted = 0
    Parallel.map(do_client.droplets.all, progress: 'Shutting down VMs', in_threads: 10) do |droplet|
      begin
        do_client.droplets.delete(id: droplet.id)
        num_deleted += 1
      rescue => e
        logger.error e.message
      end
    end
    logger.info "Deleted #{num_deleted} total VM(s)"
  end
end
