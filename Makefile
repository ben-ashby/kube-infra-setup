up:
	cd infra && terraform init
	cd infra &&	terraform apply --auto-approve

down:
	cd infra && terraform destroy --auto-approve

kube-create-cluster:
	kops create cluster --state=s3://$(shell cd infra && terraform output kops_state_bucket_name) --name=rmit.k8s.local --zones="us-east-1a,us-east-1b" --master-size=t2.small --node-size=t2.small --node-count=1 --yes

kube-secret:
	kops create secret --state=s3://$(shell cd infra && terraform output kops_state_bucket_name) --name rmit.k8s.local sshpublickey admin -i ~/keys/ec2-key.pub

kube-delete-cluster:
	aws iam detach-role-policy --role-name nodes.rmit.k8s.local --policy-arn arn:aws:iam::aws:policy/AdministratorAccess | echo "hack"
	kops delete cluster --state=s3://$(shell cd infra && terraform output kops_state_bucket_name) rmit.k8s.local --yes

kube-deploy-cluster:
	kops update cluster --state=s3://$(shell cd infra && terraform output kops_state_bucket_name) rmit.k8s.local --yes
	aws iam attach-role-policy --role-name nodes.rmit.k8s.local --policy-arn arn:aws:iam::aws:policy/AdministratorAccess | echo "Hack"

kube-validate:
	kops validate cluster --state=s3://$(shell cd infra && terraform output kops_state_bucket_name)

kube-config:
	kops export kubecfg --state=s3://$(shell cd infra && terraform output kops_state_bucket_name)

ssh-gen:
	mkdir -p ~/keys
	yes | ssh-keygen -t rsa -b 2048 -f ~/keys/ec2-key -P ''
	chmod 0644 ~/keys/ec2-key.pub
	chmod 0600 ~/keys/ec2-key