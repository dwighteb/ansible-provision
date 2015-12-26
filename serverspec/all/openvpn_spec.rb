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
  it { should be_listening.with('udp') }
end

['/etc/openvpn/crl-clients.pem',
 '/etc/openvpn/nat2.key',
 '/etc/openvpn/ta.key'].each do |filename|
  describe file(filename) do
    it { should exist }
    it { should be_owned_by 'openvpn' }
    it { should be_grouped_into 'openvpn' }
    it { should be_mode 600 }
  end
end

['/etc/openvpn/ca-clients.crt',
 '/etc/openvpn/dh4096.pem',
 '/etc/openvpn/nat2.crt'].each do |filename|
  describe file(filename) do
    it { should exist }
    it { should be_owned_by 'openvpn' }
    it { should be_grouped_into 'openvpn' }
    it { should be_mode 644 }
  end
end

['/etc/openvpn/server-443-tcp.conf',
 '/etc/openvpn/server-443-udp.conf'].each do |filename|
  describe file(filename) do
    it { should exist }
    it { should be_owned_by 'openvpn' }
    it { should be_grouped_into 'openvpn' }
    it { should be_mode 640 }
    its(:content) { should match /^tls-version-min 1.2/ }
    its(:content) { should match /^auth SHA256/ }
    its(:content) { should match /^dh dh4096.pem/ }
  end
end

describe file('/etc/rc.local') do
  its(:content) { should match /\/usr\/local\/bin\/configure-pat.sh/ }
end

describe file('/usr/local/bin/configure-pat.sh') do
  it { should match exist }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 755 }
  its(:content) { should_not match /iptables -A INPUT -i eth0 -p tcp -m tcp --dport 80 -j ACCEPT/ }
end

describe interface('eth0') do
  it { should be_up }
end

['tun0', 'tun1'].each do |tunnel|
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
