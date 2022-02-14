# Automatic vanishing point estimation and camera calibration under the Manhattan world assumption

## Summary of main data locations

- Images of the clustered edges in `output/jaccImg` and `output/taniImg`
- Extracted numeric data in `output/extractedData.mat`
- Graphs with analysis of the results in `output/benchmarks` and in `presentation.pdf`


## Overview
Directories:

- *dataset*: the collection of images used to test the code
- *output*: visual and numeric output
- *src*: the source code

## src

`src/`
- `algorithms.m`: utility functions for both jaccard- and tanimoto-based algorithms
- `benchmark.m`: evaluation of the results
- `calibration.m`: find the calibration matrix from 3 vanishing points. Reads and updates data on output
- `clustering.m`: cluster the edges according to their directions
- `getClusterVPs.m`: extract the vanishing point of a cluster
- `getSegments.m`: extract the straight segments from an image
- `lineOps.m`: general operations on lines and segments
- `main.m`: runs the segment detection and clustering algorithms. Saves data on output
- `manhattanDirections.m`: selects the 3 main clusters which correspond to the manhattan directions
- `preferenceMatrix.m`: creates the preference matrix
- `showVps.m`: overlays the manhattan directions to the images


## output 

**Look here for already computed results**

output
- `benchmarks`	: images for the analysis of the data
- `jaccImg`		: edges classified using Jaccard distance 
- `taniImg`		: edges classified using Tanimoto distance
- `extractedData.mat` : numeric results

### extractedData.mat

Contains the numerical data extracted.
Contains an array struct with fields:

- `image`: 		the image identifier
- `algorithm`: 	either `algorithms.jaccard` or `algorithms.tanimoto`. Specifies the algorithms used to generate this struct data
- `clusters`:	an array struct with field `edges` containing a list of edges in the same cluster in the shape `[x_1 y_1 x_2 y_2; ...]`
- `vps`:		the vanishing points relative to the extracted Manhattan directions
- `calibration`:the calibration matrix for this image, or `[]` if it was not possible to get one


## How to reproduce the data

1. Find and cluster the edges with `main.m`
2. Find the calibration matrices with `calibration.m`
3. Analize the data with `benchmark.m`

Note: this has been developed in MATLAB R2021b, which has syntax differences with respect to MATLAB 2020 and previous versions.