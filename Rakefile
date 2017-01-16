require 'rubygems'
require 'bundler'
require 'droplet_kit'
require 'logger'
require 'net/http'
require 'erb'
require 'pry'
require 'faker'
require 'parallel'
require 'yaml'

require_relative 'rake_helper'
include RakeHelper



CONFIG = YAML.load_file('config.yml')
CLUSTER_BOOTSTRAP_DATA = CONFIG['cluster']['bootstrap']
Dir.glob('cluster/**/*.rake').each { |r| import r }
