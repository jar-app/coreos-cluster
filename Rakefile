require "droplet_kit"
require "logger"
require 'faker'
require 'parallel'


CLUSTER_BOOTSTRA_DATA {
  tags: ['jar-app', 'env-stage'],
  num_nodes: 10,

}





namespace :cluster do
  desc "Brings up the core-os cluster"
  task :up do

  end

  desc "Brings up the coreos cluster"
  task :down

  desc "Brings down ALL the coreos nodes"
  task :down_all
end


def read_env_var_or_fail env_var_name
  ENV[env_var_name] || raise("'#{env_var_name}' not provided!")
end


def do_client
  access_token = read_env_var_or_fail("DIGITAL_OCEAN_ACCESS_TOKEN")
  @do_client ||= Dropkit::Client.new(access_token: access_token)
end

def logger
  @logger ||= Logger.new(STDOUT)
end
