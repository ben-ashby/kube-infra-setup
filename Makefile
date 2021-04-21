up:
	cd infra && terraform init
	cd infra &&	terraform apply --auto-approve

down:
	cd infra && terraform destroy --auto-approve

kube-create-cluster:
	kops create cluster --state=s3://$(shell cd infra && terraform output kops_state_bucket_name) --name=rmit.k8s.local --zones=us-east-1a --master-size=t3.medium --yes

kube-secret:
	kops create secret --state=s3://$(shell cd infra && terraform output kops_state_bucket_name) --name rmit.k8s.local sshpublickey admin -i ~/keys/ec2-key.pub

kube-down:
	kops delete cluster --state=s3://$(shell cd infra && terraform output kops_state_bucket_name) rmit.k8s.local --yes

kube-deploy-cluster:
	kops update cluster --state=s3://$(shell cd infra && terraform output kops_state_bucket_name) rmit.k8s.local --yes

kube-validate:
	kops validate cluster --state=s3://$(shell cd infra && terraform output kops_state_bucket_name)

kube-config:
	kops export kubecfg --state=s3://$(shell cd infra && terraform output kops_state_bucket_name) --admin

ssh-gen:
	mkdir -p ~/keys
	yes | ssh-keygen -t rsa -b 4096 -f ~/keys/ec2-key -P ''
	chmod 0644 ~/keys/ec2-key.pub
	chmod 0600 ~/keys/ec2-key