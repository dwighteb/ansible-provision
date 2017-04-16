require 'spec_helper'

packages = [
  'acpid',
  'git',
  'ntp',
  'openssh-server',
  'sysstat']

packages.each do |pkg|
  describe package(pkg), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
  end
end

services = [
  'ntp',
  'ssh']

services.each do |svc|
  describe service(svc), :if => os[:family] == 'ubuntu' do
    it { should be_enabled }
    it { should be_running }
  end
end

describe port(22) do
  it { should be_listening.with('tcp') }
end

describe "Google Authenticator configured correctly" do
  describe package('libpam-google-authenticator') do
    it { should be_installed }
  end

  describe file('/etc/pam.d/sshd') do
    its(:content) { should match /^auth required pam_google_authenticator.so/ }
  end

  describe file('/etc/ssh/sshd_config') do
    its(:content) { should match /^ChallengeResponseAuthentication yes/ }
    its(:content) { should match /^PasswordAuthentication yes/ }
  end

  describe file('/home/ubuntu/.google_authenticator') do
    it { should exist }
    it { should be_mode 400 }
    its(:md5sum) { should eq 'ed27c9b45c68b6650f9388a12d23f894' }
  end
end

describe file('/etc/ssh/sshd_config') do
  its(:content) { should match /^PermitRootLogin no/ }
  its(:content) { should match /^UseDNS no/ }
end

describe file('/etc/default/sysstat') do
  its(:content) { should match /^ENABLED=true/ }
end

describe user('ubuntu') do
  it { should exist }
  it { should have_login_shell '/bin/bash' }
  it { should have_home_directory '/home/ubuntu' }
  it { should have_authorized_key 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEcL268vOj9Q5/2jRch6fulX/x7QsJ17zk3RA/yVyi/zxKdoIhvj6s4ioCiq4ojmEM2lRoC412adJDnab2uOVPmXoTi/vky3eMkV2EzFfWaJJgL+sC6cLFS6iYTLbwiHlo5RK9UWt19+E8qc3DUpKVCBPpjKYFe6AqyVYmsVh9AKZzRFwwHS6JABa90W3CQDUQSFdmq0yvgcuSZ0h5k7SJ24Dj1mM6K5deizvOkCfNsPDSSGN3qEKXLUPAckSdongmhGflW5asQunQ6or7gNx4ukSgUdPGD1AVH3djGNlCYJjYBAzchXN+0NgXEuZtxRe+sG3AGGtRYprId2a3OCM0RDeQr08vPmNzUpu+EWYE+2LHGLCK5GJMLb1hVo0JpjEGUmu7t4849x6Pj16YZXKfmbjQUchtPCIuIUIVEnyoWh2P6NC4j3mjNJEyCDuaNg4HfGAOaMXn+xgbyhRbVNRoPGJwFSxIDPagDAFGKm8PfLi4kAJKuDmDWKfMwUiWPqfiaR+gwrV1oM+BU6a5bvrdPysli8lP7aak4LE9dZE/v3zmZhPjvAlgDelXmNsoCqoRFo3FJt8RPhtLPaN2heofZoo9+0Ep9IBipVluJHr6T8IcTDAgLTMdmiaC8rPAaRyBC1DcZQfmtg/mcReRbX1AcuGSLhAeR2QQhdv2UJEpOQ== dwighteb@20160709.mbp3' }
  it { should_not have_authorized_key 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKRdlc3uNB9Y+GadVPp/7BMfYgMAo1aI2ynbt2R6hnLFtliEonSa7nRU8IGPM1wfx80ki+kbcAeQm7gLUCYZx0EevwGQnEi8B08TRJ0jWgFYdymJcq8H2yFU1FyEkrZhbHLhS9QfiHvDc5/rO7q4Tpn+o0+lYfLCErGLztzGe8C+j8sky9TOsiBoYsinQVMnmo/P99wYXKnezf/b0IOgZozJgAbUWL3S0hJ/Y4GP2wUkR5xE9Oh8c34x7/T3Y4FQsQ9dUEDhN9EhosqdcR8yc5FdiPq+ppCcFgHeplX6oUdBdyj0VSBsk1vC5lhkRzx9vljWDrqe6Al9VipPBEKSawLrkzqDsg5YkkUqu8YpkpbnnAFuQAr7dIRtC7y3EHMF0RpTkrKOUlxNF/sZtWuISdnKUKkBY7YmbjDj/7Li/3k+Mxpfo4awEUuLoPp835jPGvxB9yZ4NyZPGcgmfkBWievY8rDlh9u46iR+Qg90NEJJtNJJehKBic6RuWHYO7N+WCFX1plImS1l7AQeQbrm84iX9aDDnuVQPfhy3L4QDhSRxYmGUzFihbgH8EN7bvYQsoVLsUkf+8mWpySoSvk3+RKzWtia5usSUJUhJGLqw/AU/2BYUTF6P6M9Rdd2c3GP4WN6ASLL6uYYJmtL+ZJqU6Zc8cv9e5sRdFfLR/sl82XQ== db-ipad-2017-02-18' }
  it { should have_authorized_key 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+pyYOeUUV9+yV3p3Wi0hajHmDQOSvUgJFfD6pjAQSwN/dDp3JEqKzML+9MJuLJgJfUQQT7jE6oJHm0kc/7/7vx3XHU930ZOR8EEsWjSILrKfbSJqsl2Xh8QFLiPHN+FpDQ4bEN1CWXRYRBk5kWheolfeaHUvZZ2XsQP3K/+g2nrXbva0TmjRE9hQmeGgrK1Fodsz68EkSNvWdn57fCeIS/iXU1d68oEl2p+rac9O+iM4Xb0cgUT2XJuaNsj1unLOzX6pg3febgMH5GgWY8oYkvtR11Buf2FrZnBk0mYdPv+W47i7YDs8biQr543+8jSpOUhtGuSkw/1kdh0+Fq9YtGv/0aFzlFNxxjOKgKwCTYzyrHWLAiPhUM4xh1D5jmysC9VxcwYwnREVPQl1fO+J122ThLy4wxhcsY4f0cRtFsItGFmjVv5oO6Z9RCZznnmaM2serzyC5GrplhuMrSPIjSItTr5G2EJh8mSeAx+6jbv/jS71xtG/MQbqZ8Oz/llQuDZbD85Z03l6kuYxUyajFkwwvQVg8BDlW/RWVXzr64gsGGKbQoxB4Op2VdYmAkAzPPYKv0YV4VA26S4dEWGXhwDUgM89IoZs7sstMa0ifcF+AdT+n8yRHxFltiNWzg1160b0cHGj5THLm6CbEdzHyVP1TgIPUu1X8RcXEFBzDfw== db-iphone-2017-02-18' }
  it { should have_authorized_key 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDoCsZFu50NpO4/CVLjDA5pKNAcdh4U66kfjiNwgyueik7dy2cGTzIbHNaO5hlBJDKussUcmY1DM6XnJW28Bq+t4xbOpY6vfYjDzMq4KyUc7NSRcVrBR/PKW3uv6aIfuFRDnGyde1MXJkoMaZHZkAcsTUuUmcAtCkXlX8GXBc++hmrplMZTtunb8DhGzrw+Jgmax7RGaP/kt6e6tQCsZ1EpuGwnuJ73UmUwQ5g/ZjcMKygrRu84W30MMki2ubz6tyVk70imV0vUvjUBU6N8IrvKbHDWgiVFLDa0ix8GznwYv87i3qhCc5JvQ47A6ImTb3kIYNcqYzSWZYgezkLOaWCToAR1Evqs/su9PJo2e3r75uMzt4BuFQR7b7FZch7Ma4v863NPJId1h/IhGtkJ313yawcn+2auklf26jq72CLBgNBEYSsWLJ5qMbZGlD69YF8Z6gpO71DwOWNoEGj72ugXczkw/tBbWiImRoWzvSy/I7goGY/LUsj2TXtMerd9wyNhYJNd8gdpMFGIvEMhpfkwrzQEweyvoZpiDlWMOtf1ikR7/AVzpCkcaNpJtv6A4ALK1ae6oJs3fgur8hs3KJxk8G3TjTtoQ0+HhuDFx0zVySAOj6E4u596QVe27PAXPRAU421E7E0bT8nGYkGmJmtKT3Dy7CaXFf5T7BgKo4AgMw== db-ipad-2017-04-16' }
  its(:encrypted_password) { should match(/^\$6\$.{8,16}\$.{86}$/) }
end
