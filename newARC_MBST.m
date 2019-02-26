function general_multiband_slice_timing(subjects, conditions, runs)

% This is a simple wrapper function that does slice timing corrections for
% the Deckersbach group for their multi-band imaging scans. Assumes a scan
% with 63 slices collected in an interleaved fashion (odds-first) across
% three volumes.
% To run this script: Open Matlab, type command amd pass proper arguments. SPM will open a window which will 
% allow user to select NIFTI files.

%% Example Command:
% newARC_MBST({'newARC_001', 'newARC_002'},{'newARC'},{'newARC_001','newARC_002','newARC_003'})

%% subjects='newARC_004,'newARC_005','newARC_008','newARC_009','newARC_010','newARC_011','newARC_014','newARC_015','newARC_016','newARC_017','newARC_018','newARC_020'


%% use this command to see how many (TRs+1) in dir: ls -l . | egrep -c '^-' 

%% Specify root directory and subjects.
addpath '/autofs/cluster/pubsw/1/pubsw/common/spm/spm8';
spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_get_defaults('cmdline',true);

numSub = length(subjects);
numConds = length(conditions);
numRuns = length(runs);

%% Select nii file.
for subIdx = 1:numSub
    for condIdx = 1:numConds
        for runIdx = 1:numRuns
            %% Specify TR and Task Directory.
            switch conditions{condIdx}
                case 'newARC'
                    TR = 1750
                    dir = '/autofs/space/lilli_001/users/DARPA-newARC';
            end

            %% Specify Run Directory.
            run_dir = [dir filesep subjects{subIdx} filesep runs{runIdx}]

            %% Select functional files.
            msg = ['Select files for ' subjects{subIdx}]   
            P = spm_select(Inf,'image',msg,[],[run_dir filesep '001'], [runs{runIdx},'.nii'],'1:1000');

            %% Cue for TR.
    %         TR = inputdlg(['TR:','Please enter TR for ' conditions{condIdx}]);
    %         TR = str2double(TR);

            %% Define parameters.
            % Define slice orders.
            sliceorder = [1:2:21 2:2:21; 22:2:42 23:2:42; 43:2:63 44:2:63]';

            % Define reference slice.
            refslice = 1;

            % Timing
            nSlices = 21;
            TA = TR - (TR/nSlices);
            timing(1) = TA / (nSlices - 1);
            timing(2) = TR - TA;

            % Prefix
            prefix = 'a';

            %% Perform slice timing.
            try
                newARC_spm_mbst(P, sliceorder, refslice, timing, prefix);
            catch
                1+1;
            continue
            end
        end
    end
end

end

