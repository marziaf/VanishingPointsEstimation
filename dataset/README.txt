The Toulouse Vanishing Points Dataset
=====================================

Introduction
------------

This dataset is a collection of photographs taken in Toulouse.
The images are 1920x1080 in size and have been taken with an iPad Air 1.

Further details can be found in the MMSys conference paper Angladon V., Gasparini S. & Charvillat V. (2015). The Toulouse Vanishing Points Dataset.
If you use this dataset, please cite this paper.


Organization
------------

### camera_intrinsics.mat

Contains the camera intrinsic parameters matrix.


### image_name.jpg

The original 1920x1080 image.
The UserComment EXIF field contain JSON.
The mean_rot value is the attitude of the mobile device at the time of the shot, represented as a change of basis matrix from the world reference frame to the camera frame.


### image_name.mat

* endptAccuracy  1x1 accuracy of the endpoints 
* mean_rot       3x3 change of basis matrix from the world frame to the camera frame
* polys          1x3 cell array of polygons. polys{i} is a lx3 matrix of the coordinates of the polygon in the image space in homogeneous coordinates.
* segments       nx4 enpoints of the segment in the form [x1 y1 x2 y2 ; ...]
* vp_association 1xm vanishing point associated with each of the n line segments.  Possible values are {1,2,3}. We used Patrick Denis conventions: 
1. First horizontal vanishing point 
2. Vertical vanishing point 
3. Second horizontal vanishing point


### image_name.txt

The ground truth lines segments in the JSON format and stored in a list of three elements.
The first element contains the line segments of the first horizontal vanishing point, the second the line segments of the vertical vanishing point, ...
Each segment is represented by a list using the following convention: [x1, y1, x2, y2].


