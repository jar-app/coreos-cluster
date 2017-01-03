require_relative '../cluster_helper'

namespace :cluster do
  namespace :etcd do
    desc "Generate certifactes for etcd2 to encrypt/authenticate all communication"
    task :encrypt do
      wait_for_cluster_bootstrap
      droplets = created_cluster_droplets
    end
  end
end
