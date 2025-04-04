pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS_ID = 'azure-service-principal-python'
        RESOURCE_GROUP = 'rg-jenkins'
        APP_SERVICE_NAME = 'pythonwebapijenkins8387963808'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/PawanK7390/python_webapi.git'
            }
        }

        // ---------- TERRAFORM ----------
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    bat 'terraform init'
                }
            }
        }

        stage('Terraform Plan and Apply') {
            steps {
                dir('terraform') {
                    bat 'terraform plan -out=tfplan'
                    bat 'terraform apply -auto-approve tfplan'
                }
            }
        }

        // ---------- PYTHON SETUP ----------
        stage('Setup Python Environment') {
            steps {
                bat 'python -m venv venv'
                bat 'call venv\\Scripts\\activate'
                bat 'call venv\\Scripts\\activate && pip install --upgrade pip'
                bat 'call venv\\Scripts\\activate && pip install -r requirements.txt'
            }
        }

        // ---------- PACKAGE APP ----------
        stage('Package Application') {
            steps {
                bat 'powershell -Command "Remove-Item -Recurse -Force publish -ErrorAction SilentlyContinue"'
                bat 'powershell -Command "New-Item -ItemType Directory -Path publish"'
                bat 'powershell -Command "Copy-Item -Path app.py, requirements.txt, startup.txt -Destination publish -Force"'
                bat 'powershell -Command "Compress-Archive -Path publish\\* -DestinationPath publish.zip -Force"'
            }
        }

        // ---------- DEPLOY TO AZURE ----------
        stage('Deploy to Azure') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    // Login to Azure
                    bat 'az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%'

                    // Set app settings
                    bat 'az webapp config appsettings set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true'
                    bat 'az webapp config appsettings set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --settings WEBSITES_PORT=8000'
                    bat 'az webapp config appsettings set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --settings STARTUP_COMMAND="python app.py"'

                    // Deploy the zip package
                    bat 'az webapp deployment source config-zip --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --src publish.zip'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment Successful!'
        }
        failure {
            echo '❌ Deployment Failed. Check logs above.'
        }
    }
}
