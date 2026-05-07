library(cluster)
library(factoextra)
library(NbClust)

# Z-score normalization
z_score_norm <- function(x) {
  (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
}

run_optimal_k <- function(file, min_nc, max_nc,
                          true_k = NA,
                          drop_last_col = FALSE) {
  
  # Correct file path
  file_path <- file.path("data", file)
  
  # Check if file exists
  if (!file.exists(file_path)) {
    cat("File not found:", file_path, "\n")
    return(NULL)
  }
  
  # Read dataset
  df <- read.table(file_path, header = FALSE)
  
  # Remove last column if needed
  if (drop_last_col) {
    df <- df[, -ncol(df)]
  }
  
  # Normalize data
  df <- as.data.frame(lapply(df, z_score_norm))
  
  # Remove NA rows if any
  df <- na.omit(df)
  
  # Run NbClust
  res <- NbClust(
    data = df,
    distance = "euclidean",
    min.nc = min_nc,
    max.nc = max_nc,
    method = "kmeans",
    index = "ch"
  )
  
  # Extract CH index values
  ch_values <- res$All.index
  k_values  <- as.integer(names(ch_values))
  
  # Optimal k
  optimal_k <- k_values[which.max(ch_values)]
  
  # Open one graph per window
  dev.new()
  
  # Plot
  plot(
    k_values,
    ch_values,
    type = "b",
    pch = 19,
    col = "black",
    xlab = "Number of clusters (k)",
    ylab = "Calinski-Harabasz Index",
    main = paste0(
      tools::file_path_sans_ext(basename(file)),
      " | Optimal k = ", optimal_k,
      if (!is.na(true_k)) paste0(" | True k = ", true_k) else ""
    )
  )
  
  # Optimal k line
  abline(v = optimal_k, col = "red", lty = 2, lwd = 2)
  
  # True k line only if available
  if (!is.na(true_k)) {
    abline(v = true_k, col = "blue", lty = 2, lwd = 2)
    
    legend(
      "topright",
      legend = c(
        paste("Optimal k =", optimal_k),
        paste("True k =", true_k)
      ),
      col = c("red", "blue"),
      lty = 2,
      lwd = 2,
      bty = "n"
    )
  } else {
    
    legend(
      "topright",
      legend = paste("Optimal k =", optimal_k),
      col = "red",
      lty = 2,
      lwd = 2,
      bty = "n"
    )
  }
  
  # Console output
  cat(sprintf(
    "%-15s | Optimal k: %2d",
    tools::file_path_sans_ext(basename(file)),
    optimal_k
  ))
  
  if (!is.na(true_k)) {
    cat(sprintf(" | True k: %2d", true_k))
  }
  
  cat("\n")
}

# Dataset list
datasets <- list(
  
  list(
    file = "D31.txt",
    min_nc = 2,
    max_nc = 55,
    true_k = 31,
    drop_last_col = TRUE
  ),
  
  list(
    file = "R15.txt",
    min_nc = 2,
    max_nc = 24,
    true_k = 15,
    drop_last_col = TRUE
  ),
  
  list(
    file = "a2.txt",
    min_nc = 2,
    max_nc = 72,
    true_k = 35,
    drop_last_col = FALSE
  ),
  
  list(
    file = "a1.txt",
    min_nc = 2,
    max_nc = 72,
    true_k = 20,
    drop_last_col = FALSE
  )
  

# Run all datasets
for (d in datasets) {
  
  run_optimal_k(
    file = d$file,
    min_nc = d$min_nc,
    max_nc = d$max_nc,
    true_k = d$true_k,
    drop_last_col = d$drop_last_col
  )
}