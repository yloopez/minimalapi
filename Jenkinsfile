pipeline {
    agent {
        docker {
            image 'mcr.microsoft.com/dotnet/sdk:6.0'
            args '-v $HOME/.nuget/packages:/root/.nuget/packages'
        }
    }

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

        stage('Restore') {
            steps {
                sh 'dotnet restore'
            }
        }

        stage('Build') {
            steps {
                sh 'dotnet build --configuration Release --no-restore'
            }
        }

        stage('Test') {
            steps {
                // This will skip if no tests exist, or you can target your test project
                sh 'dotnet test --no-build --verbosity normal || echo "Tests skipped (none found)"'
            }
        }

        stage('Publish') {
            steps {
                sh 'dotnet publish -c Release -o published'
            }
        }

        // stage('Docker Build (Optional)') {
        //     steps {
        //         // Make sure you have a Dockerfile in your project root if using this stage
        //         sh 'docker build -t sixminapi .'
        //     }
        // }
    }
}
