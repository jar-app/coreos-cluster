namespace :cluster do
  namespace :kubernetes do
    desc "Install kubernetes on each of the cluster members"
    task :install do
      droplets = Cluster::Helper.created_cluster_droplets
      ssh_key_path = CONFIG['cluster']['local_ssh_private_key_path']
      ssh_private_keys = [File.read(ssh_key_path)]
      Parallel.each(droplets, progress: 'Installing kubernetes on cluster') do |droplet|
        hostname = droplet.name
        host_ip = droplet.networks.v4.first.ip_address
        user = 'core'
        retry_interval = 5
        retry_count = 10
        ssh_opts = {
          paranoid: false, # Avoid raising errors on host key fingerprint mismatch
          key_data: ssh_private_keys,
          keys_only: true,
          auth_methods: ['publickey'] # Only use public/private key auth
        }
        begin
          Net::SSH.start(host_ip, user, ssh_opts) do |ssh|
            cmds = [
              "sudo mkdir -p #{Kubernetes::Helper.binaries_dir}",
              "curl -O https://storage.googleapis.com/kubernetes-release/release/v1.5.2/kubernetes-server-linux-amd64.tar.gz",
              "tar -zxvf kubernetes-server-linux-amd64.tar.gz",
              "sudo cp ~/kubernetes/server/bin/* #{Kubernetes::Helper.binaries_dir}"
            ]
            ssh.exec!(cmds.join(" && "))
          end
        rescue => e
          retry_count -= 1
          if retry_count <= 0
            raise e
          else
            logger.error("#{hostname}: #{e.message}")
            sleep retry_interval
            retry
          end
        end
      end
    end
  end
end
