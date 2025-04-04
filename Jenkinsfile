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
                bat 'python -m venv venv'
                bat 'call venv\\Scripts\\activate && python -m pip install --upgrade pip'
                bat 'call venv\\Scripts\\activate && pip install -r requirements.txt'
            }
        }

        stage('Test (Optional)') {
            steps {
                bat 'call venv\\Scripts\\activate && pytest || exit /b 0'
            }
        }

        stage('Package App') {
            steps {
                // Step 1: Clean up old publish folder (if exists)
                bat 'powershell -Command "Remove-Item -Recurse -Force publish -ErrorAction SilentlyContinue"'

                // Step 2: Create a new publish directory
                bat 'powershell -Command "New-Item -ItemType Directory -Path publish"'

                // Step 3: Copy all necessary files except ignored folders/files
                bat 'powershell -Command "Get-ChildItem -Exclude venv,publish,*.zip,.git,__pycache__ | ForEach-Object { Copy-Item $_.FullName -Destination publish -Recurse -Force }"'

                // Step 4: Create ZIP file from publish folder
                bat 'powershell -Command "Compress-Archive -Path publish\\* -DestinationPath publish.zip -Force"'
            }
        }


        stage('Deploy to Azure') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat 'az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%'
                    bat 'az webapp config set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --startup-file "python app.py"'
                    bat 'az webapp config appsettings set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true'
                    bat 'az webapp config appsettings set --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --settings PORT=8000'
                    bat 'az webapp deploy --resource-group %RESOURCE_GROUP% --name %APP_SERVICE_NAME% --src-path publish.zip --type zip'
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment Successful!'
        }
        failure {
            echo 'Deployment Failed. Check logs above.'
        }
    }
}
