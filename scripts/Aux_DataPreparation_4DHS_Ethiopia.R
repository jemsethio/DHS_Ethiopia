
#' Integrating and Analyzing Raster Data for Ethiopia
#'
#' Author: Jemal S. Ahmed
#' email: JemalSeid.Ahmed@santannapisa.it
#' github: https://github.com/jemsethio/DHS_Ethiopia.git
#' Affiliation: Institute of Plant Science, Scuola Superiore Sant'Anna
#' Date: 25 June 2024
#' 
#' Objectives:
#' - Integrate multiple raster datasets into a single cohesive stack for Ethiopia.
#' - Resample and mask raster layers to ensure they share a common resolution and extent.
#' - Extract covariate information from raster layers for DHS geolocations.
#' - Summarize covariate data at the administrative level 3 boundaries.
#' - Provide comprehensive spatial data for phd research students.


# Load necessary libraries
library(terra)
library(sf)
library(dplyr)
library(geodata)

# Set working directory
work_dir <- "./DHS_Ethiopia/data"
setwd(work_dir)

list.files(path = work_dir, pattern = ".tif")

# Load population density raster as a reference and check a resolution
popD <- rast("Population Density eth_pd_2019_1km_UNadj.tif")
names(popD) <- "PD"
res(popD)

#covariate filenames and names
cov_filename <- paste0(work_dir,c("Population Density eth_pd_2019_1km_UNadj.tif", 
                  "201501_Global_Time to Nearest City _ETH.tiff",
                  "Distance to Major road eth_osm_dst_road_100m_2016.tif", 
                  "202001_Global Walking Only Travel Time nearst healthcare ETH.tiff", 
                  "Age and Sex Structures 15_49_2015_1km.tif",
                  "Cultivated landuse eth_esaccilc_dst011_100m_2014.tif", 
                  "Elevation above Sea level eth_srtm_topo_100m.tif",
                  "Nighttime Light Radiance eth_esaccilc_dst011_100m_2015.tif", 
                  "Topographic Slope eth_srtm_slope_100m.tif"))
cov_name <- c("PD", "GTNC", "DMR", "GWT", "AgeSex", "CLU", "ALT", "NLR", "Slope")

# Initialize stack with population density raster
stack_layer <- popD

# Resample and mask each covariate layer, then add to stack
for (i in 1:length(cov_filename)) {
  rast_in <- rast(cov_filename[i])
  rast_resampled <- resample(rast_in, popD, method = "bilinear")
  rast_masked <- mask(crop(rast_resampled, popD), popD)
  stack_layer <- c(stack_layer, rast_masked)
}

names(stack_layer) <- cov_name

# Load and process bioclimate data
dir.create("./worldclim")
bio <- worldclim_country(country = "ET", var = "bio", path = paste0(work_dir,"/worldclim"))
names(bio) <- paste0("BIO", 1:19)
bio_resampled <- resample(bio, popD, method = "bilinear")
bio_masked <- mask(crop(bio_resampled, popD), popD)

# Stack all layers including bioclimate data
stack_lyr <- c(stack_layer, bio_masked)

# Save individual layers and stacked layer
dir.create(paste0(work_dir,"Final_Aux_data"))
for (i in 1:nlyr(stack_lyr)) {
  writeRaster(stack_lyr[[i]], filename = paste0(work_dir, "/Final_Aux_data/", names(stack_lyr)[i]), format = "GTiff", overwrite = TRUE)
}
writeRaster(stack_lyr, filename = "./Final_Aux_data/all_auxiliaryData.tif", format = "GTiff", overwrite = TRUE)

# Summarize covariates by administrative level 3
eth_adm3 <- gadm(country = 'ET', level = 3, path = "./admin/Ethiopia/")
admn3_summary <- terra::extract(stack_lyr, eth_adm3, fun = 'mean', bind = TRUE, 
                                touches = TRUE, exact=TRUE, small=TRUE, na.rm=TRUE )
writeVector(admn3_summary, filename = paste0(work_dir, "/Final_Aux_data/aux_admin3_eth.shp"),  overwrite=TRUE)

# Save summary data
write.csv(admn3_summary, file = "Admin3_summary.csv", row.names = FALSE)

# Read DHS geolocation data and extract covariate data
dhs_geoloc <- read.csv(file = "GPS data.csv", stringsAsFactors = FALSE)
dhs_orig <- dhs_geoloc
dhs_geoloc <- vect(dhs_geoloc, geom = c("LONGNUM", "LATNUM"), crs = crs(stack_lyr))

dhs_cov <- extract(stack_lyr, dhs_geoloc)
DHS_Cov <- cbind.data.frame(dhs_orig, dhs_cov)
write.csv(x = DHS_Cov, file = "DHS_with_auxiliary_information.csv", row.names = FALSE)

