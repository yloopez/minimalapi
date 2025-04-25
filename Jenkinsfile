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
                dir('SixMinApi') {
                    sh 'docker-compose down --volumes || true'
                    sh 'docker-compose build --no-cache'
                    sh 'docker-compose up -d'
                }
            }
        }

        stage('Apply EF Migrations') {
            agent {
                docker {
                    image 'mcr.microsoft.com/dotnet/sdk:6.0'
                    args '-v $HOME/.nuget/packages:/root/.nuget/packages'
                }
            }
            environment {
                ConnectionStrings__SQLDbConnection = "Server=sqlserver;Database=CommandDb;User Id=sa;Password=pa55w0rd!;TrustServerCertificate=True"
            }
            steps {
                dir('SixMinApi') {
                    sh '''
                        echo "Waiting for SQL Server to be ready..."
                        for i in {1..10}; do
                            if docker exec $(docker ps -qf "name=sixminapi-sqlserver-1") /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "pa55w0rd!" -Q "SELECT 1" > /dev/null 2>&1; then
                                echo "SQL Server is ready."
                                break
                            else
                                echo "SQL Server not ready yet... ($i)"
                                sleep 5
                            fi
                        done

                        echo "Applying EF Core Migrations..."
                        dotnet tool install --global dotnet-ef --version 6.0.26
                        export PATH="$PATH:/root/.dotnet/tools"
                        dotnet ef database update --project SixMinApi.csproj
                    '''
                }
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
                    dotnet restore SixMinApi.sln
                    dotnet build SixMinApi.sln --configuration Release --no-restore
                    dotnet test SixMinApi.sln -c Release --no-build --verbosity normal || echo "Tests failed"
                    rm -rf SixMinApi/published
                    dotnet publish SixMinApi/SixMinApi.csproj -c Release -o SixMinApi/published
                '''
            }
        }

        stage('Run Container and Test Endpoint') {
            steps {
                dir('SixMinApi') {
                    sh '''
                        set -e
                        i=1
                        while [ $i -le 10 ]; do
                            echo "🔍 Checking container health (attempt $i)..."
                            container_id=$(docker ps -qf "name=sixminapi-api-1")
                            if [ -z "$container_id" ]; then
                                echo "API container not found!"
                                exit 1
                            fi

                            response=$(docker exec "$container_id" curl -s http://localhost:80/)
                            echo "Response: $response"

                            if echo "$response" | grep "API is running Correctly!"; then
                                echo "API is reachable"
                                break
                            else
                                echo "Waiting for API... ($i)"
                                docker-compose logs --tail=20 api || true
                                sleep 2
                            fi
                            i=$((i+1))
                        done

                        if [ "$i" -gt 10 ]; then
                            echo "API not reachable after 10 tries"
                            exit 1
                        fi

                        echo "Hitting /api/v1/commands endpoint..."
                        docker exec "$container_id" curl -s http://localhost:80/api/v1/commands
                    '''
                }
            }
        }

         stage('Security Scan') {
            agent {
                docker {
                    image 'mcr.microsoft.com/dotnet/sdk:6.0'
                }
            }
            steps {
                sh '''
                    echo "Running Security Scan on NuGet dependencies..."
                    dotnet restore SixMinApi.sln
                    dotnet list SixMinApi/SixMinApi.csproj package --vulnerable || true
                '''
            }
        }

        stage('SonarQube Analysis') {
            agent {
                docker {
                    image 'mcr.microsoft.com/dotnet/sdk:6.0'
                }
            }
            environment {
                SONAR_SCANNER_OPTS = "-Xmx512m"
                DOTNET_TOOLS_DIR = "/root/.dotnet/tools"
                PATH = "/root/.dotnet/tools:$PATH"
            }
            steps {
                withSonarQubeEnv('LocalSonar') {
                    sh '''
                        apt-get update && apt-get install -y openjdk-17-jre
                        dotnet tool install --global dotnet-sonarscanner
                        export PATH="$DOTNET_TOOLS_DIR:$PATH"
                        $DOTNET_TOOLS_DIR/dotnet-sonarscanner begin /k:"SixMinApi" /d:sonar.login=$SONAR_AUTH_TOKEN
                        dotnet build SixMinApi.sln
                        $DOTNET_TOOLS_DIR/dotnet-sonarscanner end /d:sonar.login=$SONAR_AUTH_TOKEN
                    '''
                }
            }
        }

        stage('Cleanup') {
            steps {
                dir('SixMinApi') {
                    sh 'docker-compose down'
                }
            }
        }
    }
}
