module RakeHelper
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
end
