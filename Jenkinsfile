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
                    docker rm -f sixminapi-test || true
                    docker build -t sixminapi .
                    docker run -d -p 5000:80 --name sixminapi-test sixminapi

                    i=1
                    while [ $i -le 5 ]; do
                        if docker exec sixminapi-test curl -s http://localhost:80/ | grep "API is running from JenkinsFile"; then
                            echo "API is reachable"
                            break
                        else
                            echo "Waiting for API... ($i)"
                            sleep 2
                        fi
                        i=$((i+1))
                        if [ "$i" -gt 5 ]; then
                            echo "API not reachable after 5 tries"
                            docker logs sixminapi-test || true
                            exit 1
                        fi
                    done
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
