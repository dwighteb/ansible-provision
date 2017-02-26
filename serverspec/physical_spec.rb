require 'spec_helper'

packages = [
  'anacron',
  'avahi-daemon',
  'smartmontools']

packages.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

['avahi-daemon', 'smartd'].each do |services|
  describe service(services) do
    it { should be_enabled }
    it { should be_running }
  end
end
