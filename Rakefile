require 'rake'
require 'rspec/core/rake_task'

task :spec    => 'spec:all'
task :default => :spec

namespace 'ansible' do
  desc 'Run ansible against mac-mini system'
  task 'mac-mini' do
    sh 'ansible-playbook playbook/site.yml -l mac-mini -v --vault-password-file ~/.vault_pass.txt -i ~/ansible.hosts'
  end

  desc 'Provision ec2 instance'
  task :ec2 do
    sh 'ansible-playbook playbook/ec2.yml -v --vault-password-file ~/.vault_pass.txt -i ~/ansible.hosts'
  end

  desc 'Run ansible against dell systems'
  task :dell do
    sh 'ansible-playbook playbook/site.yml -l dell -v --vault-password-file ~/.vault_pass.txt -i ~/ansible.hosts'
  end
end

namespace :spec do
  targets = []
  Dir.glob('./spec/*').each do |dir|
    next unless File.directory?(dir)
    target = File.basename(dir)
    target = "_#{target}" if target == "default"
    targets << target
  end

  task :all     => targets
  task :default => :all

  targets.each do |target|
    original_target = target == "_default" ? target[1..-1] : target
    desc "Run serverspec tests to #{original_target}"
    RSpec::Core::RakeTask.new(target.to_sym) do |t|
      ENV['TARGET_HOST'] = original_target
      t.pattern = "spec/#{original_target}/*_spec.rb"
    end
  end
end
