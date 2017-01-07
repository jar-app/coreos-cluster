require 'openssl'
require 'securerandom'
require 'fileutils'
require 'net/scp'
require 'net/ssh'
require 'etc'
require_relative '../cluster_helper'
require_relative './certificate_helper'

CERT_DIR = '.data/certs/'
CA_CERT_NAME = 'ca_cert.perm'

namespace :cluster do
  namespace :etcd do
    desc "Generate certifactes for etcd2 to encrypt/authenticate all communication"
    task :encrypt do
      Rake::Task["cluster:etcd:generate_peer_certs"].invoke
      Rake::Task["cluster:etcd:copy_certs_to_cluster"].invoke
      Rake::Task["cluster:reboot"].invoke
    end

    desc "Generate a CA certificate"
    task :generate_ca_cert => [:clean_certs] do
      logger.info "Generating CA"
      FileUtils.mkdir_p CERT_DIR
      @ca_key, @ca_cert = CertificateHelper.ca_key_certificate_pair
      open "#{CERT_DIR}/#{CA_CERT_NAME}", 'w' do |io|
        io.write @ca_cert.to_pem
      end
    end

    desc "Generate a client certificate for all members in the cluster"
    task :generate_peer_certs => [:clean_certs, :generate_ca_cert]  do
      wait_for_cluster_bootstrap
      FileUtils.mkdir_p CERT_DIR
      droplets = created_cluster_droplets
      Parallel.each(droplets, progress: "Generating peer certifactes") do |droplet|
        hostname = droplet.name
        host_ip = droplet.networks.v4.first.ip_address
        ca_cert = @ca_cert || raise("@ca_cert not set!")
        ca_key = @ca_key || raise("@ca_key not set!")
        peer_key, peer_cert, = CertificateHelper.peer_key_certificate_pair(hostname, host_ip, ca_cert, ca_key)
        open "#{CERT_DIR}/#{hostname}.pem", 'w' do |io|
          io.write peer_cert.to_pem
        end
        open "#{CERT_DIR}/#{droplet.name}.key", 'w' do |io|
          io.write peer_key.export
        end
      end
    end

    desc "Clean up all certificates"
    task :clean_certs do
      FileUtils.rm_rf(CERT_DIR)
    end

    task :copy_certs_to_cluster do
      droplets = created_cluster_droplets
      ssh_dir = File.join(Etc.getpwuid.dir, ".ssh")
      ssh_private_keys = [File.read("#{ssh_dir}/id_rsa")]
      Parallel.each(droplets, progress: "Copying certificates to cluster") do |droplet|
        hostname = droplet.name
        host_ip = droplet.networks.v4.first.ip_address
        user = 'core'
        key_path = "#{CERT_DIR}/#{hostname}.key"
        peer_cert_path = "#{CERT_DIR}/#{hostname}.pem"
        ca_cert_path = "#{CERT_DIR}/#{CA_CERT_NAME}"
        retry_interval = 5
        retry_count = 10
        begin
          Net::SSH.start(host_ip, user, key_data: ssh_private_keys, keys_only: true, auth_methods: ["publickey"]) do |ssh|
            ssh.scp.upload!(key_path, remote_key_file_path)
            ssh.scp.upload!(peer_cert_path, remote_cert_file_path)
            ssh.scp.upload!(ca_cert_path, remote_ca_file_path)
          end
        rescue => e
          retry_count = retry_count - 1
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
