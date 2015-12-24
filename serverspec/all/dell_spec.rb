require 'spec_helper'

packages = [
  'anacron',
  'apt-cacher-ng',
  'smartmontools',
  'squid-deb-proxy-client']

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

describe port('3142') do
  it { should be_listening.with('tcp') }
end
