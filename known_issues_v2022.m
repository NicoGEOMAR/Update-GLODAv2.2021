%% Updates for GLODAPv2.2022
clear all
close all

cd 'C:\Users\nlange\Desktop\GLODAP_merge_2021\data_products\adjusted'
load('GLODAPv2.2021_Merged_Master_File.mat')

%% "Bugs"

% Fill missing BTLNBRs: 
% 29AH20160617 (2011)
cd 'E:\GLODAPv2.2020_02202020\29AH20160617'
A=load('29AH20160617.mat');
A=struct2table(A);
A=sortrows(A,[68 16]);
cruise=find(G2cruise==2011);
G2bottle(cruise)=A.BTLNBR;

clear cruise A

% 29HE20190406 (2013)
cd 'E:\GLODAPv2.2020_02202020\29HE20190406'
A=load('29HE20190406.mat');
A=struct2table(A);
A=sortrows(A,[68 16]);
cruise=find(G2cruise==2013);
G2bottle(cruise)=A.BTLNBR;

clear cruise A

% Change flags for calculated TA of 316N19831007 (wrong flags from original file)
cruise=find(G2cruise==239);

for i=1:length(cruise)
    if G2talkf(cruise(i))==2
        G2talkf(cruise(i))=0;
    end
end
G2talkqc(cruise)=0;

clear i cruise
    

% 2nd QC flags for carbon (issue introduced due to fco2 inccoperated into carbon calculations)
ind_tco2=find(G2talkf~=2 & G2fco2f==2 & G2tco2f==2 & G2phts25p0f~=2);
ind_ta=find(G2talkf==2 & G2fco2f==2 & G2tco2f~=2 & G2phts25p0f~=2);
ind_ph=find(G2talkf~=2 & G2fco2f==2 & G2tco2f~=2 & G2phts25p0f==2);

G2talkqc(ind_tco2)=0;
G2phtsqc(ind_tco2)=0;
G2tco2qc(ind_ta)=0;
G2phtsqc(ind_ta)=0;
G2talkqc(ind_ph)=0;
G2tco2qc(ind_ph)=0;

clear ind*


%% 2nd QC updates

% Knorr cruises
cruises={'316N19950829','316N19951111','316N19951202','316N19950423','316N19950611','316N19950715',...
'316N19950310','316N19941201','316N19950124'};

% Adjustments based updon CRM comparisons
DIC=-[-3.17,-0.62,-0.97,-2.42,-1.99,-2.42,-1.72,-0.65,-1.33];
ALK=-[3.56,-1.99,3.64,2.02,6.06,7.65,-1.16,8.66,2.86];

% Use mean offset for all
DIC(:)=1.7;
ALK(:)=-3.5;

for i=1:length(cruises)
    
    holder=find(strcmp(cruises{i},expocode)==1);
    number=expocodeno(holder);
    cruise=find(G2cruise==number);
    G2talk(cruise)=G2talk(cruise)+ALK(i);
    G2tco2(cruise)=G2tco2(cruise)+DIC(i);
    
    % Recalculate ph and fCO2 and reassign WOCE flags
    [cos,~,~]=CO2SYS(G2talk(cruise),G2tco2(cruise),1,2,G2salinity(cruise),G2temperature(cruise),25,G2pressure(cruise),0,G2silicate(cruise),G2phosphate(cruise),2,10,1);
    G2phts25p0(cruise)=cos(:,18);
    clear cos
    [cos,~,~]=CO2SYS(G2talk(cruise),G2tco2(cruise),1,2,G2salinity(cruise),G2temperature(cruise),G2temperature(cruise),G2pressure(cruise),G2pressure(cruise),G2silicate(cruise),G2phosphate(cruise),2,10,1);
    G2phtsinsitutp(cruise)=cos(:,18);
    clear cos
    [cos,~,~]=CO2SYS(G2talk(cruise),G2tco2(cruise),1,2,G2salinity(cruise),G2temperature(cruise),20,G2pressure(cruise),0,G2silicate(cruise),G2phosphate(cruise),2,10,1);
    G2fco2(cruise)=cos(:,20);
    clear cos
    
    
    G2phts25p0f(cruise(find(~isnan(G2phts25p0(cruise)))))=0;
    G2phts25p0f(cruise(find(isnan(G2phts25p0(cruise)))))=9;
    G2phtsinsitutpf(cruise(find(~isnan(G2phtsinsitutp(cruise)))))=0;
    G2phtsinsitutpf(cruise(find(isnan(G2phtsinsitutp(cruise)))))=9;
    G2fco2f(cruise(find(~isnan(G2fco2(cruise)))))=0;
    G2fco2f(cruise(find(isnan(G2fco2(cruise)))))=9;
    
    clear number holder cruise cos
end

clear i DIC ALK cruises


% 49HG19960807 adjust pH an additional -0.05
cruise=find(G2cruise==433);
G2phts25p0(cruise)=G2phts25p0(cruise)-0.05;

% Recalculate phinsitu
data=[G2year(cruise),G2latitude(cruise),G2longitude(cruise),G2pressure(cruise),G2temperature(cruise),G2salinity(cruise),G2oxygen(cruise)];
SILCAT_ca=silcat_nncanyonb_bit18(data);
[holder,~,~]=CO2SYS(G2talk(cruise),G2phts25p0(cruise),1,3,G2salinity(cruise),25,G2temperature(cruise),0,G2pressure(cruise),SILCAT_ca,G2phosphate(cruise),2,10,1);
G2phtsinsitutp(cruise)=holder(:,18);

clear holder cruise SILCAT_ca data


% 49UP19970912 adjust O2 1.5% upward
cruise=find(G2cruise==574);
G2oxygen(cruise)=G2oxygen(cruise).*1.015;

clear cruise

%% SF6 2nd QC flags

SF6_Cruises=[26,55,57,58,62,63,64,263,273,295,307,324,329,330,345,346,347,355,434,435,461,631,...
    635,674,702,703,706,708,724,1002,1003,1005,1007,1008,1011,1012,1013,1014,1016,1020,1025,1026,1027,...
    1029,1033,1035,1036,1038,1040,1041,1042,1043,1044,1045,1046,1050,1051,1053,1054,1055,1103,1104,2003,...
    2005,2006,2008,2011,2020,2023,2026,2027,3002,3003,3004,3005,3029,3030,3031,3033,3034,3041,3042];

G2sf6qc=G2sf6;
G2sf6qc(:)=0;

for i=1:length(SF6_Cruises)
    ind=find(SF6_Cruises(i)==G2cruise);
    G2sf6qc(ind)=1;
    clear ind
end

clear i SF6_Cruises

% Adjust 10% upward: 06MT20091126 (1013) & 320620170820 (3030)
ind=find(G2cruise==1013 | G2cruise==3030);
G2sf6(ind)=G2sf6(ind)*1.1;
G2psf6(ind)=ppt_calc(G2theta(ind),G2salinity(ind),G2sf6(ind),2);
clear ind

% Adjust 20%upward: 49HG1997110 (434) & 49HG19980812 (435) & 320620170703 (3029)
ind=find(G2cruise==434 | G2cruise==435 | G2cruise==3029);
G2sf6(ind)=G2sf6(ind)*1.2;
G2psf6(ind)=ppt_calc(G2theta(ind),G2salinity(ind),G2sf6(ind),2);
clear ind

% Give QC-flag zero to cruises which couldn'nt be assessed (-888):
% 06MT20060712 (62) & 325020080826 (307)
ind=find(G2cruise==62 | G2cruise==307);
G2sf6qc(ind)=0;
clear ind

% Get rid of bad data (-777): 49K619990523 (461) & 58GS20090528 (635)
ind=find(G2cruise==461 | G2cruise==635);
G2sf6(ind)=NaN;
G2sf6f(ind)=9;
G2psf6(ind)=NaN;
clear ind

% Correct for "wrong" unit for 06M20081031 (1012)
ind=find(G2cruise==1012);
G2sf6(ind)=G2sf6(ind)*1000;
G2psf6(ind)=ppt_calc(G2theta(ind),G2salinity(ind),G2sf6(ind),2);
clear ind


% Correct 06M320150501 (1011)
ind=find(G2cruise==1011);
cd 'C:\Users\nlange\Desktop\06M320150501'
A=load('06M320150501.mat');
A=struct2table(A);
A=sortrows(A,[68 16]);

A.SF6(A.SF6_FLAG_W~=2 & A.SF6_FLAG_W~=6)=NaN;
A.SF6_FLAG_W(A.SF6_FLAG_W~=2 & A.SF6_FLAG_W~=6)=9;
A.SF6_FLAG_W(A.SF6_FLAG_W==6)=2;
A.CFC_12(A.CFC_12_FLAG_W~=2 & A.CFC_12_FLAG_W~=6)=NaN;
A.CFC_12_FLAG_W(A.CFC_12_FLAG_W~=2 & A.CFC_12_FLAG_W~=6)=9;
A.CFC_12_FLAG_W(A.CFC_12_FLAG_W==6)=2;


G2sf6(ind)=A.SF6;
G2sf6f(ind)=A.SF6_FLAG_W;
G2psf6(ind)=ppt_calc(G2theta(ind),G2salinity(ind),G2sf6(ind),2);

G2cfc12(ind)=A.CFC_12;
G2cfc12f(ind)=A.CFC_12_FLAG_W;
G2pcfc12(ind)=ppt_calc(G2theta(ind),G2salinity(ind),G2cfc12(ind),1);

clear A ind


%% Save interim updated file 
cd 'C:\Users\nlange\Desktop\GLODAP_merge_2022\python-for-glodap-master'
save('GLODAPv2.2021_updated_int.mat')

%% DOI and Expocode in file
clear all

A=load('GLODAPv2.2021_updated_int.mat');
for i=1:length(A.expocode)
    ind=find(A.G2cruise==A.expocodeno(i));
    A.G2expocode(ind)=A.expocode(i);
    A.G2doi(ind)=A.DOI(i);
end
A.G2expocode=A.G2expocode';
A.G2doi=A.G2doi';
clear ind i

%% Station M
A=rmfield(A,{'DOI','expocode','expocodeno'});
A=struct2table(A);
cd 'C:\Users\nlange\Desktop\GLODAP_merge_2022\processed_cruises'

vars={'index','STNNBR','CASTNO','BTLNBR','DATE','TIME','LATITUDE','LONGITUDE','DEPTH','CTDPRS','CTDTMP','CTDSAL','CTDSAL_FLAG_W','OXYGEN','OXYGEN_FLAG_W','SILCAT','SILCAT_FLAG_W','NITRAT','NITRAT_FLAG_W','PHSPHT','PHSPHT_FLAG_W','TCARBN','TCARBN_FLAG_W','ALKALI','ALKALI_FLAG_W','HOUR','MINUTE','YEAR','MONTH','DAY','SAMPNO','BTLNBR_FLAG_W','CTDDEP','SALNTY','SALNTY_FLAG_W','NITRIT','NITRIT_FLAG_W','NO2NO3','NO2NO3_FLAG_W','CTDOXY','CTDOXY_FLAG_W','PH_SWS','PH_SWS_FLAG_W','PH_TMP','PH_TMP_FLAG_W','PH_TS','PH_TS_FLAG_W','PH_TOT','PH_TOT_FLAG_W','PH','PH_FLAG_W','THETA','DOC','DOC_FLAG_W','CFC_11','CFC_11_FLAG_W','CFC_12','CFC_12_FLAG_W','CFC113','CFC113_FLAG_W','CCL4','CCL4_FLAG_W','SF6','SF6_FLAG_W','HELIUM','HELIUM_FLAG_W','HELIER','DELHE3','DELHE3_FLAG_W','DELHER','TRITUM','TRITUM_FLAG_W','TRITER','DELC13','DELC13_FLAG_W','NEON','NEON_FLAG_W','NEONER','DELO18','DELO18_FLAG_W','DELC14','DELC14_FLAG_W','C14ERR','TDN','TDN_FLAG_W','TOC','TOC_FLAG_W','DON','DON_FLAG_W','CHLORA','CHLORA_FLAG_W','PCO2','PCO2_FLAG_W','PCO2TMP','FCO2','FCO2_FLAG_W','FCO2_TMP','CRUISE','DEPTH_MAX','bottomdepth','SALNTY_2ndQC','OXYGEN_2ndQC','TCARBN_2ndQC','ALKALI_2ndQC','NITRAT_2ndQC','SILCAT_2ndQC','PHSPHT_2ndQC','CFC_11_2ndQC','CFC113_2ndQC','CCL4_2ndQC','CFC_12_2ndQC','SF6_2ndQC','DELC13_2ndQC','SILCAT_ca','PHSPHT_ca','TA_ca','PH_TOT_2ndQC','SIGMA0','SIGMA1','SIGMA2','SIGMA3','SIGMA4','GAMMA','AOU','AOU_FLAG_W','pCFC_12','pSF6','pCCL4','pCFC_11','pCFC113t','PH_TOT_ca','ALKALI_ca','TCARBN_ca','FCO2_ca','PH_IN_SITU','PH_IN_SITU_FLAG_W','DOI','region'};
opts = detectImportOptions('58P320011031.csv');
opts=setvaropts(opts,vars,'TreatAsMissing','-9999');
C=readtable('58P320011031.csv',opts);
clear vars

vars_old={'STNNBR','CASTNO','BTLNBR','LATITUDE','LONGITUDE','CTDPRS','CTDTMP','CTDDEP','SILCAT','SILCAT_FLAG_W','NITRAT','NITRAT_FLAG_W','NITRIT','NITRIT_FLAG_W','PHSPHT','PHSPHT_FLAG_W','TCARBN','TCARBN_FLAG_W','ALKALI','ALKALI_FLAG_W','PH_TOT','PH_TOT_FLAG_W','THETA','HOUR','MINUTE','YEAR','MONTH','DAY','SALNTY','SALNTY_FLAG_W','OXYGEN','OXYGEN_FLAG_W','DOC','DOC_FLAG_W','CFC_11','CFC_11_FLAG_W','CFC_12','CFC_12_FLAG_W','CFC113','CFC113_FLAG_W','CCL4','CCL4_FLAG_W','SF6','SF6_FLAG_W','HELIUM','HELIUM_FLAG_W','HELIER','DELHE3','DELHE3_FLAG_W','DELHER','TRITUM','TRITUM_FLAG_W','TRITER','DELC13','DELC13_FLAG_W','NEON','NEON_FLAG_W','NEONER','DELO18','DELO18_FLAG_W','DELC14','DELC14_FLAG_W','C14ERR','TDN','TDN_FLAG_W','TOC','TOC_FLAG_W','DON','DON_FLAG_W','CHLORA','CHLORA_FLAG_W','CRUISE','DEPTH_MAX','bottomdepth','SALNTY_2ndQC','OXYGEN_2ndQC','TCARBN_2ndQC','ALKALI_2ndQC','NITRAT_2ndQC','SILCAT_2ndQC','PHSPHT_2ndQC','CFC_11_2ndQC','CFC113_2ndQC','CCL4_2ndQC','CFC_12_2ndQC','DELC13_2ndQC','SF6_2ndQC','PH_TOT_2ndQC','SIGMA0','SIGMA1','SIGMA2','SIGMA3','SIGMA4','GAMMA','AOU','AOU_FLAG_W','pCFC_12','pSF6','pCCL4','pCFC_11','pCFC113t','PH_IN_SITU','PH_IN_SITU_FLAG_W','FCO2','FCO2_FLAG_W','FCO2_TMP','DOI','region'};
vars_G2={'G2station','G2cast','G2bottle','G2latitude','G2longitude','G2pressure','G2temperature','G2depth','G2silicate','G2silicatef','G2nitrate','G2nitratef','G2nitrite','G2nitritef','G2phosphate','G2phosphatef','G2tco2','G2tco2f','G2talk','G2talkf','G2phts25p0','G2phts25p0f','G2theta','G2hour','G2minute','G2year','G2month','G2day','G2salinity','G2salinityf','G2oxygen','G2oxygenf','G2doc','G2docf','G2cfc11','G2cfc11f','G2cfc12','G2cfc12f','G2cfc113','G2cfc113f','G2ccl4','G2ccl4f','G2sf6','G2sf6f','G2he','G2hef','G2heerr','G2he3','G2he3f','G2he3err','G2h3','G2h3f','G2h3err','G2c13','G2c13f','G2neon','G2neonf','G2neonerr','G2o18','G2o18f','G2c14','G2c14f','G2c14err','G2tdn','G2tdnf','G2toc','G2tocf','G2don','G2donf','G2chla','G2chlaf','G2cruise','G2maxsampdepth','G2bottomdepth','G2salinityqc','G2oxygenqc','G2tco2qc','G2talkqc','G2nitrateqc','G2silicateqc','G2phosphateqc','G2cfc11qc','G2cfc113qc','G2ccl4qc','G2cfc12qc','G2c13qc','G2sf6qc','G2phtsqc','G2sigma0','G2sigma1','G2sigma2','G2sigma3','G2sigma4','G2gamma','G2aou','G2aouf','G2pcfc12','G2psf6','G2pccl4','G2pcfc11','G2pcfc113','G2phtsinsitutp','G2phtsinsitutpf','G2fco2','G2fco2f','G2fco2temp','G2doi','G2region'};

ind=find(A.G2cruise==656);
ind_end=min(find(A.G2cruise==657));

B(1:ind(1)-1,:)=A(1:ind(1)-1,:);
for k=1:length(vars_old)
    B.(vars_G2{k})(ind(1):ind(1)+length(C.(vars_old{k}))-1)=C.(vars_old{k});
end
B.G2cruise(ind(1):ind(1)+size(C,1)-1)=656;
B(ind(1)+size(C,1):ind(1)+size(C,1)+length(A.G2cruise(ind_end:end))-1,:)=A(ind_end:end,:);

clearvars -except B

ind=find(B.G2cruise==656);
B.G2expocode(ind)={'58P320011031'};
clearvars -except B

cd 'C:\Users\nlange\Desktop\GLODAP_merge_2022\python-for-glodap-master'
load('GLODAPv2.2021_updated_int.mat','expocode','expocodeno','DOI')

vars=B.Properties.VariableNames;
for i=1:length(vars)
    str=strcat(vars{i},'=B.',vars{i},';');
    eval(str)
    clear str
end
clear i vars

save('GLODAPv2.2021_updated.mat')
run write_updated_mat_to_csv.m
