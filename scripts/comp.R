library(cluster)
library(factoextra)
library(NbClust)

# ---- Normalization functions ----
z_score_norm  <- function(x) (x - mean(x)) / sd(x)
min_max_norm  <- function(x) (x - min(x)) / (max(x) - min(x))

# ---- Error metric ----
compute_error <- function(k_detected, k_real) {
  abs(k_detected - k_real) / k_real * 100
}

# ---- Core function ----
run_ch <- function(df, min_nc, max_nc) {
  res <- NbClust(data = df, distance = "euclidean",
                 min.nc = min_nc, max.nc = max_nc,
                 method = "kmeans", index = "ch")
  ch_values <- res$All.index
  k_values  <- as.integer(names(ch_values))
  list(k_opt = k_values[which.max(ch_values)],
       k_vals = k_values, ch_vals = ch_values)
}

# ---- Plot function ----
plot_ch <- function(k_vals, ch_vals, k_opt, k_real, title) {
  plot(k_vals, ch_vals, type = "b", pch = 19, col = "black",
       xlab = "Nombre de clusters (k)",
       ylab = "Indice CH",
       main = title)
  abline(v = k_opt,  col = "red",  lty = 2, lwd = 2)
  abline(v = k_real, col = "blue", lty = 2, lwd = 2)
  legend("topright",
         legend = c(paste("K optimal =", k_opt),
                    paste("K réel =", k_real)),
         col = c("red", "blue"), lty = 2, lwd = 2, bty = "n")
}

# ---- Datasets ----
datasets <- list(
  list(file = "data/D31.txt", min_nc = 2, max_nc = 55,
       true_k = 31, drop_last = TRUE),
  list(file = "data/R15.txt", min_nc = 2, max_nc = 24,
       true_k = 15, drop_last = TRUE),
  list(file = "data/a2.txt",  min_nc = 2, max_nc = 72,
       true_k = 35, drop_last = FALSE),
  list(file = "data/a1.txt",  min_nc = 2, max_nc = 72,
       true_k = 20, drop_last = FALSE)
)

# ---- Results storage ----
results <- data.frame(
  Dataset  = character(),
  K_reel   = integer(),
  K_brut   = integer(), Err_brut   = numeric(),
  K_zscore = integer(), Err_zscore = numeric(),
  K_minmax = integer(), Err_minmax = numeric(),
  stringsAsFactors = FALSE
)

# ---- Main loop ----
for (d in datasets) {
  name <- tools::file_path_sans_ext(basename(d$file))
  df   <- read.table(d$file, header = FALSE)
  if (d$drop_last) df <- df[, -ncol(df)]
  
  df_brut   <- df
  df_z      <- as.data.frame(lapply(df, z_score_norm))
  df_mm     <- as.data.frame(lapply(df, min_max_norm))
  
  r_brut  <- run_ch(df_brut, d$min_nc, d$max_nc)
  r_z     <- run_ch(df_z,    d$min_nc, d$max_nc)
  r_mm    <- run_ch(df_mm,   d$min_nc, d$max_nc)
  
  # --- 3 plots per dataset ---
  dev.new(); par(mfrow = c(1, 3))
  plot_ch(r_brut$k_vals, r_brut$ch_vals, r_brut$k_opt, d$true_k,
          paste0(name, " — Brut"))
  plot_ch(r_z$k_vals,    r_z$ch_vals,    r_z$k_opt,    d$true_k,
          paste0(name, " — Z-Score"))
  plot_ch(r_mm$k_vals,   r_mm$ch_vals,   r_mm$k_opt,   d$true_k,
          paste0(name, " — Min-Max"))
  
  results <- rbind(results, data.frame(
    Dataset  = name,
    K_reel   = d$true_k,
    K_brut   = r_brut$k_opt,
    Err_brut   = round(compute_error(r_brut$k_opt, d$true_k), 1),
    K_zscore = r_z$k_opt,
    Err_zscore = round(compute_error(r_z$k_opt,    d$true_k), 1),
    K_minmax = r_mm$k_opt,
    Err_minmax = round(compute_error(r_mm$k_opt,   d$true_k), 1)
  ))
}

# ---- Summary table ----
print(results)

# ---- Grouped bar chart (like slide 63) ----
dev.new()
datasets_names <- results$Dataset
k_real  <- results$K_reel
k_brut  <- results$K_brut
k_z     <- results$K_zscore
k_mm    <- results$K_minmax

bar_data <- rbind(k_real, k_brut, k_z, k_mm)
barplot(bar_data,
        beside = TRUE,
        names.arg = datasets_names,
        col = c("red", "steelblue", "darkgreen", "goldenrod"),
        legend.text = c("K Réel", "K Brut", "K Z-Score", "K Min-Max"),
        args.legend = list(x = "topright", bty = "n"),
        xlab = "Dataset",
        ylab = "Nombre de clusters (K)",
        main = "Comparaison K réel vs K optimal détecté (CH Index)\nInfluence de la normalisation")