require_relative 'kubernetes/kubernetes_helper'
module Cluster
  module Helper
    VALID_HOST_NAME_REGEX = /^[a-z-]+$/
    class << self
      def deep_merge(h1, h2)
        h1.merge(h2) do |_k, v1, v2|
          if v1.is_a?(Hash) && v2.is_a?(Hash)
            deep_merge(v1, v2)
          elsif v1.is_a?(Array) && v2.is_a?(Array)
            v1.concat(v2)
          else
            v2
          end
         end
      end

      def cloud_config(etcd_member_name)
        yml_str = ERB.new(File.read('cloud-config.yml.erb')).result(binding)
        cloud_config_stringify(YAML.safe_load(yml_str))
      end

      def master_cloud_config(etcd_member_name)
        cluster_memeber_config = YAML.safe_load(cloud_config(etcd_member_name))
        master_config = YAML.safe_load(ERB.new(File.read('cloud-config-master-extend.yml.erb')).result(binding))
        merged = deep_merge(cluster_memeber_config, master_config)
        cloud_config_stringify(merged)
      end

      def cloud_config_stringify(settings)
        ['#cloud-config', settings.to_yaml].join("\n")
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
        expected_nodes = CLUSTER_BOOTSTRAP_DATA['num_nodes']
        progress_bar = ProgressBar.create(title: 'Droplets ready', starting_at: 0, total: expected_nodes)
        loop do
          ready_droplets = created_cluster_droplets.collect { |droplet| droplet.status == 'active' }
          num_nodes_ready = ready_droplets.select { |ready| ready }.size
          progress_bar.progress = num_nodes_ready
          break if num_nodes_ready == expected_nodes
          sleep retry_interval
        end
      end

      # All droplets created for the cluster
      def created_cluster_droplets
        do_client.droplets.all(tag: CLUSTER_BOOTSTRAP_DATA['tags'].first)
      end
    end
  end
end
