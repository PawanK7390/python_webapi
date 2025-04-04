pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS_ID = 'azure-service-principal-python'
        RESOURCE_GROUP = 'rg-jenkins'
        APP_SERVICE_NAME = 'pythonwebapijenkins8387963808'
        ZIP_FILE = 'publish.zip'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/PawanK7390/python_webapi.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                bat '''
                    python -m venv venv
                    call venv\\Scripts\\activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Run Tests (Optional)') {
            steps {
                bat '''
                    call venv\\Scripts\\activate
                    pytest || exit /b 0
                '''
            }
        }

        stage('Prepare Artifact') {
            steps {
                bat '''
                    powershell -Command "if (!(Test-Path publish)) { New-Item -ItemType Directory -Path publish }"
                    powershell -Command "Get-ChildItem -Exclude publish,venv -Recurse | Copy-Item -Destination publish -Recurse -Force"
                    powershell -Command "Compress-Archive -Path publish\\* -DestinationPath ${env.ZIP_FILE} -Force"
                '''
            }
        }

        stage('Deploy to Azure') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat """
                        az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%
                        az webapp config appsettings set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true
                        az webapp config appsettings set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --settings PORT=8000
                        az webapp deploy --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --src-path ${env.ZIP_FILE} --type zip
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment Successful!'
        }
        failure {
            echo '❌ Deployment Failed. Please check logs above.'
        }
    }
}
