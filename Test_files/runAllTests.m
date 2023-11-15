import matlab.unittest.TestRunner;
import matlab.unittest.plugins.DiagnosticsOutputPlugin;
import sltest.plugins.MATLABTestCaseIntegrationPlugin;
import sltest.plugins.TestManagerResultsPlugin;
import sltest.plugins.ToTestManagerLog;
import sltest.plugins.ModelCoveragePlugin;
import sltest.plugins.coverage.CoverageMetrics;
import sltest.plugins.coverage.ModelCoverageReport;
import sltest.testmanager.importResults;
import sltest.plugins.coverage.ModelCoverageReport;
import matlab.unittest.plugins.codecoverage.CoberturaFormat;
import matlab.unittest.TestSuite;
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.Verbosity;
import matlab.unittest.plugins.XMLPlugin;
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.plugins.CodeCoveragePlugin;
import matlab.unittest.plugins.codecoverage.CoverageReport;
import matlab.unittest.plugins.TAPPlugin;
import matlab.unittest.plugins.ToFile;

proj = openProject('Requirements_Model.prj');
open_system('Wiper_Model.slx');
%open_system('Wiper_Req_Harness.slx');
myLinkSet = slreq.load('Matlab_Req_Test_File.slmx');
slreq.clear;
[myLinkSet,myReqSet] = slreq.load('Wiper_Model.slx');
sltestmgr; 
%testFile = sltest.testmanager.load('Requirements_Wiper.mldatx'); 


testfile = fullfile('Requirements_Wiper.mldatx'); %Importing the mldatx file
sltest.testmanager.view; %Viewing the Test Manager
sltest.testmanager.load(testfile); %Loading the Test file to Test Manager
suite = testsuite('Matlab_Req_Test_File.mldatx'); % Creating a Suite
mj = TestRunner.withTextOutput('OutputDetail', Verbosity.Detailed ); %Creating a Test Runner

%To Generate a Pdf result
pdfFile = 'mjreport.pdf';
trp = TestReportPlugin.producingPDF(pdfFile);
mj.addPlugin(trp); %Adding pdf report generator plugin to runner

%Adding Test Manager Results to the MATLAB Test Report.
tmr = TestManagerResultsPlugin; 
mj.addPlugin(tmr); %Adding Test Manager Report Generator plugin to runner

%Outputting plugin outputs to the F14Output.tap file.
tapFile = 'mjreport.tap';
tap = TAPPlugin.producingVersion13(ToFile(tapFile));
mj.addPlugin(tap); %Adding tap report generator plugin to runner

%Running the Tests
result = mj.run(suite);

%Initializing Model Coverage Results for Continuous Integration
con_test = sltest.testmanager.TestFile('Test_Files\Matlab_Req_Test_File.mldatx');
apsuite = testsuite(con_test.FilePath);

%Using the Same Test Runner for Continuous Integration.
cmet = CoverageMetrics('Decision',true); %Including the Coverage Metrics - Decision

%Setting the Coverage Result Properties. Generating the xml files
rptfile = 'mj.xml';
rpt = CoberturaFormat(rptfile)

%Create a model coverage plugin. The plugin collects the coverage metrics and produces the Cobertura format report.
mcp = ModelCoveragePlugin('Collecting',cmet,'Producing',rpt)

%Adding Coverage to the Test Runner
mj.addPlugin(mcp);

% Turn off command line warnings:
warning off Stateflow:cdr:VerifyDangerousComparison
warning off Stateflow:Runtime:TestVerificationFailed

%Running the Tests
Results = mj.run(apsuite);

%Reenable warnings
warning on Stateflow:cdr:VerifyDangerousComparison
warning on Stateflow:Runtime:TestVerificationFailed

%addpath(genpath('Test_files'));

%suite = testsuite(pwd, 'IncludeSubfolders', true);

%[~,~] = mkdir('matlabTestArtifacts');

%runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Detailed );
%runner.addPlugin(TestReportPlugin.producingHTML('testReport'));
%runner.addPlugin(TAPPlugin.producingVersion13(ToFile('matlabTestArtifacts/taptestresults.tap')));
%runner.addPlugin(XMLPlugin.producingJUnitFormat('matlabTestArtifacts/junittestresults.xml'));
%runner.addPlugin(CodeCoveragePlugin.forFolder({'Test_files'}, 'IncludingSubfolders', true, 'Producing', CoverageReport('covReport', ...
%   'MainFile','index.html')));

%results = runner.run(testCase);

% Generate Zip files
% zip('covReport.zip','covReport');
nfailed = nnz([results.Failed]);
assert(nfailed == 0, [num2str(nfailed) ' test(s) failed.']);
