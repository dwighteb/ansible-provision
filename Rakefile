task :default => :build_nat

desc 'Run ansible against nat instance'
task :build_nat do
  sh 'ansible-playbook playbook/site.yml -l openvpn -v --vault-password-file ~/.vault_pass.txt'
end

desc 'Provision ec2 instance'
task :build_ec2 do
  sh 'ansible-playbook playbook/ec2.yml -v --vault-password-file ~/.vault_pass.txt'
end

desc 'Run ansible against all systems'
task :build_all do
  sh 'ansible-playbook playbook/site.yml -v --vault-password-file ~/.vault_pass.txt'
end

desc 'Run ansible against dell systems'
task :build_dells do
  sh 'ansible-playbook playbook/site.yml -l dell -v --vault-password-file ~/.vault_pass.txt'
end

desc 'Run ansible against dell1'
task :build_dell1 do
  sh 'ansible-playbook playbook/site.yml --limit dell1.local -v --vault-password-file ~/.vault_pass.txt'
end

desc 'Run ansible against dell2'
task :build_dell2 do
  sh 'ansible-playbook playbook/site.yml --limit dell2.local -v --vault-password-file ~/.vault_pass.txt'
end
