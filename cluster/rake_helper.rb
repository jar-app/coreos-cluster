def read_env_var_or_fail(env_var_name)
  ENV[env_var_name] || raise("'#{env_var_name}' not provided!")
end

def do_client
  access_token = read_env_var_or_fail('DIGITAL_OCEAN_ACCESS_TOKEN')
  @do_client ||= DropletKit::Client.new(access_token: access_token)
end

def logger
  @logger ||= Logger.new(STDOUT)
end

def remote_ca_file_path
  "/home/core/ca.pem"
end

def remote_cert_file_path
  "/home/core/coreos.pem"
end

def remote_key_file_path
  "/home/core/coreos-key.pem"
end
