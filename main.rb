# frozen_string_literal: true

require 'English'
require 'pathname'

def run_command(cmd)
  puts "@@[command] #{cmd}"
  `#{cmd}`
end

def bundler_version
  gemlock_path = Pathname.new('Gemfile.lock')
  if File.file?(gemlock_path)
    regex = /BUNDLED WITH\s+(\S+)/
    match = gemlock_path.read(mode: 'rt').match(regex)
    return match[1] if match && match.length > 1
  end
  nil
end

def run_danger(cmdline)
  if File.file?('Gemfile')
    puts('Running danger with bundler')
    run_command("gem install bundler --force --no-document --version #{bundler_version}") unless bundler_version.nil?
    run_command('bundle install')
    run_command("bundle exec danger #{cmdline}")
  else
    puts('Running danger directly')
    run_command("danger  #{cmdline}")
  end
end

cmdline = ''
danger_path = ENV['AC_DANGER_PATH']
repository_path = ENV['AC_REPOSITORY_DIR']
extra_args = ENV['AC_DANGER_EXTRA_PARAMETERS']
cmdline += "--dangerfile=#{danger_path}" unless danger_path.to_s.empty?
cmdline += " #{extra_args}" unless extra_args.to_s.empty?

Dir.chdir(repository_path) do
  run_danger(cmdline)
end
