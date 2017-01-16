module Cluster
  module Helper
    VALID_HOST_NAME_REGEX = /^[a-z-]+$/
    class << self
      def cloud_config(etcd_member_name)
        ERB.new(File.read('cloud-config.yml.erb')).result(binding)
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
        progress_bar = ProgressBar.create(:title => "Droplets ready", :starting_at => 0, :total => expected_nodes)
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
