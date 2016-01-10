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

describe service('apt-cacher-ng') do
  it { should be_enabled }
  it { should be_running }
end

describe service('smartd'), :if => os[:release] == '15.10' do
  it { should be_enabled }
  it { should be_running }
end

describe service('smartmontools'), :if => os[:release] == '14.04' do
  it { should be_enabled }
  it { should be_running }
end

describe port('3142') do
  it { should be_listening.with('tcp') }
end
