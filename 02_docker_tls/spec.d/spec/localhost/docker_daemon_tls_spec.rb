require 'spec_helper.rb'

# The MIT License (MIT) andreas@de-wiring.net

# This serverspec ensures that
# - tls is configured in docker defaults file
# - certs and keys are present and valid (using openssl verify)
# - dockerd is listing on TLS port
# - there is no activity on docker socket (tls only)
# - that a connection is TLS-secure (using openssl s_client) 
# - that docker client can connect using TLS (using docker client)
# dependencies
# - openssl, lsof, netstat, docker client

#  This is a sample specification, it has to be adapted to
#  local paths and settings.

# Configuration ---------------
#
docker_tls_config = {
	:host_ip		=>	'10.0.2.15',
	:host_name		=>	'docker-server.local',				
	:cert_path		=>	'/etc/docker-tls/certs',			# where certificates are
	:key_path		=>	'/etc/docker-tls/private',			# where keys are
	:ca_file		=>	'/etc/docker-tls/cacert.pem',
	# file names of certs in CERT_PATH/
	:client_cert_file	=>	'client-cert.pem',
	:server_cert_file	=>	'server-cert.pem',
	# file names of keys in KEY_PATH/ 
	:client_key_file	=>	'client-key.pem',
	:server_key_file	=>	'server-key.pem',
	# certificate details to check for
	:cert_issuer		=>	/C=DE\/L=Berlin\/O=YourOrg.com/,
	:server_cert_subject	=>	/^subject=.*\/CN=docker-server.local/,
	:client_cert_subject	=>	/^subject=.*\/CN=client/,
	# FLAG: should local socket be allowed or not
	:allow_socket		=>	false,
	# ensure key strength
	:server_key_bits	=>	4096
}
# -----------------------------

describe 'This spec needs to run as root' do
	describe command "id -u" do
		its(:stdout) { should match /^0$/ }
	end
end


# check all files needed for TLS, client and server - keys and certs.
# run openssl to check validity
describe 'keys and certs should be present and valid' do
	[ docker_tls_config[:server_key_file], docker_tls_config[:client_key_file]].each do |n|
		describe file "#{docker_tls_config[:key_path]}/#{n}" do
			it { should be_file }
			it { should be_owned_by 'root' }
			it { should be_grouped_into 'root' }
			it { should be_mode 640 }
		end

		describe command "openssl rsa -in #{docker_tls_config[:key_path]}/#{n} -check -noout" do 
			its(:stdout) { should match /^RSA key ok/ }
			its(:exit_status) { should be 0 }
		end
	end
	[ docker_tls_config[:server_cert_file], docker_tls_config[:client_cert_file] ].each do |n|
		describe file "#{docker_tls_config[:cert_path]}/#{n}" do
			it { should be_file }
			it { should be_owned_by 'root' }
			it { should be_grouped_into 'root' }
			it { should be_mode 644 }
		end

		describe command "openssl x509 -in #{docker_tls_config[:cert_path]}/#{n} -issuer -noout" do
			its(:stdout) { should match docker_tls_config[:cert_issuer] }
			its(:exit_status) { should be 0 }
		end

		describe command "openssl verify -CAfile #{docker_tls_config[:ca_file]} #{docker_tls_config[:cert_path]}/#{n}" do 
			its(:stdout) { should match /.*OK$/ }
			its(:exit_status) { should be 0 }
		end
	end

	describe 'Server key should match server cert' do
		describe command "(openssl x509 -noout -modulus -in #{docker_tls_config[:cert_path]}/#{docker_tls_config[:server_cert_file]} | openssl md5 ; \
				   openssl rsa -noout -modulus -in #{docker_tls_config[:key_path]}/#{docker_tls_config[:server_key_file]} | openssl md5 ) | \
					uniq | wc -l" do
			its(:stdout) { should match /^1$/ }
		end
	end

	describe 'Client key should match client cert' do
		describe command "(openssl x509 -noout -modulus -in #{docker_tls_config[:cert_path]}/#{docker_tls_config[:client_cert_file]} | openssl md5 ; \
				   openssl rsa -noout -modulus -in #{docker_tls_config[:key_path]}/#{docker_tls_config[:client_key_file]} | openssl md5 ) | \
					uniq | wc -l" do
			its(:stdout) { should match /^1$/ }
		end
	end

	describe 'Key subjects should be valid' do
		describe command "openssl x509 -in #{docker_tls_config[:cert_path]}/#{docker_tls_config[:server_cert_file]} -subject -noout" do
			its(:stdout) { should match docker_tls_config[:server_cert_subject]}
			its(:exit_status) { should be 0 }
		end
		describe command "openssl x509 -in #{docker_tls_config[:cert_path]}/#{docker_tls_config[:client_cert_file]} -subject -noout" do
			its(:stdout) { should match docker_tls_config[:client_cert_subject] }
			its(:exit_status) { should be 0 }
		end
	end
end

# check defaults configuration file for settings to be present
# does not mean that they're effective, but at least thats needed.
describe 'it should have TLS configured in defaults file' do
	describe file('/etc/default/docker') do 
		its(:content) { should match '--tlsverify' }
		its(:content) { should match '--tlscacert=[a-zA-Z_0-9\/]+' }
		its(:content) { should match '--tlscert=[a-zA-Z_0-9\/]+' }
		its(:content) { should match '--tlskey=[a-zA-Z_0-9\/]+' }
		its(:content) { should match "-H=#{docker_tls_config[:host_ip]}:2376" }
		its(:content) { should_not match '-H=0\.0\.0\.0' }
	end
end

# basic check for port to be listening, NOT on 0.0.0.0
describe 'it should be running on specific port/ip' do

	describe port 2376 do
 		it { should be_listening }
	end
	
	# netstat-based	
	describe command 'netstat -nltp' do
		its(:stdout) { should match '[0-9\.]+:2376.*docker' }
		its(:stdout) { should_not match '0\.0\.0\.0:2376.*docker' }
	end

	# lsof based
	describe command 'lsof -n -i :2376' do
		its(:stdout) { should match 'docker.*[0-9\.]+:2376.*LISTEN' }
		its(:stdout) { should_not match 'docker.*0\.0\.0\.0:2376.*LISTEN' }
	end

end

if docker_tls_config[:allow_socket]== false then
	# use lsof to ensure no activity on socket even if there
	# is a socket.
	describe 'it should NOT be running on docker socket' do
	
		# extra check
		describe command 'test -S /var/run/docker.sock && lsof /var/run/docker.sock' do
			its(:stdout) { should_not match /^docker.*docker.sock$/ }
			its(:stdout) { should match /^$/ }
		end
	end
else
	# ensure that socket exists and is active
	describe 'it should be running on docker socket' do
	
		describe file '/var/run/docker.sock' do
			it { should be_socket }
		end
	
		# extra check
		describe command 'test -S /var/run/docker.sock && lsof /var/run/docker.sock' do
			its(:stdout) { should match /^docker.*docker.sock$/ }
			its(:stdout) { should_not match /^$/ }
		end
	end
end

# use openssl s_tunnel to check that TLS port is enabled with our certificate
describe 'it should be running on secured TLS port' do
	describe command "echo '' | \
		openssl s_client \
		-showcerts  \
		-host #{docker_tls_config[:host_ip]} \
		-port 2376 \
		-state \
		-cert #{docker_tls_config[:cert_path]}/#{docker_tls_config[:client_cert_file]} \
		-key #{docker_tls_config[:key_path]}/#{docker_tls_config[:client_key_file]} \
		-CAfile #{docker_tls_config[:ca_file]}" do

		its(:exit_status) { should be 0 }
		its(:stdout) { should match docker_tls_config[:server_cert_subject] }
                its(:stdout) { should match docker_tls_config[:cert_issuer] }
		# ensure key strength
                its(:stdout) { should match /^Server public key is #{docker_tls_config[:server_key_bits]} bit$/ }
		# ensure that out cert is written to server by looking at -state output
                its(:stdout) { should match /write client certificate/ }
                its(:stdout) { should match /write client key exchange/ }
		# look for recent cipher suites 
		its(:stdout) { should match /Protocol.*:.*TLSv1.2/ }
	end
		
end

# finally ensure that docker client is able to call API successfully
describe 'it should respond to docker client using TLS' do
	describe command "DOCKER_HOST=tcp://#{docker_tls_config[:host_name]}:2376 docker \
			--tlsverify \
			--tlscacert=#{docker_tls_config[:ca_file]} \
			--tlscert #{docker_tls_config[:cert_path]}/#{docker_tls_config[:client_cert_file]} \
			--tlskey #{docker_tls_config[:key_path]}/#{docker_tls_config[:client_key_file]} \
			version" do
		its(:exit_status) { should eq 0 }
                its(:stdout) { should match /Server API version/ }
                its(:stdout) { should match /Server version/ }
	end
end


