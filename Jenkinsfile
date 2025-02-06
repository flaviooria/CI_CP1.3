pipeline {
    agent any

    environment {
        PYTHONPATH = '.'
        FLASK_APP = 'app/api.py'
        PATH_VENV = '/home/ubuntu/venv/bin'
    }

    stages {
        stage('Get Code') {
            steps {
                git url: 'https://github.com/flaviooria/CI_CP1.3.git', branch: 'develop'
            }
        }

        stage('Static Test') {
            steps {

                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh '$PATH_VENV/flake8 --format=pylint --exit-zero ./src > flake8.out'

                    recordIssues tools: [flake8(name: 'Flake8', pattern: 'flake8.out', reportEncoding: 'UTF-8')]

                }

                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh '$PATH_VENV/bandit --exit-zero -r src -f custom -o bandit.out --msg-template "{abspath}:{line}: [{test_id}] {severity} {msg}"'

                    recordIssues tools: [pyLint(name: 'Bandit', pattern: 'bandit.out')]

                }
            }
        }

        stage('Deploy') {
            steps {
                sh 'sam deploy'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}