# Integrating and Analyzing Raster Data for Ethiopia

## Overview

This project integrates multiple raster datasets into a single cohesive stack for Ethiopia, ensuring they share a common resolution and extent.  It also extracts covariate information from these raster layers for DHS geolocations and summarizes the data at the administrative level 3 boundaries. 
## Objectives

- Integrate multiple raster datasets into a single cohesive stack.
- Resample and mask raster layers to ensure they share a common resolution and extent.
- Extract covariate information from raster layers for DHS geolocations.
- Summarize covariate data at the administrative level 3 boundaries.
- Provide comprehensive spatial data for research and policy development in Ethiopia.

## Dependencies

Ensure you have the following R packages installed:

- `terra`
- `sf`
- `dplyr`
- `geodata`

You can install these packages using:

```r
install.packages(c("terra", "sf", "dplyr", "geodata"))
```

## Script Details
### Step 1: Setting Up the Environment
Load necessary libraries and set the working directory.

### Step 2: Loading and Preparing Population Density Data
Load the population density raster and set its resolution.

### Step 3: Defining Covariate Layers
Define and load covariate raster layers, resampling and masking them to match the population density raster.

### Step 4: Resampling and Masking Covariate Layers
Each covariate layer is resampled and masked to match the population density layer, then added to the stack.

### Step 5: Loading and Processing Bioclimate Data
Download, process, and integrate bioclimate data.

### Step 6: Stacking All Layers
Combine all processed layers into a single stack.

### Step 7: Saving the Stacked Layers
Save both individual layers and the complete stack as GeoTIFF files for future use.

### Step 8: Summarizing Data by Administrative Level
Summarize covariate data at the administrative level 3 boundaries, providing aggregated information useful for policy and decision-making.

### Step 9: Extracting Data for DHS Geolocations
Read DHS geolocation data and extract covariate information from the stacked layers for each location.


##  Outputs
- Individual Layers: Saved in the Final_Aux_data directory.
- Stacked Layers: Saved as all_auxiliaryData.tif in the Final_Aux_data directory.
- DHS with Auxiliary Information: Saved as DHS_with_auxiliary_information.csv.
- Admin3 Summary Data: Saved as Admin3_summary.csv.
