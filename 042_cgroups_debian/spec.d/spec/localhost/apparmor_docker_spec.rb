require 'spec_helper'

describe package('apparmor') do
  it { should be_installed }
end

describe package('apparmor-profiles') do
  it { should be_installed }
end

describe package('apparmor-utils') do
  it { should be_installed }
end

describe file '/usr/sbin/aa-status' do
  it { should be_executable }
end

describe command 'aa-status' do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /apparmor module is loaded/ }
  its(:stdout) { should match /docker-default/ }
end

describe file '/etc/apparmor.d/docker' do
  it { should be_file }
end


