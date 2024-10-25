properties([
        parameters([
            choice(
                choices: ['dev'], // Include all environments
                name: 'Environment'
            ),
            choice(
                choices: ['plan', 'apply', 'destroy'], 
                name: 'Terraform_Action'
            )
        ])
])
pipeline {
    agent any
    // environment {
    //     AWS_REGION = 'us-west-2' // Specify your AWS region
    //     TF_VAR_rds_password = credentials('rds_password') // Reference your Jenkins credential for RDS password
    // }
    options {
        // Set build timeout (optional)
        timeout(time: 1, unit: 'HOURS')
        // Enable build discarding to keep the workspace clean
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    stages {
        stage('Checkout') {
            steps {
                // Clone the repository
                git branch: 'main', url: 'https://github.com/DevOps-AWS-123/ec2-deploy-spring-boot-app.git'
            }
        }
        stage('Terraform Init') {
            steps {
                // Initialize Terraform
                sh 'terraform init'
            }
        }
        stage('Terraform Action') {
            steps {
                script {
                    def environment = params.Environment
                    def action = params.Terraform_Action
                    def varFile = "terraform.${environment}.tfvars"

                    if (action == 'plan') {
                        // Plan Terraform
                        sh "terraform plan -var-file=${varFile}"
                    } else if (action == 'apply') {
                        // Apply Terraform changes
                        sh "terraform apply -auto-approve -var-file=${varFile}"
                    } else if (action == 'destroy') {
                        // Destroy Terraform resources
                        input 'Approve Terraform Destroy?'
                        sh "terraform destroy -auto-approve -var-file=${varFile}"
                    }
                }
            }
        }
    }
    post {
        always {
            // Archive Terraform state files
            archiveArtifacts artifacts: '**/terraform.tfstate', fingerprint: true
            // Clean up workspace if necessary
            cleanWs()
        }
        success {
            // Notify on success (optional)
            echo 'Terraform action completed successfully!'
        }
        failure {
            // Notify on failure (optional)
            echo 'Terraform action failed.'
        }
    }
}