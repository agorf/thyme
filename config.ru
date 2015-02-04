lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) if !$:.include?(lib)

require 'thyme/db'
require 'thyme/server'

run Thyme::Server
