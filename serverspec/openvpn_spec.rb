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
  it { should be_listening.with('udp') }
end

['/etc/openvpn/crl.pem',
 '/etc/openvpn/server.key',
 '/etc/openvpn/ta.key'].each do |filename|
  describe file(filename) do
    it { should exist }
    it { should be_owned_by 'openvpn' }
    it { should be_grouped_into 'openvpn' }
    it { should be_mode 600 }
  end
end

['/etc/openvpn/ca.crt',
 '/etc/openvpn/dh4096.pem',
 '/etc/openvpn/server.crt'].each do |filename|
  describe file(filename) do
    it { should exist }
    it { should be_owned_by 'openvpn' }
    it { should be_grouped_into 'openvpn' }
    it { should be_mode 644 }
  end
end

describe file('/etc/openvpn/server-443-udp.conf') do
  it { should exist }
  it { should be_owned_by 'openvpn' }
  it { should be_grouped_into 'openvpn' }
  it { should be_mode 640 }
  its(:content) { should match /^tls-version-min 1.2/ }
  its(:content) { should match /^auth SHA256/ }
  its(:content) { should match /^dh dh4096.pem/ }
  its(:content) { should match /^remote-cert-tls client/ }
end

describe file('/etc/openvpn/server-443-tcp.conf') do
  it { should_not exist }
end

describe file('/etc/openvpn/server-443-udp.conf') do
  its(:content) { should_not match /^status openvpn-status-443-udp.log/ }
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

describe file('/lib/systemd/system/openvpn@.service') do
  its(:content) { should match /After\s?=\s?network.target network-online.target/ }
end

describe interface('eth0') do
  it { should be_up }
end

describe interface('tun0') do
  it { should exist }
end

describe user('openvpn') do
  it { should exist }
  it { should have_uid 999 }
  it { should have_login_shell '/usr/sbin/nologin' }
  its(:encrypted_password) { should match(/^.{0,2}$/) }
end
