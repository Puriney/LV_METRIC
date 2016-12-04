close all;
clear all;
% Set the input image name and how you set the seed
img_fname = 'Picture3.png';
seed_select_mode = 'manual'; % set manually by mouse operation in GUI
% seed_select_mode = 'hough';  % automatically set by hough transform

% Read-in image and transfered to gray scale
img = imread(img_fname);
img_gray = rgb2gray(img);

fig_r = 2;
fig_c = 1;

figure;
imhist(img_gray);
title(['Histogram of gray-scaled ', img_fname]);
print(strcat(img_fname, '.01Histgraom.png'), '-dpng');

figure;
imshow(img_gray);
title(img_fname);
print(strcat(img_fname, '.01GrayScale.png'), '-dpng');

%
% Seed Selection
% 1) Manually create one seed point (or use getpts function to set several
% seeds)
% 2) Hough transform
% 
figure;
imshow(img_gray);
if (strcmp(seed_select_mode, 'manual'))
    [seed_col, seed_row] = ginput(1); % using mouse in GUI of matlab
elseif (strcmp(seed_select_mode, 'hough'))
    [seed_C, seed_R, seed_Metric] = hough_find_seed(img_gray);
    seed_num = length(seed_R);
    if (seed_num == 0)
        disp('Fail to run Hough Transform to find seed. Please manually select.');
        [seed_col, seed_row] = ginput(1); % using mouse in GUI of matlab
        seed_select_mode = 'forced manual';
    else
        seed_col = seed_C(1, 1);
        seed_row = seed_C(1, 2);
        if (seed_num < 5)
            top_seed_num = seed_num;
        else
            top_seed_num = 5;
        end
        viscircles(seed_C(1:top_seed_num, :), seed_R(1:top_seed_num), 'EdgeColor', 'b', 'LineStyle','--');
    end
end
viscircles([seed_col, seed_row], 2, 'EdgeColor', 'r');
title(strcat('Seed (red) on ', img_fname, ' (', seed_select_mode, ')')) 
print(strcat(img_fname, '.02Seed.png'), '-dpng');

seed_col = round(seed_col);
seed_row = round(seed_row);


% Edge-based region-growth to roughly get blood region
blood_region = edge_based_region_growth(img_gray, 20, seed_row, seed_col, 0);
blood_edge = edge_based_region_growth(img_gray, 20, seed_row, seed_col, 1);

% Mask the region on original image to visualize blood region and edge
figure;
mask_figure(img_gray, blood_region, 2);
title('Blood region')
print(strcat(img_fname, '.03bBloodRegion.png'), '-dpng');
figure;
mask_figure(img_gray, blood_edge, 0);
title('Blood region (edge)')
print(strcat(img_fname, '.03aBloodEdge.png'), '-dpng');
mean_blood = mean(img_gray(blood_region));
std_blood = std(double(img_gray(blood_region)));

% Threshold-based region-growth to estimate myocardial mean
[i_list, vol_list, mask] = threshold_based_region_growth(img_gray, blood_region, seed_row, seed_col, 0);
figure;
mask_figure(img_gray, mask, 3);
title('Result of region-growth after all iterations are finished');
print(strcat(img_fname, '.04FinalIteration.png'), '-dpng');

% Determine the optimal i which achieving best discontinuity
i_num = size(i_list, 2);
diff_i = diff(vol_list); % (i_num - 1) elements
delta_i = zeros(1, i_num-2); % (i_num - 2) elements
for x=1:(i_num-2)
    delta_i(x) = diff_i(x+1) / diff_i(x);
end

delta_i = [0, delta_i, 0]; % add 0 for dummy numbers
delta_i(not(isfinite(delta_i))) = 0; % inf changed to 0
[delta_max, i_opt_index] = max(delta_i);
i_spike_val = i_list(i_opt_index); % myocardial appears
i_opt_val = i_spike_val - 0.1;

figure;
subplot(2, 1, 1);
plot(i_list(2:i_num-1), vol_list(2:i_num-1), '-o', [i_spike_val, i_spike_val], [min(vol_list), max(vol_list)], '--');
xlabel('Blood Mean / Region-Growth Threshold (i)');
ylabel('Volumn(voxels)');
subplot(2, 1, 2);
plot(i_list(2:i_num-1), delta_i(2:i_num-1), '-o', [i_spike_val, i_spike_val], [0, delta_max], '--');
xlabel('Blood Mean / Region-Growth Threshold (i)');
ylabel('Delta(\delta)');
print(strcat(img_fname, '.05DiagnoseDiscontinuity.png'), '-dpng');

% Estimate myocardial region, i.e. edge of LV
myocardial_region = explore_LV_region(img_gray, blood_region, i_spike_val, 0, seed_row, seed_col, 1);
myocardial_region = logical(myocardial_region);
lv_full_region = explore_LV_region(img_gray, blood_region, i_spike_val, 0, seed_row, seed_col, 0);
figure;
mask_figure(img_gray, myocardial_region, 3);
title('Myocardial region');
print(strcat(img_fname, '.06MyocardialRegion.png'), '-dpng');


% Estimate the content inner LV

lv_full_val = img_gray(lv_full_region);
lv_full_vol = sum(lv_full_region(:));
std_myocardial = std(double(img_gray(myocardial_region)));
mean_myocardial = mean_blood / i_spike_val;
dummy_full_myocardial = uint8(normrnd(mean_myocardial, std_myocardial, [lv_full_vol, 1]));
dummy_full_blood = uint8(normrnd(mean_blood, std_blood, [lv_full_vol, 1]));

figure;
subplot(3, 1, 1);
imhist(lv_full_val);
title('Observed LV before content analysis');
subplot(3, 1, 2);
imhist(dummy_full_myocardial);
title('Dummy full myocardial');
subplot(3, 1, 3);
imhist(dummy_full_blood);
title('Dummy full blood');
print(strcat(img_fname, '.07LVContent.png'), '-dpng');

lv_window_lower = mean_myocardial + 4 * std_myocardial;
lv_window_upper = mean_blood - 4 * std_blood;
lv_region = fetch_LV_region(img_gray, blood_region, lv_window_lower, lv_window_upper, seed_row, seed_col, 0);

figure;
img_mask = zeros(size(img_gray));
img_mask(lv_region) = img_gray(lv_region);
img_mask = uint8(img_mask);
mask_figure(img_gray, img_mask, 4);
title('Identifed LV')
print(strcat(img_fname, '.08LV.png'), '-dpng');


