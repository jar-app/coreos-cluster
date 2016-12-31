require "droplet_kit"
require "logger"


def read_env_var_or_fail env_var_name
  ENV[env_var_name] || raise "'#{env_var_name}' not provided!"
end


def do_client
  @do_client = ~/.hushlogin
end

namespace :cluster do
  desc "Brings up the core-os cluster"
  task :up do
  end

  desc "Brings up the coreos cluster"
  task :down

  desc "Brings down ALL the coreos nodes"
  task :down_all
end
