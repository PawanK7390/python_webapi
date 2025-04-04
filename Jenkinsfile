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
                bat 'python -m venv venv'
                bat 'call venv\\Scripts\\activate && pip install --upgrade pip'
                bat 'call venv\\Scripts\\activate && pip install -r requirements.txt'
            }
        }

        stage('Run Tests (Optional)') {
            steps {
                bat 'call venv\\Scripts\\activate && pytest || exit /b 0'
            }
        }

        stage('Prepare Artifact') {
            steps {
                bat 'powershell -Command "Remove-Item publish -Recurse -Force -ErrorAction SilentlyContinue"'
                bat 'powershell -Command "New-Item -ItemType Directory -Path publish -Force"'
                bat 'powershell -Command "Get-ChildItem -Recurse -Directory | Where-Object { $_.Name -notin @(\'venv\', \'publish\') } | ForEach-Object { Copy-Item $_.FullName -Destination publish -Recurse -Force }"'
                bat 'powershell -Command "Get-ChildItem -File | ForEach-Object { Copy-Item $_.FullName -Destination publish -Force }"'
                bat 'powershell -Command "Compress-Archive -Path publish\\* -DestinationPath publish.zip -Force"'
            }
        }

        stage('Deploy to Azure') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat 'az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%'
                    bat 'az webapp config appsettings set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true'
                    bat 'az webapp config appsettings set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --settings PORT=8000'
                    bat 'az webapp deploy --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --src-path %ZIP_FILE% --type zip'
                }
            }
        }
    }

    post {
        success {
            echo ' Deployment Successful!'
        }
        failure {
            echo ' Deployment Failed. Please check logs above.'
        }
    }
}
