module Etcd
  module Helper
    class << self
      def etcd_discover_token(num_nodes = 3)
        size = num_nodes
        @token ||= Net::HTTP.get_response(URI.parse("https://discovery.etcd.io/new?size=#{size}")).body
      end

      def remote_ssl_dir
        '/etc/etcd/ssl'
      end

      def remote_ca_file_path
        "#{remote_ssl_dir}/ca.pem"
      end

      def remote_cert_file_path
        "#{remote_ssl_dir}/coreos.pem"
      end

      def remote_key_file_path
        "#{remote_ssl_dir}/coreos-key.pem"
      end

      def client_advertise_url
        'https://0.0.0.0:2379'
      end
    end
  end
end
