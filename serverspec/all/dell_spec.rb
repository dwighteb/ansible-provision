require 'spec_helper'

packages = [
  'anacron',
  'apt-cacher-ng',
  'apt-transport-https',
  'docker-engine',
  'linux-image-extra-virtual',
  'smartmontools',
  'squid-deb-proxy-client']

packages.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

['apt-cacher-ng','docker','smartd'].each do |services|
  describe service(services) do
    it { should be_enabled }
    it { should be_running }
  end
end

describe file('/etc/default/grub') do
  its(:content) { should match /GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/}
end

describe group('docker') do
  it { should exist }
end

describe port('3142') do
  it { should be_listening.with('tcp') }
end

['dwighteb','ubuntu'].each do |username|
  describe user(username) do
    it { should belong_to_group 'docker' }
  end
end
