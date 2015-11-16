# Build with Amazon Web Services (AWS)
packer build -var 'aws_access_key=<AWS_KEY>' -var 'aws_secret_key=<AWS_SECRET_KEY>' -var 'vpc_id=<AWS_VPC>' -var 'subnet_id=<AWS_SUBNET>' <json file>

# Build with Digital Ocean (DO)
packer build -var 'api_token=<DO_TOKEN>' <json file>

Warning: those images should only be used in a demo environment. SSH pw authentication is a bad move as are the two "curl url | sh" calls. The internet is a dangerous place.
