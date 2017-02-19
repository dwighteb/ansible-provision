require 'spec_helper'

packages = [
  'anacron',
  'apt-cacher-ng',
  'smartmontools',
  'squid-deb-proxy-client']

packages.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

['apt-cacher-ng','smartd'].each do |services|
  describe service(services) do
    it { should be_enabled }
    it { should be_running }
  end
end

describe port('3142') do
  it { should be_listening.with('tcp') }
end
