voi_list = dir('D:\Vered_Asaf_MRI_GARP\VOIs\Asaf_ROIs\*.voi');

subjects = dir('D:\Vered_Asaf_MRI_GARP\*_analyzed');
subjects = str2double(regexpi({subjects.name}, '\d\d\d', 'match', 'once'));

vtc_path_template = 'D:/Vered_Asaf_MRI_GARP/%d_analyzed/function/*main*_SCCTBL_*.vtc';

all_subject_arr = {};
all_mean_roi = {};
all_subject_RSM = {};
all_subject_demeaned = {};
size(all_mean_roi)

%%
for sub_i = 1:length(subjects)
    subject_arr = [];
    subject_mean_roi = [];
    subject_RSM = [];
    subject_mean_signal = [];
    sub_num = subjects(sub_i);
    sub_path = sprintf(vtc_path_template, sub_num);
    disp(sub_path);
    vtcs = dir(sub_path);
    if length(vtcs) == 0
        sprintf('Subject %d has no data\n', sub_num);
        return;
    end
    fprintf('Subject %d\n', subjects(sub_i))
    for voi_path_i = 1:length(voi_list)
        voi_path = [voi_list(voi_path_i).folder '\' voi_list(voi_path_i).name];
        voi = BVQXfile(voi_path);
        if length(voi.VOI) > 1
            voi.VOI = voi(1);
            voi.NrOfVOIs = 1;
        end
        voi_name = split(voi.VOI.Name, '_');
        voi_name = voi_name{1};
        % Extract signal from VOI (ROI)
        voi_signal = [];
        voi_mean_signal = {};
        voi_signal_demeaned = {};
        block_demeaned = {};
        for i_vtc = 1:length(vtcs)
            vtc = vtcs(i_vtc);
            vtc_path = [vtc.folder '\' vtc.name];
            f = BVQXfile(vtc_path);
            brain_block_mean = mean(f.VTCData(:));
            % extract mean ROI signal (averaging over voxels)
            this_mean_signal = f.VOITimeCourse(voi);
            voi_mean_signal{end+1} = this_mean_signal;
            voi_signal_demeaned{end+1} = this_mean_signal - mean(this_mean_signal);
            block_demeaned{end+1} = brain_block_mean;
            % extract signal per voxel 
            signal_cell = f.VOITimeCourse(voi, struct('weight', 2));
            signal_double = signal_cell{:};
            voi_signal = [voi_signal; signal_double];
        end
        subject_arr = [subject_arr; {voi_name, voi_signal}];
        subject_mean_roi = [subject_mean_roi; [voi_name, voi_mean_signal]];
        subject_mean_signal = [subject_mean_signal;  block_demeaned];
        xff(0, 'clearallobjects');
    end
    all_subject_arr{end+1} = {sub_num, subject_arr};
    all_mean_roi{end+1} = {sub_num, subject_mean_roi};
    all_subject_demeaned{end+1} = {sub_num, subject_mean_signal};
    
    
end
%%
save('all_subject_arr.mat', 'all_subject_arr', '-v7.3');
save('all_mean_roi.mat', 'all_mean_roi');
save('all_subject_demeaned.mat', 'all_subject_demeaned')
