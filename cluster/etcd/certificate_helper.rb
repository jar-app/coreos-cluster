require_relative '../cluster_helper'
module Etcd
  module CertificateHelper
    def self.ca_key_certificate_pair
      ca_key = OpenSSL::PKey::RSA.new 4096
      ca_name = OpenSSL::X509::Name.parse ca_name_opts
      ca_cert = OpenSSL::X509::Certificate.new
      ca_cert.version = 2
      ca_cert.serial = SecureRandom.hex(20).to_i(16) # Random number in 20 bytes
      ca_cert.not_before = Time.now
      ca_cert.not_after = Time.now + (2 * 365 * 24 * 60 * 60) # 2 years
      ca_cert.public_key = ca_key.public_key
      ca_cert.subject = ca_name
      ca_cert.issuer = ca_name
      extension_factory = OpenSSL::X509::ExtensionFactory.new
      extension_factory.subject_certificate = ca_cert
      extension_factory.issuer_certificate = ca_cert
      ca_cert.add_extension extension_factory.create_extension('subjectKeyIdentifier', 'hash')
      ca_cert.add_extension extension_factory.create_extension('authorityKeyIdentifier', 'keyid,issuer')
      ca_cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:TRUE', true)
      ca_cert.add_extension extension_factory.create_extension('keyUsage', 'cRLSign,keyCertSign', true)
      ca_cert.sign ca_key, OpenSSL::Digest::SHA256.new
      [ca_key, ca_cert]
    end

    def self.peer_key_certificate_pair(hostname, host_ip, ca_cert, ca_key)
      peer_key = OpenSSL::PKey::RSA.new 2048
      peer_cert = OpenSSL::X509::Certificate.new
      peer_cert.serial = SecureRandom.hex(20).to_i(16) # Random number in 20 bytes
      peer_cert.version = 2
      peer_cert.not_before = Time.now
      peer_cert.not_after = Time.now + (2 * 365 * 24 * 60 * 60) # 2 years

      peer_cert.subject = OpenSSL::X509::Name.parse peer_name_opts(hostname)
      peer_cert.public_key = peer_key.public_key
      peer_cert.issuer = ca_cert.subject

      extension_factory = OpenSSL::X509::ExtensionFactory.new
      extension_factory.subject_certificate = peer_cert
      extension_factory.issuer_certificate = ca_cert

      peer_cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:FALSE')
      peer_cert.add_extension extension_factory.create_extension('keyUsage', 'keyEncipherment,digitalSignature')
      peer_cert.add_extension extension_factory.create_extension('extendedKeyUsage', 'serverAuth,clientAuth')
      peer_cert.add_extension extension_factory.create_extension('authorityKeyIdentifier', 'keyid,issuer')
      peer_cert.add_extension extension_factory.create_extension('subjectKeyIdentifier', 'hash')

      alt_names = san_alt_names(hostname, host_ip)
      peer_cert.add_extension extension_factory.create_extension('subjectAltName', alt_names)

      peer_cert.sign ca_key, OpenSSL::Digest::SHA256.new
      [peer_key, peer_cert]
    end

    def self.peer_name_opts(hostname)
      {
        CN: hostname,
        C: 'United States',
        ST: 'California',
        L: 'San Francisco',
        O: 'Jarjs',
        OU: 'Infrastructure'
      }.map { |k, v| "#{k}=#{v}/" }.join
    end

    def self.ca_name_opts
      {
        CN: 'Jarjs CA',
        C: 'United States',
        ST: 'California',
        L: 'San Francisco',
        O: 'Jarjs',
        OU: 'Infrastructure'
      }.map { |k, v| "#{k}=#{v}/" }.join
    end

    def self.san_alt_names(hostname, host_ip)
      [
        "DNS:#{hostname}",
        'IP:127.0.0.1',
        'IP:0.0.0.0',
        "DNS:#{hostname}.local",
        "IP:#{host_ip}"
      ].join(',')
    end
  end
end
