require 'spec_helper.rb'

# The MIT License (MIT)

# This serverspec ensures that
# - tls is configured in docker defaults file
# - certs and keys are present and valid (using openssl verify)
# - dockerd is listing on TLS port
# - there is no activity on docker socket
# - that a connection is TLS-secure 
# - that docker client can connect using TLS
# dependencies
# - openssl, lsof, netstat, docker client

#  This is a sample specification, it has to be adapted to
#  local paths and settings.

# Configuration ---------------
#
HOST_IP='10.0.2.15'
HOST_NAME='docker-server.local'				
CERT_PATH='/etc/docker-tls/certs'			# where certificates are
KEY_PATH='/etc/docker-tls/private'			# where keys are
CA_FILE='/etc/docker-tls/cacert.pem'
# file names of certs in CERT_PATH/
CLIENT_CERT_FILE='client-cert.pem'
SERVER_CERT_FILE='server-cert.pem'
# file names of keys in KEY_PATH/ 
CLIENT_KEY_FILE='client-key.pem'
SERVER_KEY_FILE='server-key.pem'
# certificate details to check for
CERT_ISSUER=/C=DE\/L=Berlin\/O=YourOrg.com/
SERVER_CERT_SUBJECT=/^subject=.*\/CN=docker-server.local/
CLIENT_CERT_SUBJECT=/^subject=.*\/CN=client/
# FLAG: should local socket be allowed or not
ALLOW_SOCKET=false
# -----------------------------


# check all files needed for TLS, client and server - keys and certs.
# run openssl to check validity
describe 'keys and certs should be present and valid' do
	[ SERVER_KEY_FILE, CLIENT_KEY_FILE ].each do |n|
		describe file "#{KEY_PATH}/#{n}" do
			it { should be_file }
			it { should be_owned_by 'root' }
			it { should be_grouped_into 'root' }
			it { should be_mode 640 }
		end

		describe command "openssl rsa -in #{KEY_PATH}/#{n} -check -noout" do 
			its(:stdout) { should match /^RSA key ok/ }
			its(:exit_status) { should be 0 }
		end
	end
	[ SERVER_CERT_FILE, CLIENT_CERT_FILE ].each do |n|
		describe file "#{CERT_PATH}/#{n}" do
			it { should be_file }
			it { should be_owned_by 'root' }
			it { should be_grouped_into 'root' }
			it { should be_mode 644 }
		end

		describe command "openssl x509 -in #{CERT_PATH}/#{n} -issuer -noout" do
			its(:stdout) { should match CERT_ISSUER }
			its(:exit_status) { should be 0 }
		end

		describe command "openssl verify -CAfile #{CA_FILE} #{CERT_PATH}/#{n}" do 
			its(:stdout) { should match /.*OK$/ }
			its(:exit_status) { should be 0 }
		end
	end

	describe 'Server key should match server cert' do
		describe command "(openssl x509 -noout -modulus -in #{CERT_PATH}/#{SERVER_CERT_FILE} | openssl md5 ; \
				   openssl rsa -noout -modulus -in #{KEY_PATH}/#{SERVER_KEY_FILE} | openssl md5 ) | \
					uniq | wc -l" do
			its(:stdout) { should match /^1$/ }
		end
	end

	describe 'Client key should match client cert' do
		describe command "(openssl x509 -noout -modulus -in #{CERT_PATH}/#{CLIENT_CERT_FILE} | openssl md5 ; \
				   openssl rsa -noout -modulus -in #{KEY_PATH}/#{CLIENT_KEY_FILE} | openssl md5 ) | \
					uniq | wc -l" do
			its(:stdout) { should match /^1$/ }
		end
	end

	describe 'Key subjects should be valid' do
		describe command "openssl x509 -in #{CERT_PATH}/#{SERVER_CERT_FILE} -subject -noout" do
			its(:stdout) { should match SERVER_CERT_SUBJECT }
			its(:exit_status) { should be 0 }
		end
		describe command "openssl x509 -in #{CERT_PATH}/#{CLIENT_CERT_FILE} -subject -noout" do
			its(:stdout) { should match CLIENT_CERT_SUBJECT }
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
		its(:content) { should match "-H=#{HOST_IP}:2376" }
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

if ALLOW_SOCKET == false then
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
		-host #{HOST_IP} \
		-port 2376 \
		-state \
		-cert #{CERT_PATH}/#{CLIENT_CERT_FILE} \
		-key #{KEY_PATH}/#{CLIENT_KEY_FILE} \
		-CAfile #{CA_FILE}" do

		its(:exit_status) { should be 0 }
		its(:stdout) { should match SERVER_CERT_SUBJECT }
                its(:stdout) { should match CERT_ISSUER }
		# ensure key strength
                its(:stdout) { should match /^Server public key is 4096 bit$/ }
		# ensure that out cert is written to server by looking at -state output
                its(:stdout) { should match /write client certificate/ }
                its(:stdout) { should match /write client key exchange/ }
	end
		
end

# finally ensure that docker client is able to call API successfully
describe 'it should respond to docker client using TLS' do
	describe command "DOCKER_HOST=tcp://#{HOST_NAME}:2376 docker \
			--tlsverify \
			--tlscacert=#{CA_FILE} \
			--tlscert=#{CERT_PATH}/#{CLIENT_CERT_FILE} \
			--tlskey=#{KEY_PATH}/#{CLIENT_KEY_FILE} \
			version" do
		its(:exit_status) { should eq 0 }
                its(:stdout) { should match /Server API version/ }
                its(:stdout) { should match /Server version/ }
	end
end


