# Automatic vanishing point estimation and camera calibration under the Manhattan world assumption
## Directories
.
├── dataset
│   └── tvpd_dataset
├── output
│   ├── jaccImg
│   └── taniImg
└── src

- *dataset*: the collection of images used to test the code
- *output*: visual and numeric output
- *src*: the source code

## src

.
├── algorithms.m : utility functions for both jaccard- and tanimoto-based algorithms
├── benchmark.m : evaluation of the results
├── calibration.m : find the calibration matrix from 3 vanishing points. Reads and updates data on output
├── clustering.m : cluster the edges according to their directions
├── getClusterVPs.m : extract the vanishing point of a cluster
├── getSegments.m : extract the straight segments from an image
├── lineOps.m : general operations on lines and segments
├── main.m : runs the segment detection and clustering algorithms. Saves data on output
├── manhattanDirections.m : selects the 3 main clusters which correspond to the manhattan directions
└── preferenceMatrix.m : creates the preference matrix


## output 
TODO


