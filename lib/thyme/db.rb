require 'data_mapper'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper::Model.raise_on_save_failure = true
DataMapper.setup(:default, "sqlite://#{File.expand_path('index.db')}")
