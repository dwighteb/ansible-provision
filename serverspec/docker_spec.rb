require 'spec_helper'

packages = [
  'apt-transport-https',
  'docker-engine',
  'linux-image-extra-virtual']

packages.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe service('docker') do
  it { should be_enabled }
  it { should be_running }
end

describe group('docker') do
  it { should exist }
end

['dwighteb','ubuntu'].each do |username|
  describe user(username) do
    it { should belong_to_group 'docker' }
  end
end

describe file('/etc/default/grub') do
  its(:content) { should match /GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/}
end
