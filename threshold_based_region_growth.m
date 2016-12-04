function [i_list, vol_list, M] = threshold_based_region_growth(img, mask, row, col, mode)
% threshold_based_region_growth: Detect region from one seed
% 
% Yun Yan (Dec 3, 2016)
%
% Parameters:
% - img: gray scaled image;
% - mask: established mask of blood region
% - row: row position of seed
% - col: col position of seed
% - mode: default find region only, while set 1 for edge only

mask_val = img(mask);
theta = mean(mask_val);
mask_val_std = std(double(mask_val));

M = false(size(img));
M(row, col) = 1;

i_list = 1:0.1:4;
vol_list = zeros(size(i_list));
fluctuation = 0; %1 * mask_val_std);

for x = 1:size(i_list, 2)
    i = i_list(x);
    growth_theta = theta / i;
    M_cached = false(size(img)); % initial cached mask for new growth_theta to turn on the while loop
    while (sum(M(:)) ~= sum(M_cached(:)))
        M_cached = M; % cached before new round propagation
        se = strel('disk', 1, 0);
        M_se = imdilate(M, se);
        candidate_index = M_se - M;
        candidate_pos_index = find(candidate_index);
        candidate_value = img(candidate_pos_index);
        % Lower-bound thresholding region-growth
        is_accepted = (candidate_value >= growth_theta - fluctuation); 
        M(candidate_pos_index(is_accepted)) = 1;
    end

    vol = sum(M(:));
    vol_list(x) = vol;
end

if (mode == 1)
    M = M - imerode(M, se);
end
end