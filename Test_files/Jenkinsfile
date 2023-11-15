pipeline {
    agent any 
    stages {
        stage('Build & Test'){
            matrix {
                agent {
                    label 'Windows'
                }
                
                axes {
                    axis {
                        name 'MATLAB_VERSION'
                        values 'R2022b'
                    }
                }
                
                tools{
                    matlab "${MATLAB_VERSION}"
                }
                
                stages {
                    stage('Run MATLAB Command') {
                        steps {
                            runMATLABCommand 'test'
                        }
                    }
                    
                    stage('Run MATLAB Test') {
                        steps {
                            runMATLABTests(testResultsJUnit: 'matlabTestArtifacts/junittestresults.xml', sourceFolder: ['matlabTestArtifacts'])
                        }
                    }
                }
            }
        }
    }
}
