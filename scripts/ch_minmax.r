library(cluster)
library(factoextra)
library(NbClust)

# Min-Max normalization
min_max_norm <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

run_optimal_k <- function(file, min_nc, max_nc,
                          true_k = NA,
                          drop_last_col = FALSE) {
  
  file_path <- file.path("data", file)
  
  if (!file.exists(file_path)) {
    cat("File not found:", file_path, "\n")
    return(NULL)
  }
  
  df <- read.table(file_path, header = FALSE)
  
  if (drop_last_col) {
    df <- df[, -ncol(df)]
  }
  
  # Ensure numeric
  df <- as.data.frame(lapply(df, function(x) as.numeric(as.character(x))))
  
  # Remove NAs before normalization
  df <- na.omit(df)
  
  # Apply Min-Max normalization per column
  df <- as.data.frame(lapply(df, min_max_norm))
  
  # Remove NAs introduced by zero-range columns (max == min)
  df <- na.omit(df)
  
  # Run NbClust with CH index
  res <- NbClust(
    data = df,
    distance = "euclidean",
    min.nc = min_nc,
    max.nc = max_nc,
    method = "kmeans",
    index = "ch"
  )
  
  ch_values <- res$All.index
  k_values  <- as.integer(names(ch_values))
  optimal_k <- k_values[which.max(ch_values)]
  
  dev.new()
  
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
      " [Min-Max] | Optimal k = ", optimal_k,
      if (!is.na(true_k)) paste0(" | True k = ", true_k) else ""
    )
  )
  
  abline(v = optimal_k, col = "red", lty = 2, lwd = 2)
  
  if (!is.na(true_k)) {
    abline(v = true_k, col = "blue", lty = 2, lwd = 2)
    legend(
      "topright",
      legend = c(paste("Optimal k =", optimal_k), paste("True k =", true_k)),
      col = c("red", "blue"),
      lty = 2, lwd = 2, bty = "n"
    )
  } else {
    legend(
      "topright",
      legend = paste("Optimal k =", optimal_k),
      col = "red",
      lty = 2, lwd = 2, bty = "n"
    )
  }
  
  cat(sprintf("%-15s | Optimal k: %2d", tools::file_path_sans_ext(basename(file)), optimal_k))
  if (!is.na(true_k)) cat(sprintf(" | True k: %2d", true_k))
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
)

# Run all
for (d in datasets) {
  run_optimal_k(
    file = d$file,
    min_nc = d$min_nc,
    max_nc = d$max_nc,
    true_k = d$true_k,
    drop_last_col = d$drop_last_col
  )
}