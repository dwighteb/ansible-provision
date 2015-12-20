require 'spec_helper'

packages = [
  'anacron',
  'ansible',
  'apt-cacher-ng',
  'git',
  'smartmontools',
  'squid-deb-proxy-client',
  'vagrant',
  'virtualbox-5.0']

services = [
  'apt-cacher-ng',
  'smartmontools']

packages.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

services.each do |svc|
  describe service(svc) do
    it { should be_enabled }
    it { should be_running }
  end
end

describe ppa('ansible/ansible') do
  it { should exist }
  it { should be_enabled }
end

describe file('/etc/apt/sources.list.d/download_virtualbox_org_virtualbox_debian.list') do
  it { should exist }
  its(:content) { should match /deb http:\/\/download.virtualbox.org\/virtualbox\/debian/ }
end

describe port(3142) do
  it { should be_listening.with('tcp') }
end
