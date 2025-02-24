pipeline {
    agent any

    environment {
        PYTHONPATH = '.'
        PATH_VENV = '/home/ubuntu/venv/bin'
        STACK_NAME = 'todo-list-aws-production'
        REGION = 'us-east-1'
    }

    stages {
        stage('Get Code') {
            steps {
                git url: 'https://github.com/flaviooria/CI_CP1.3.git', branch: 'master'
                sh 'wget -q -O samconfig.toml https://raw.githubusercontent.com/flaviooria/todo-list-aws-config/refs/heads/production/samconfig.toml'
                sh 'cat samconfig.toml'
            }
        }

        stage('Deploy') {
            steps {
                sh 'sam build'
                sh 'sam validate --region ${REGION}'
                sh 'sam deploy --config-file samconfig.toml --config-env production --no-confirm-changeset --no-fail-on-empty-changeset'

                script {
                    def apiUrl = sh(script: """
                        sam list stack-outputs --stack-name ${STACK_NAME} --region ${REGION} --output json | jq -r '.[] | select(.OutputKey=="BaseUrlApi") | .OutputValue'
                    """, returnStdout: true).trim()

                    env.BASE_URL = apiUrl
                    echo "API BASE_URL: ${env.BASE_URL}"
                }
            }
        }

        stage('Rest Test') {
            steps {
                sh '$PATH_VENV/pytest -s -m get test/integration/todoApiTest.py'
            }
        }
    }

    post {
        always {
            deleteDir()
        }
    }
}