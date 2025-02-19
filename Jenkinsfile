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
                sh 'wget -q -O samconfig.toml https://raw.githubusercontent.com/flaviooria/todo-list-aws-config/refs/heads/staging/samconfig.toml'
                sh 'cat samconfig.toml'
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
                sh "sam validate --region ${REGION}"
                sh 'sam deploy --config-file samconfig.toml --config-env staging --no-confirm-changeset --no-fail-on-empty-changeset'

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
                sh """
                git checkout master || git checkout -b master origin/master
                git pull origin master
                git merge develop --no-edit
                ls -la
                """

                script {
                    withCredentials([usernamePassword(credentialsId: 'gh_token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                        sh '''
                        git config user.name "Flavio Oria"
                        git config user.email "flavio.oriap@gmail.com"
                        git remote set-url origin https://$GIT_USER:$GIT_PASS@github.com/flaviooria/CI_CP1.3.git
                        git push origin master
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            deleteDir()
        }
    }
}