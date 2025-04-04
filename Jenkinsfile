pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS_ID = 'azure-service-principal-python'
        RESOURCE_GROUP = 'rg-jenkins'
        APP_SERVICE_NAME = 'pythonwebapijenkins8387963808'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/PawanK7390/python_webapi.git'
            }
        }

        stage('Setup Python Environment') {
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
                    pytest
                '''
            }
        }

        stage('Package App') {
            steps {
                bat '''
                    powershell -Command "Compress-Archive -Path * -DestinationPath publish.zip -Force"
                '''
            }
        }

        stage('Deploy to Azure') {
            steps {
                withAzureCLI(credentialsId: AZURE_CREDENTIALS_ID) {
                    bat '''
                        az webapp deployment source config-zip --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --src publish.zip
                        
                        REM Set startup command to run FastAPI after deployment
                        az webapp config set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --startup-file "uvicorn main:app --host 0.0.0.0 --port 8000"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment Successful! '
        }
        failure {
            echo 'Deployment Failed. Check logs above. '
        }
    }
}

