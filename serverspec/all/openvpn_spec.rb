require 'spec_helper'

describe package('openvpn'), :if => os[:family] == 'ubuntu' do
  it { should be_installed }
end

describe service('openvpn'), :if => os[:family] == 'ubuntu' do
  it { should be_enabled }
  it { should be_running }
end

describe process('openvpn'), :if => os[:family] == 'ubuntu' do
  it { should be_running }
  its(:user) { should eq 'openvpn' }
end

describe port(443) do
  it { should be_listening.with('tcp') }
end

[443, 1194].each do |portno|
  describe port(portno) do
    it { should be_listening.with('udp') }
  end
end

['/etc/openvpn/crl-clients.pem',
 '/etc/openvpn/dh2048.pem',
 '/etc/openvpn/nat1.key',
 '/etc/openvpn/ta.key'].each do |filename|
  describe file(filename) do
    it { should exist }
    it { should be_owned_by 'openvpn' }
    it { should be_grouped_into 'openvpn' }
    it { should be_mode 600 }
  end
end

['/etc/openvpn/ca-clients.crt',
 '/etc/openvpn/nat1.crt'].each do |filename|
  describe file(filename) do
    it { should exist }
    it { should be_owned_by 'openvpn' }
    it { should be_grouped_into 'openvpn' }
    it { should be_mode 644 }
  end
end

['/etc/openvpn/server-1194-udp.conf',
 '/etc/openvpn/server-443-tcp.conf',
 '/etc/openvpn/server-443-udp.conf'].each do |filename|
  describe file(filename) do
    it { should exist }
    it { should be_owned_by 'openvpn' }
    it { should be_grouped_into 'openvpn' }
    it { should be_mode 640 }
    its(:content) { should match /tls-version-min 1.2/ }
  end
end

describe file('/etc/openvpn/ccd/dd-wrt1.atl.dwighteb.com') do
  it { should exist }
  it { should be_owned_by 'openvpn' }
  it { should be_grouped_into 'openvpn' }
  it { should be_mode 644 }
  its(:content) { should_not match /iroute 192.168.64.0 255.255.252.0/ }
  its(:content) { should match /iroute 192.168.69.0 255.255.255.0/ }
end

describe file('/etc/rc.local') do
  its(:content) { should match /\/usr\/local\/bin\/configure-pat.sh/ }
end

describe file('/usr/local/bin/configure-pat.sh') do
  it { should match exist }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 755 }
end

describe file('/usr/local/etc/blackhole') do
  it { should match exist }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 644 }
  its(:content) { should match /43.229.53.86/ }
end

describe interface('eth0') do
  it { should be_up }
end

['tun0', 'tun1', 'tun2'].each do |tunnel|
  describe interface(tunnel) do
    it { should exist }
  end
end

describe user('openvpn') do
  it { should exist }
  it { should have_uid 999 }
  it { should have_login_shell '/usr/sbin/nologin' }
  its(:encrypted_password) { should match(/^.{0,2}$/) }
end
