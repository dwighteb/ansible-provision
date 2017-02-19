require 'spec_helper'

describe file('/etc/modules-load.d/af_key.conf') do
  it { should exist }
  it { should be_owned_by 'root' }
  it { should be_mode 644 }
  its(:content) { should match /af_key/}
end

describe command ('lsmod | grep af_key') do
  its(:stdout) { should match /af_key/ }
end

describe file('/usr/bin/dockercloud-agent') do
  it { should exist }
end

describe group('docker') do
  it { should exist }
end

['dwighteb','ubuntu'].each do |username|
  describe user(username) do
    it { should belong_to_group 'docker' }
  end
end
