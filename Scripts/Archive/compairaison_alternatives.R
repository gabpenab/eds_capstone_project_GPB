# Alternative code compairaison
calc_area_change <- function(delta_raster, threshold = 0.05) {
  
  # volver a probabilidad
  delta <- delta_raster / 1000
  
  # clasificar
  gain  <- delta > threshold
  loss  <- delta < -threshold
  stable <- abs(delta) <= threshold
  
  # área por celda
  cell_area <- terra::cellSize(delta, unit = "km")
  
  # áreas
  area_gain   <- terra::global(cell_area * gain, sum, na.rm=TRUE)[1,1]
  area_loss   <- terra::global(cell_area * loss, sum, na.rm=TRUE)[1,1]
  area_stable <- terra::global(cell_area * stable, sum, na.rm=TRUE)[1,1]
  area_total  <- terra::global(cell_area, sum, na.rm=TRUE)[1,1]
  
  # porcentajes
  data.frame(
    gain = (area_gain / area_total) * 100,
    loss = (area_loss / area_total) * 100,
    stable = (area_stable / area_total) * 100
  )
}
  
  results <- lapply(delta_list, calc_area_change)
  results_df <- do.call(rbind, results)
  
  # añadir nombres
  results_df$scenario <- names(delta_list)
  results_df
  
  results_df <- results_df %>%
    separate(scenario, into = c("scenario","period"), sep = "_")
  
  ggplot(results_df, aes(x = period, y = loss, fill = scenario)) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(
      y = "% area with loss of suitability",
      x = "Time period",
      fill = "Scenario",
      title = "Projected loss of suitable habitat"
    ) +
    theme_minimal()
  