# Title:  k-Means
# File:   kMeans.R
# Course: Data Mining with R

# INSTALL AND LOAD PACKAGES ################################

# Install pacman if you don't have it (uncomment next line)
# install.packages("pacman")

# Install and/or load packages with pacman
pacman::p_load(  # Use p_load function from pacman
  cluster,       # Cluster analysis
  factoextra,    # Evaluate clusters
  magrittr,      # Pipes
  pacman,        # Load/unload packages
  rio,           # Import/export data
  tidyverse      # So many reasons
)

# LOAD AND PREPARE DATA ####################################

# Use the `penguins` dataset that was wrangled previously 
# in "Penguins.R."

# Set random seed for reproducibility in processes like
# splitting the data
set.seed(1)  # You can use any number here

# Import data and sample
df <- import("penguins.rds") %>%
  sample_n(100)  # Reduce n for graphing

# Look at the first few rows of the prepared data frame
df

# Separate the class labels
species <- df %>%  # Rename `y` back to `species`
  pull(y)          # Select just `y` as a vector

df %<>% 
  select(-y) %>%   # Select everything except `y`
  scale()          # Standardize variables

# OPTIMAL NUMBER OF CLUSTERS ###############################

# Elbow method
df %>%
  fviz_nbclust(          # From `factoextra`
    FUN = kmeans,        # Use k-means
    method = "wss"       # "within cluster sums of squares"
  ) +
  geom_vline(            # Reference line
    xintercept = 3, 
    color = "red", 
    linetype = "dotted"
  )                      # Look for "bend" in curve

# Silhouette method
df %>%
  fviz_nbclust(
    FUN = kmeans,          # Use k-means
    method = "silhouette"  # Look for maximum width
  ) 

# Use gap statistics to find optimal number of clusters
# and visualize it using fviz_gap_stat
df %>% 
  clusGap(         # Function from `cluster`
    FUN = kmeans,  # Method for clustering
    K.max = 10,    # Maximum number of clusters
    B = 100        # Number of Monte Carlo/bootstrap samples
  ) %>%
  fviz_gap_stat()  # Look for highest value

# K-MEANS CLUSTERING #######################################

# Compute three clusters
km <- df %>% 
  kmeans(3) %>%  # Set the number of clusters
  print()        # Print output

# Visualize the clusters
km %>% fviz_cluster(
  data = df,
  geom = c("point")
) +
  geom_text(
    vjust = 1.5,  # Color points according to cluster
    aes(
      color = as.factor(km$cluster),
      label = species # label according to species
    )
  )

# CLEAN UP #################################################

# Clear data
rm(list = ls())  # Removes all objects from the environment

# Clear packages
p_unload(all)    # Remove all contributed packages

# Clear plots
graphics.off()   # Clears plots, closes all graphics devices

# Clear console
cat("\014")      # Mimics ctrl+L

# Clear R
#   You may want to use Session > Restart R, as well, which 
#   resets changed options, relative paths, dependencies, 
#   and so on to let you start with a clean slate

# Clear mind :)