pipeline {
   agent any
    environment {
        giturl = "https://gitlab.com/devops1447/skilrock-eks-iaac.git"
        gitBranch = "main"
        az1 = "a"
        az2 = "b"
        az3 = "c"
    }
    tools {
        terraform 'Terraform'
    }
    
  stages {
    stage('Checkout') {
      steps {
                    git branch: "${params.ClientName}",
                    //git branch: 'main',
                    credentialsId: 'gitlab',
                    url: "${env.giturl}"
            }
    }
    
    stage('Validating Client Name') {
      steps {
            script {
                    if (params.ClientName.isEmpty()) { 
                        currentBuild.result = 'ABORTED'
                        error("Client Name is empty")
                    }  
            }
            }
    }
    stage('Validating Client AWS Account ID') {
      steps {
            script {
                    if (params.ClientAWSAccountID.isEmpty()) { 
                        currentBuild.result = 'ABORTED'
                        error("ClientAWSAccountID is empty or wrong")
                    }
            }
            }
    }
    stage('Validating Cluster Name') {
      steps {
            script {
                    if (params.K8ClusterName.isEmpty() || params.K8ClusterName.length() >= 16) { 
                        currentBuild.result = 'ABORTED'
                        error("Kubernetenes Cluster is empty or length is greater then 15 char")
                    }
            }
            }
    }
    
    
    stage("Creating Values File") {
      steps {
                script {
                    sh '''
                    cat > $ClientName-$Environment.tfvars<<EOF
name                        = "$K8ClusterName"
environment                 = "$Environment"
region                      = "$AWSRegion"
availability_zones          = ["$AWSRegion$az1", "$AWSRegion$az3"]
cidr                        = "$CIDR"
private_subnets             = ["$PrivateSubnetAZ1", "$PrivateSubnetAZ2"]
public_subnets              = ["$PublicSubnetAZ1", "$PublicSubnetAZ2"]
kubeconfig_path             = "~/.kube"
k8s_version                 = "1.23"
EOF
                    '''
                }
            }
        }
    stage("Creating Provider File") {
       steps {
                script {
                    sh '''
                    cat > provider.tf<<EOF
provider "aws" {
  version = ">= 3.50"
  region  = var.region
  profile = "default"
  assume_role {
        role_arn     = "arn:aws:iam::$ClientAWSAccountID:role/Skilrock-Terraform"
    }
}
EOF
                    '''
                }
            }
        }
    stage('Saving Provider file in S3 Bucket') {
      steps {
          sh 'aws s3 cp "provider.tf" s3://skilrock-infrastructure-workspaces/$ClientName-$Environment.provider'
      }
     }

    stage('TF init') {
      steps {
          sh 'terraform init'
      }
     } 
    stage('TF Create workspace') {
        steps {
            script {
                if (params.NewWorkspace)
                {
                  sh 'echo $ClientName-$Environment'
                  sh 'terraform workspace new $ClientName-$Environment'
                }
                else {
                    sh "echo workspace already created"
                    
                }
            }
        }
     }
    stage('Select workspace') {
      steps {
          sh 'terraform workspace select $ClientName-$Environment'
      }
     }
     
    stage('Saving Workspace in S3 Bucket') {
      steps {
          sh 'aws s3 cp "$ClientName-$Environment.tfvars" s3://skilrock-infrastructure-workspaces'
      }
     }
     
    stage('TF Plan') {
      steps {
          sh 'terraform  plan -var-file="$ClientName-$Environment.tfvars" -out $ClientName-$Environment.tfplan'
      }
    }
    
    stage('Saving Plan File in S3 Bucket') {
      steps {
          sh 'aws s3 cp "$ClientName-$Environment.tfplan" s3://skilrock-infrastructure-workspaces'
      }
     }
     
    stage('Approval') {
      steps {
        script {
          def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
        }
      }
    }
    // stage('Setting k8') {
    //   steps {
    //       sh 'export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" $(aws sts assume-role --role-arn arn:aws:iam::521826328656:role/Sapidblue-Terraform --role-session-name PAYPR-Role --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" --output text))'
    //       sh 'aws sts get-caller-identity'
    //       sh 'sleep 10 &'
    //       sh 'aws eks update-kubeconfig --region us-east-1 --name PAYPR-KS-ks-cluster-all'
    //   }
    // }
    stage('TF Apply') {
       steps {
           //sh 'export KUBE_CONFIG_PATH=$HOME/.kube/config'
           sh 'terraform apply -var-file="$ClientName-$Environment.tfvars" --auto-approve -input=false'
       }
     }
    
    //stage('TF Destroy') {
      //steps {
         // sh 'terraform destroy -var-file="$ClientName-$Environment.tfvars" --auto-approve -input=false'
     // }
    //}
   
  }
    // post { 
    //     always { 
    //         cleanWs()
    //     }
    // }
}