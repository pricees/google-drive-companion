require "bundler/gem_tasks"



task default:  "test:all"

desc "Test all test/*test.rb files"
namespace :test do
  task :all do
    FileList['test/*test.rb'].each do |fn|
      puts "TESTING: #{fn}"
      sh "ruby -Ilib:test #{fn}"
    end
  end
end
