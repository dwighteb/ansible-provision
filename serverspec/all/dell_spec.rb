require 'spec_helper'

packages = [
  'anacron',
  'ansible',
  'apt-cacher-ng',
  'git',
  'jenkins',
  'nginx',
  'openjdk-7-jdk',
  'openjdk-7-jre',
  'smartmontools',
  'squid-deb-proxy-client',
  'vagrant',
  'virtualbox-5.0']

services = [
  'apt-cacher-ng',
  'jenkins',
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

describe file('/etc/nginx/conf.d/jenkins.conf') do
  it { should exist }
  its(:content) { should match /server 127.0.0.1:8080/ }
end

['80', '3142'].each do |portno|
  describe port(portno) do
    it { should be_listening.with('tcp') }
  end
end

describe port('3142') do
  it { should be_listening.with('tcp') }
end

describe port('8080') do
  it { should be_listening.with('tcp6') }
end

describe user('jenkins') do
  it { should exist }
  its(:encrypted_password) { should match(/^.{0,2}$/) }
end
