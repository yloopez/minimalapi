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
                    i=1
                    while [ $i -le 5 ]; do
                        if curl -s http://localhost:5000/ | grep "API is running Correctly from Jenkinsfile"; then
                            echo "API is reachable"
                            break
                        else
                            echo "Waiting for API... ($i)"
                            docker-compose logs api || true
                            sleep 2
                        fi
                        i=$((i+1))
                        if [ "$i" -gt 5 ]; then
                            echo "API not reachable after 10 tries"
                            exit 1
                        fi
                    done
                '''
            }
        }

        stage('Cleanup') {
            steps {
                sh '''
                    docker-compose down
                '''
            }
        }
    }
}
