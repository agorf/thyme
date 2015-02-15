require 'logger'
require 'sequel'

DB = Sequel.connect(
  adapter: 'sqlite',
  database: File.expand_path('../../../thyme.db', __FILE__)
)
