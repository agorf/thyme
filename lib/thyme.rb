require 'thyme/db'
require 'thyme/photo'
require 'thyme/set'

DataMapper.finalize
DataMapper.auto_migrate!
