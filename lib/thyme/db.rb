require 'data_mapper'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite://#{File.expand_path('index.db')}")
DataMapper.finalize
