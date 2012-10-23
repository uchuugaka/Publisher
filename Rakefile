require 'rubygems'
require 'xcoder'
require 'github_api'

if File.exist?('Rakefile.config')
  load 'Rakefile.config'
end

$name="Publisher"

$github_user='ase-lab'
$github_repo='Publisher'

$configuration="Release"

project=Xcode.project($name)
$osx=project.target($name).config($configuration).builder
$osx.sdk = :macosx

desc "Clean, Build, Test and Archive for OS X"
task :default => [:osx]

desc "Cleans for OS X"
task :clean => [:removebuild, "osx:clean"]

desc "Builds for OS X"
task :build => ["osx:build"]

desc "Test for OS X"
task :test => ["osx:test"]

desc "Archives for OS X"
task :archive => [ "osx:archive"]

desc "Remove build folder"
task :removebuild do
  rm_rf "build"
end

desc "Clean, Build, Test and Archive for OS X"
task :osx => ["osx:clean", "osx:build", "osx:test", "osx:archive"]

namespace :osx do

  desc "Clean for OS X"
  task :clean => [:init, :removebuild] do
    $osx.clean
  end

  desc "Build for OS X"
  task :build => :init do
    $osx.build
  end
  
  desc "Test for OS X"
  task :test => :init do
    puts("Tests for OS X are not implemented - hopefully (!) - yet.")
  end

  desc "Archive for OS X"
  task :archive => ["osx:clean", "osx:build", "osx:test"] do
    cd "build/" + $configuration do
      sh "tar cvzf ../" + $name + ".tar.gz " + $name + ".app"
    end
  end

end

desc "Initialize and update all submodules recursively"
task :init do
  system("git submodule update --init --recursive")
  system("git submodule foreach --recursive git checkout master")
end

desc "Pull all submodules recursively"
task :pull => :init do
  system("git submodule foreach --recursive git pull")
end

def publish(version)
  github = Github.new :user => $github_user, :repo => $github_repo, :login => $github_login, :password => $github_password
  file = 'build/' + $name + ".tar.gz"
  name = $name + '-' + version + '.tar.gz'
  size = File.size(file)
  description = "Version " + version
  res = github.repos.downloads.create $github_user, $github_repo,
    "name" => name,
    "size" => size,
    "description" => description,
    "content_type" => "application/x-gzip"
  github.repos.downloads.upload res, file
end

desc "Publish a new version of the framework to github"
task :publish, :version do |t, args|
  if !args[:version]
    puts("Usage: rake publish[version]");
    exit(1)
  end
  if !defined? $github_login
    puts("$github_login is not set");
    exit(1)
  end
  if !defined? $github_password
    puts("$github_password is not set");
    exit(1)
  end
  version = args[:version]
  #check that version is newer than current_version
  current_version = open("Version").gets.strip
  if Gem::Version.new(version) < Gem::Version.new(current_version)
    puts("New version (" + version + ") is smaller than current version ("+current_version+")")
    exit(1)
  end
  #write version into versionfile
  File.open("Version", 'w') {|f| f.write(version) }
  Rake::Task["archive"].invoke
  system("git add Version")
  system('git commit -m "Bump version to ' + version + '"')
  system('git tag -a v' + version + ' -m "Framework version ' + version + '."')
  system('git push')
  system('git push --tags')
  publish(version)
end
