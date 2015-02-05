require 'data_mapper'

DataMapper::Logger.new(STDOUT, :debug) if ENV['THYME_ENV'] == 'development'
DataMapper.setup(:default,
                 "sqlite://#{File.expand_path('../../../index.db', __FILE__)}")
DataMapper.finalize
