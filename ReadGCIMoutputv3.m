function [GCIMoutput]=ReadGCIMoutputv3(GCIMoutput_filename)
% The function reading standard output file from the OpenSHA implementation file was downloaded from website of Professor Brendon A Bradely 
% https://sites.google.com/site/brendonabradley/research/ground-motion-selection

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Purpose: to read the standard output file from the OpenSHA implementation
%of the GCIM approach (as at 26 Sept 2013).

%version control:
%v1 - developed for PSHA-based hazard from GMPE-based SHA
%v2 - incorporated Scenario-based hazard from simulation-based SHA

%input variables:
%CIMoutput_filename -- a text file with the GCIM output data in the format
%produced by OpenSHA
%plots -- if ==1 then plots are produced
%alpha - if plots==1 then alpha is used for the KS bounds       
%   

%Output variables:
%GCIMoutput -- a structure with the following variables
% .numIMi -- the number of IMis for which GCIM distributions are computed
% .numz  -- the number of points used in the CDF of IMi
% .numIMiRealizations -- the number of realizations of the IMi's
% .Prob_IML_name -- a string with the Probability/IML level for which the
%           GCIM distributions and simulated IMi values are for
% .IML -- the IML for which GCIM distributions are computed
% .ProbLevel -- the exceedance probability corresponding to IML
% .IMiNames -- the names of the IMi's for which GCIM distributions and
%           realizations are computed
% .GCIM_IMiRealizationValues -- a (numIMiRealizations,numIMi,2) matrix which
%           contains the realizations of the IMi's.  (m,i,1) is the IMi value
%           for IM number i, from realization m. (m,i,2) is the standard
%           deviation of the conditional distribution of lnIMi|IMj,Rup
%           which should be used in the weighted least squares to determine
%           which ground motion record is the best match to the realization
% .GCIM_IMiValues - a (numz,2,numIMi) matrix containing the CDF's of the
%           IMi's. (k,1:2,i)=[IMivalue CDFvalue] are the IMi value and CDF
%           value for the kth empirical distribution point for IM number i.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%open the file
fid=fopen(GCIMoutput_filename,'r');
if fid<0
    fprintf('Error: could not open the file \n');
end

%first line is only a title
titleraw=fgetl(fid);
if (length(titleraw)>=24) %this is for backwards compatibility (will be removed in future versions)
    if (strcmp(titleraw(15:24),'Simulation')==1)
        simulationSHA=true;
    else
        simulationSHA=false;
    end
else
    simulationSHA=false;
end
%determine if PSHA or Scenario-based
IMj_name_raw=fgetl(fid);
if strcmp(IMj_name_raw(1:8),'Scenario')==1
    %Scenario-based
    scenarioSHA=true;
else
    scenarioSHA=false;
end

if scenarioSHA==true %Scenario-based case
    %read blank line - these will be filled in at some stage
    fgetl(fid);
    %read blank line
    fgetl(fid);
elseif scenarioSHA==false  %PSHA-based case
    %read the conditioning IM (if PSHA-based case)
    C = textscan(IMj_name_raw,strcat('%16c %',num2str(length(IMj_name_raw)-17),'c'),1);
    IMjName=cell2mat(C(2));
    %if IMj is SA then get the period
    IMjPeriod=-1;
    if IMjName(1:2)=='SA'
        C = textscan(IMjName,'%4c %f',1);
        IMjPeriod=cell2mat(C(2));
    end
    %now read the next 2 lines and then see if it is IML or Prob based
    Prob_IML_name1=fgetl(fid);
    Prob_IML_name2=fgetl(fid);
    C1 = textscan(Prob_IML_name1,'%6c %f',1);
    C2 = textscan(Prob_IML_name2,'%6c %f',1);
    if Prob_IML_name1(1:4)=='Prob';
        type=1;
        IML=cell2mat(C2(2)); ProbLevel=cell2mat(C1(2));
    else
        type=2;
        IML=cell2mat(C1(2)); ProbLevel=cell2mat(C2(4));
    end
end
    
%read blank line
fgetl(fid);
%get numIMi
C = textscan(fgetl(fid),'%28c %f',1); numIMi=cell2mat(C(2));
%get the number of z values for the GCIM distribution for each IMi
C = textscan(fgetl(fid),'%33c %f',1); numz=cell2mat(C(2));
%get the number of IMi realizations
C = textscan(fgetl(fid),'%29c %f',1); numIMiRealizations=cell2mat(C(2));


%read two blank lines
for i=1:2; fgetl(fid); end;

%read the GCIM CDFs for each IMi
GCIM_IMiValues = zeros(numz,2,numIMi);
IMiPeriods=-ones(numIMi,1);
for i=1:numIMi
    %read dashed line
    fgetl(fid);
    %get the name of IMi 
    IMiname_raw=fgetl(fid);
    C = textscan(IMiname_raw,strcat('%12c %',num2str(length(IMiname_raw)-12),'c'),1);
    iminame=cell2mat(C(2));
    IMiNames{i}=cell2mat(C(2));
    %if IMi is SA then get the vibration period
    if iminame(1:2)=='SA'
        C = textscan(iminame,'%4c %f',1);
        IMiPeriods(i)=cell2mat(C(2));
    end
    %now read the IMi and CDF values
    for j=1:numz
        dataline=strread(fgetl(fid));
        GCIM_IMiValues(j,1:2,i)=[dataline(1),dataline(2)];
    end
    %now read two blank lines
    for i=1:2; fgetl(fid); end;
end

%now read the realizations of the IMi's
GCIM_IMiRealizationValues = zeros(numIMiRealizations,numIMi,2);
for i=1:2; fgetl(fid); end; %two blank lines 
for m=1:numIMiRealizations
    dataline=strread(fgetl(fid));
    for i=1:numIMi
        GCIM_IMiRealizationValues(m,i,1)=[dataline(2*(i-1)+2)]; %IMi values
        GCIM_IMiRealizationValues(m,i,2)=[dataline(2*(i-1)+3)]; %stddev values
    end
end
%end of reading the GCIMoutput file
fclose(fid);

%output structure
GCIMoutput.simulationSHA=simulationSHA;
GCIMoutput.scenarioSHA=scenarioSHA;
if scenarioSHA==true
elseif scenarioSHA==false
    GCIMoutput.IMjName=IMjName;
    GCIMoutput.IMjPeriod=IMjPeriod;
    GCIMoutput.IML=IML;
    GCIMoutput.ProbLevel=ProbLevel;
end
GCIMoutput.numIMi=numIMi;
GCIMoutput.numz=numz;
GCIMoutput.numIMiRealizations=numIMiRealizations;
GCIMoutput.IMiNames=IMiNames;
GCIMoutput.IMiPeriods=IMiPeriods;
GCIMoutput.GCIM_IMiRealizationValues=GCIM_IMiRealizationValues;
GCIMoutput.GCIM_IMiValues=GCIM_IMiValues;
GCIMoutput.GCIMfilename=GCIMoutput_filename;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



