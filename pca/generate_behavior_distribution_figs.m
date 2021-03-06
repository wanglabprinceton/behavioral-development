% This script generates figures for all of the metrics and PCA
% distributions generated by ks_analysis.m
% 
% Originally in: ../2016-04-12 - behavior pca - the separability awakens 
%   or:  ../2016-04-18_ksAnalysis

%% Setup
% Let's start clean :)
clear, clc, close all

% Add dependencies to the path
addpath(genpath('deps'))

% Analysis data generated by ks_analysis.m
ksAnalysisPath = 'data/2017-08-31-ks_analysis.mat';

% Figures output paths
figsAllPath = 'figs/ks_all';
figsSigPath = 'figs/ks_significant';
if ~exists(figsAllPath); mkdir(figsAllPath); end
if ~exists(figsSigPath); mkdir(figsSigPath); end

%% Find analysis hits
load(ksAnalysisPath)

% Arbitrary but just for initial screening
alpha = 0.05; % significance threshold
minDelta = 0.1; % change in means

% Filter
isSignificant = kstable.p < alpha & abs(kstable.DeltaMu) > minDelta;
significant = sortrows(kstable(isSignificant, :), {'Region', 'Age', 'Assay', 'p'});

printf('*Significant observations* (alpha = %g, minDeltaMu = %g):', alpha, minDelta)
disp(significant)

%% Raw metrics (metrics with original units)
allPath = ff(figsAllPath,'raw');
sigPath = ff(figsSigPath,'raw');
if ~exists(allPath); mkdir(allPath); end
if ~exists(sigPath); mkdir(sigPath); end

for i = 1:height(kstable)
    % Pull out hit
    X = table2struct(kstable(i,:));
    
    % Skip PCs
    if contains(X.VarName,'_PC'); continue; end
    
    % Plot
    plotRaw(X.Data, X.VarName)
    painters % smooth rendering for vector export
    
    % Save
    figName = sprintf('%s_%s_%s', X.VarName, X.Age, X.Region);
    export_fig(ff(allPath, figName),'-png','-eps') 
    
    % Save significant
    if isSignificant(i)
        export_fig(ff(sigPath, figName),'-png','-eps')
    end
    
    % Close fig
    close(gcf)
end

%% Normalized metrics (z-scored raw and PCs)
allPath = ff(figsAllPath,'normalized');
sigPath = ff(figsSigPath,'normalized');
if ~exists(allPath); mkdir(allPath); end
if ~exists(sigPath); mkdir(sigPath); end

for i = 1:height(kstable)
    % Pull out hit
    X = table2struct(kstable(i,:));

    % Plot
    plotMetric(X.Data, X.VarName)
    painters % smooth rendering for vector export
    
    % Save
    figName = sprintf('%s_%s_%s', X.VarName, X.Age, X.Region);
    export_fig(ff(allPath, figName),'-png','-eps') 
    
    % Save significant
    if isSignificant(i)
        export_fig(ff(sigPath, figName),'-png','-eps')
    end
    
    % Close fig
    close(gcf)
end

%% Single PCs (with latent and coeffs)
allPath = ff(figsAllPath,'pcs');
sigPath = ff(figsSigPath,'pcs');
if ~exists(allPath); mkdir(allPath); end
if ~exists(sigPath); mkdir(sigPath); end

for i = 1:height(kstable)
    % Pull out hit
    X = table2struct(kstable(i,:));
    
    % Skip non-PCs
    if ~contains(X.VarName,'_PC'); continue; end

    % Plot
    plotPC(X.Data, X.VarName)
    painters % smooth rendering for vector export
    
    % Save
    figName = sprintf('%s_%s_%s', X.VarName, X.Age, X.Region);
    export_fig(ff(allPath, figName),'-png','-eps') 
    
    % Save significant
    if isSignificant(i)
        export_fig(ff(sigPath, figName),'-png','-eps')
    end
    
    % Close fig
    close(gcf)
end

%% Overall PCA (all coeffs and latents)
pcaFigsPath = 'figs/ks_pca';
if ~exists(pcaFigsPath); mkdir(pcaFigsPath); end

assays = {ym, sc, epm};
for i = 1:numel(assays)
    for j = 1:numel(exptRegions)
        region = exptRegions{j};
        for k = 1:numel(exptAges)
            age = exptAges{k};
            
            % Pull out data
            X = assays{i}.(strrep(region,' ','')).(age);
            
            % Plot
            plotPCA(X)
            figtitle(sprintf('\\bf%s \\rightarrow %s \\rightarrow %s', X.assay_name, age, X.region_desc))
            painters
            
            % Save
            figName = sprintf('%s_%s_%s', X.assay_abbrev, X.age_name, X.region_name);
            export_fig(ff(pcaFigsPath, figName), '-png','-eps')
            
            % Close fig
            close(gcf)
        end
    end
end
