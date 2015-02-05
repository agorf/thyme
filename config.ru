lib = File.expand_path('lib')
$:.unshift(lib) if !$:.include?(lib)

require 'thyme/db'
require 'thyme/server'

run Thyme::Server
