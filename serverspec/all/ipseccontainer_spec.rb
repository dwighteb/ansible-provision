require 'spec_helper'

describe package('python-pip') do
  it { should be_installed }
end

describe package('docker-py') do
  it { should be_installed.by('pip') }
end

describe docker_image('dwighteb/ipsec-vpn-server') do
  it { should exist }
  its(['Architecture']) { should eq 'amd64' }
end

describe file('/home/ubuntu/vpn.env') do
  it { should exist }
  it { should be_owned_by 'root' }
  it { should be_mode 400 }
  its(:content) { should match /VPN_IPSEC_PSK/ }
end

describe file('/etc/modules-load.d/af_key.conf') do
  it { should exist }
  it { should be_owned_by 'root' }
  it { should be_mode 644 }
  its(:content) { should match /af_key/}
end

describe command ('lsmod | grep af_key') do
  its(:stdout) { should match /af_key/ }
end

describe docker_container('ipsec-vpn-server') do
  it { should exist }
  its(['HostConfig.Privileged']) { should eq true }
  # its(['HostConfig.PortBindings.4500/udp.HostPort']) { should eq '4500' }
  its(['HostConfig.RestartPolicy.Name']) { should eq 'always' }
  # its(['Mounts.Source']) { should eq '/lib/modules'}
end
