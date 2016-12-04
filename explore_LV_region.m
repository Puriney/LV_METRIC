function [ M ] = explore_LV_region(img, mask, i_myocardial, fluctuation, row, col, mode)
% explore_LV_region: Detect region from one seed
% 
% Yun Yan (Dec 3, 2016)
% 
% Parameters:
% - img: gray scaled image;
% - mask: established mask of blood region
% - i_myocardial: spiking i value 
% - fluctuation: fluctuation of intensity
% - row: row position of seed
% - col: col position of seed
% - mode: default find region only, while set 1 for edge only


mask_val = img(mask);
mask_val_avg = mean(mask_val);

M = false(size(img));
M(row, col) = 1;
i_list = 1:0.1:i_myocardial;

for x = 1:size(i_list, 2)
    i = i_list(x);
    growth_theta = mask_val_avg / i;
    M_cached = false(size(img)); % initial cached mask for new growth_theta to turn on the while loop
    while (sum(M(:)) ~= sum(M_cached(:)))
        M_cached = M; % cached before new round propagation
        se = strel('disk', 1, 0);
        M_se = imdilate(M, se);
        candidate_index = M_se - M;
        candidate_pos_index = find(candidate_index);
        candidate_value = img(candidate_pos_index);
        % Lower-bound thresholding region-growth
        is_accepted = (candidate_value >= growth_theta + fluctuation);
        M(candidate_pos_index(is_accepted)) = 1;
    end
end

if (mode == 1)
    M = M - imerode(M, se);
end
end

