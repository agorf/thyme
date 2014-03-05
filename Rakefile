require 'rake/clean'
require 'thyme'

CLOBBER.include('index.db', File.join(*%w{public thumbs}))

task :upgrade_schema do
  require 'data_mapper'
  DataMapper.auto_upgrade!
end

task :make_thumbs_dir do
  mkdir_p File.join(*%w{public thumbs})
end

desc 'Scan library for photos and build database'
task :build_index, [:library_path] => [:upgrade_schema] do |t, args|
  FileList[
    File.join(
      File.expand_path(args.library_path),
      '**',
      '*.{jpg,jpeg,JPG,JPEG}'
    )
  ].each do |filename|
    Thyme::Photo.create_from_file(filename)
  end

  Thyme::Set.map(&:update_taken_at!)
end

desc 'Generate photo thumbnails from database'
task generate_thumbs: [:upgrade_schema, :make_thumbs_dir] do
  Thyme::Photo.map(&:generate_thumbs!)
end

desc 'Run application'
task :serve do
  exec 'bundle exec rackup -p 4567'
end

desc 'Open application in browser'
task :open do
  fork do
    sleep 2
    exec 'xdg-open http://localhost:4567'
  end

  Rake::Task['serve'].execute
end
