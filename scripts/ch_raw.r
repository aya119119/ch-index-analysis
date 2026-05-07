library(cluster)
library(factoextra)
library(NbClust)

run_optimal_k <- function(file, min_nc, max_nc, true_k,
                          drop_last_col = FALSE) {
  
  # Read dataset
  df <- read.table(file, header = FALSE)
  
  # Remove last column if needed
  if (drop_last_col) {
    df <- df[, -ncol(df)]
  }
  
  # Compute CH index using NbClust
  res <- NbClust(
    data = df,
    distance = "euclidean",
    min.nc = min_nc,
    max.nc = max_nc,
    method = "kmeans",
    index = "ch"
  )
  
  # Extract CH values
  ch_values <- res$All.index
  k_values  <- as.integer(names(ch_values))
  
  # Find optimal k
  optimal_k <- k_values[which.max(ch_values)]
  
  # Open a new plotting window
  dev.new()
  
  # Plot
  plot(
    k_values,
    ch_values,
    type = "b",
    pch = 19,
    col = 'black',
    xlab = "Number of clusters (k)",
    ylab = "Calinski-Harabasz Index",
    main = paste0(
      tools::file_path_sans_ext(basename(file)),
      " | Optimal k = ", optimal_k,
      " | True k = ", true_k
    )
  )
  
  # Vertical lines
  abline(v = optimal_k, col = "red", lty = 2, lwd = 2)
  abline(v = true_k, col = "blue", lty = 2, lwd = 2)
  
  # Legend
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
  
  # Print results
  cat(sprintf(
    "%-6s | Optimal k: %2d | True k: %2d\n",
    tools::file_path_sans_ext(basename(file)),
    optimal_k,
    true_k
  ))
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
)

# One graph per window
for (d in datasets) {
  
  run_optimal_k(
    d$file,
    d$min_nc,
    d$max_nc,
    d$true_k,
    d$drop_last_col
  )
}