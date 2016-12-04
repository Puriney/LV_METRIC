function [ mask ] = mask_figure(a, mask, color)
% mask_figure: overlay image a by mask
% 
% Yun Yan (Dec 3, 2016)
% 
% Parameters:
% - a: image in gray scaled
% - mask: another image in gray scaled as mask
% - color: highlighted region by color: 1=red, 2=green, 3=blue, 4=cyan,
% othwerwise=yellow
% 
% Ref: https://cn.mathworks.com/company/newsletters/articles/image-overlay-using-transparency.html

if (color == 1)
    bgcol = cat(3, ones(size(a)), zeros(size(a)), zeros(size(a)));
elseif (color == 2)
    bgcol = cat(3, zeros(size(a)), ones(size(a)), zeros(size(a)));
elseif (color == 3)
    bgcol = cat(3, zeros(size(a)), zeros(size(a)), ones(size(a)));
elseif (color == 4)
    bgcol = cat(3, ones(size(a)) .* 0.5, ones(size(a)), ones(size(a)));
else
    bgcol = cat(3, ones(size(a)), ones(size(a)), zeros(size(a)));
end
imshow(a);
hold on
h = imshow(bgcol);
hold off
set(h, 'AlphaData', mask);
end

