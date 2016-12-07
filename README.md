# LV_METRIC
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.193305.svg)](https://doi.org/10.5281/zenodo.193305)

My Matlab Implementation for LV Myocardial Effusion Threshold Reduction with Intravoxel Computation (LV-METRIC) developed by Yi Wang's lab at Cornell MRI Research lab.

# Paper source

[Left ventricle: automated segmentation by using myocardial effusion threshold reduction and intravoxel computation at MR imaging.](http://pubs.rsna.org/doi/pdf/10.1148/radiol.2482072016)<https://www.ncbi.nlm.nih.gov/pubmed/18710989>.

# Results

The LV of input image will be identified automatically.

![Imgur](http://i.imgur.com/fSVIC3K.png?1)
![Imgur](http://i.imgur.com/yZlVetR.png)
![Imgur](http://i.imgur.com/Ipwnw7l.png)

# Processing

## Seed selection

The center (seed) of LV can be either manually picked up or automatically inferred by performing Hough Transform. Here Hough Transform was performed. Top 2 possible candidates are shown as dashed blue circles and only "best" circle is for generating seed (shown as red dot).

![Imgur](http://i.imgur.com/N2y24Yo.png)

## Edge-based region-growth to detect "blood" region

![Imgur](http://i.imgur.com/uaUy23A.png)
![Imgur](http://i.imgur.com/kS0F26i.png)

The average and s.t.d. of "blood" region (brighter) are estimated (e.g. 180 is mean).

## Lower-bound threshold-based region-growth to detect myocardial region

![Imgur](http://i.imgur.com/hRXxvXA.png)

Still starting from the same seed, the program attempts to find threshold which can identify the boundary between the peripheral myocardial region and inner blood region.

In this example, the ratio between blood mean and threshold has a spke value of 3.0, which further approximately suggests the average intensity of peripheral myocardial region, e.g. 180/3.0=60.

The inferred mycardial region is shown as figure below and the s.t.d. is calculated.

![Imgur](http://i.imgur.com/0Ckgi9V.png)

## Content analysis of LV

The intensity distribution of region surrounded by above mycardial line is:

![Imgur](http://i.imgur.com/jSCxySp.png)

## Identify LV

![Imgur](http://i.imgur.com/VuOMtJL.png)

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

