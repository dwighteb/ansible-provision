require 'spec_helper'

packages = [
  'acpid',
  'fail2ban',
  'libpam-google-authenticator',
  'logcheck',
  'mutt',
  'ntp',
  'openssh-server',
  'sysstat']

packages.each do |pkg|
  describe package(pkg), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
  end
end

describe package('python-gamin'), :if => os[:release] <= '14.04' do
  it { should be_installed }
end

services = [
  'fail2ban',
  'ntp',
  'ssh']

services.each do |svc|
  describe service(svc), :if => os[:family] == 'ubuntu' do
    it { should be_enabled }
    it { should be_running }
  end
end

describe service('acpid'), :if => os[:release] <= '14.04' do
  it { should be_enabled }
  it { should be_running }
end

describe port(22) do
  it { should be_listening.with('tcp') }
end

describe 'Filesystems should have less than 80% of inodes in use' do
  host_inventory['filesystem'].each do |_, filesystem_attributes|
    describe command('/bin/df -iP ' + filesystem_attributes['mount'] + ' | /usr/bin/tail -n1 | awk \'{print $5}\''), if: filesystem_attributes['mount'] !~ %r{^(/dev$|/run$|/dev/shm$|/run/lock$|/sys/fs/cgroup$|/run/cgmanager/fs$|/run/user/)} do
      its(:stdout) { is_expected.to match /^([0-9]|[0-7][0-9])%/ }
    end
  end
end

describe file('/etc/fail2ban/jail.local'), :if => os[:release] >= '15.10' do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  its(:content) { should match /^backend = auto/ }
end

describe file('/etc/fail2ban/jail.local'), :if => os[:release] <= '14.04' do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  its(:content) { should match /^backend = gamin/ }
end

describe file('/etc/fail2ban/jail.d/recidive.conf') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
end

describe file('/etc/pam.d/sshd') do
  its(:content) { should match /^auth required pam_google_authenticator.so/ }
end

describe file('/etc/ssh/sshd_config') do
  its(:content) { should match /^ChallengeResponseAuthentication yes/ }
  its(:content) { should match /^PasswordAuthentication yes/ }
  its(:content) { should match /^PermitRootLogin no/ }
  its(:content) { should match /^UseDNS no/ }
end

describe file('/etc/default/sysstat') do
  its(:content) { should match /^ENABLED=true/ }
end

describe file('/home/dwighteb/.google_authenticator') do
  it { should exist }
  it { should be_mode 400 }
  its(:md5sum) { should eq '39e3f98dc27a1bc6b18c9beb52acfe07' }
end

describe file('/home/ubuntu/.google_authenticator') do
  it { should exist }
  it { should be_mode 400 }
  its(:md5sum) { should eq 'c5a8ef51b36c090ec24d48c9756a9399' }
end

['www.google.com', 'www.yahoo.com'].each do |hostname|
  describe host(hostname) do
    it { should be_reachable.with(:port => 80) }
  end
end

describe user('dwighteb') do
  it { should exist }
  it { should have_uid 1100 }
  it { should have_login_shell '/bin/bash' }
  it { should have_home_directory '/home/dwighteb' }
  its(:encrypted_password) { should match(/^\$6\$.{8,16}\$.{86}$/) }
end

['root', 'vagrant'].each do |username|
  describe user(username) do
    it { should exist }
    its(:encrypted_password) { should match(/^.{0,2}$/) }
  end
end

describe user('ubuntu') do
  it { should exist }
  it { should have_login_shell '/bin/bash' }
  it { should have_home_directory '/home/ubuntu' }
  its(:encrypted_password) { should match(/^\$6\$.{8,16}\$.{86}$/) }
end
