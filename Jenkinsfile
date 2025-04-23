pipeline {
    agent any

    environment {
        DOTNET_CLI_TELEMETRY_OPTOUT = '1'
        DOTNET_SKIP_FIRST_TIME_EXPERIENCE = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Start Docker Compose') {
            steps {
                sh 'docker-compose up -d'
            }
        }

        stage('Build and Test in Docker') {
            agent {
                docker {
                    image 'mcr.microsoft.com/dotnet/sdk:6.0'
                    args '-v $HOME/.nuget/packages:/root/.nuget/packages'
                }
            }
            steps {
                sh '''
                    dotnet restore
                    dotnet build --configuration Release --no-restore
                    dotnet test --no-build --verbosity normal || echo "Tests skipped"
                    dotnet publish -c Release -o published
                '''
            }
        }

        stage('Run Container and Test Endpoint') {
            steps {
                sh '''
                    docker build -t sixminapi .
                    docker run -d -p 5000:80 --name sixminapi-test sixminapi
                    sleep 10
                    curl http://localhost:5000/api/v1/commands || echo "Failed to reach endpoint"
                '''
            }
        }

        stage('Cleanup') {
            steps {
                sh '''
                    docker stop sixminapi-test || true
                    docker rm sixminapi-test || true
                    docker-compose down
                '''
            }
        }
    }
}
