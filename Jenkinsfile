pipeline {
    agent any

    environment {
        PYTHONPATH = '.'
        PATH_VENV = '/home/ubuntu/venv/bin'
        STACK_NAME = 'todo-list-aws-staging'
        REGION = 'us-east-1'
    }

    stages {
        stage('Get Code') {
            steps {
                git url: 'https://github.com/flaviooria/CI_CP1.3.git', branch: 'develop'
            }
        }

        stage('Static Test') {
            steps {
                sh '$PATH_VENV/flake8 --format=pylint ./src > flake8.out'
                recordIssues tools: [flake8(name: 'Flake8', pattern: 'flake8.out', reportEncoding: 'UTF-8')]
                
                sh '$PATH_VENV/bandit -r src -f custom -o bandit.out --msg-template "{abspath}:{line}: [{test_id}] {severity} {msg}"'
                recordIssues tools: [pyLint(name: 'Bandit', pattern: 'bandit.out')]
            }
        }

        stage('Deploy') {
            steps {
                sh 'sam build'
                sh 'sam validate --region us-east-1'
                sh 'sam deploy --config-file samconfig.toml --config-env staging sam deploy --no-confirm-changeset --no-fail-on-empty-changeset'

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
                sh '$PATH_VENV/pytest -s test/integration/todoApiTest.py'
            }
        }

        stage('Promote') {
            steps {
                sh'''
                git switch master
                git pull origin master
                ls -la
                '''
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}