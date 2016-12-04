# LV_METRIC
My Matlab Implementation for LV Myocardial Effusion Threshold Reduction with Intravoxel Computation (LV-METRIC) developed by Yi Wang's lab. Paper source: [Left ventricle: automated segmentation by using myocardial effusion threshold reduction and intravoxel computation at MR imaging.](https://www.ncbi.nlm.nih.gov/pubmed/18710989)

# Results

# How-to Run

Run `LV_METRIC.m` in Matlab. But first 1) modify the script to change the input image filename and 2) choose your method to set seed ('manual' or 'hough').

# Technical Details

## Set seed

1. The built-in function `ginput(1)` of Matlab enables users to select seed point by GUI;
2. The built-in function `imfindcircles` of Matlab performs circular Hough transform so that I can find circle-like ventricles, with hypothesis that LV in captured image is in circle-like shape. If none circles are found by Hough transform, my codes will force users to turn to the first method described as above.

Note: only one seed is allowed to select. More than one seeds are not making sense in human anatomy.

## Edge-based region-growth to estimate blood region

See `edge_based_region_growth.m`.

## Lower-bound Threshold-based region-growth to estimate myocardial region

See `threshold_based_region_growth.m`, `explore_LV_region.m`, and `fetch_LV_region.m`.

## Image visualization

See `mask_figure.m` for highlighting blood, myocardial, and ventricle regions/edges on original gray-scaled image.

