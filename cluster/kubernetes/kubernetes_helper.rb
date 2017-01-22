module Kubernetes
  module Helper
    class << self
      def api_server_ip
        "127.0.0.1"
      end
      def api_server_url
        "http://#{api_server_ip}"
      end

      def binaries_dir
        "/opt/bin"
      end

      def api_server_port
        8080
      end
    end
  end
end
