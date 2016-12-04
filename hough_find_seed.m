function [ C, R, Mc ] = hough_find_seed( img )
% hough_find: Find seed from image by performing Hough Transform
% 
% Yun Yan (Dec 3, 2016)
%
% Parameter
% - img: image in gray scale
%
% Ref: https://www.mathworks.com/help/images/ref/imfindcircles.html

[C, R, Mc] = imfindcircles(img, [round(max(size(img))/16) round(max(size(img))/4)]);
% imshow(img_gray);
% viscircles(C(1, :), R(1), 'EdgeColor', 'b');
end

