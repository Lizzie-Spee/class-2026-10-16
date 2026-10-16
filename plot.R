library(ggplot2)

weather <- read.csv("sarasota_weather.csv", check.names = FALSE)
weather_time <- as.POSIXct(
  weather$time,
  format = "%Y-%m-%d %H:%M:%S",
  tz = "America/New_York"
)
missing_time <- is.na(weather_time)
weather_time[missing_time] <- as.POSIXct(
  weather$time[missing_time],
  format = "%Y-%m-%d",
  tz = "America/New_York"
)
weather$time <- weather_time

weather_long <- rbind(
  data.frame(time = weather$time, variable = "Temperature (°C)",
             value = weather[["temperature_2m (°C)"]]),
  data.frame(time = weather$time, variable = "Humidity (%)",
             value = weather[["relative_humidity_2m (%)"]]),
  data.frame(time = weather$time, variable = "Rainfall (mm)",
             value = weather[["precipitation (mm)"]]),
  data.frame(time = weather$time, variable = "Wind speed (km/h)",
             value = weather[["wind_speed_10m (km/h)"]])
)

weather_long$variable <- factor(
  weather_long$variable,
  levels = c(
    "Temperature (°C)", "Humidity (%)",
    "Rainfall (mm)", "Wind speed (km/h)"
  )
)
weather_long$hours_since_start <- as.numeric(
  difftime(weather_long$time, min(weather$time), units = "hours")
)

weather_plot <- ggplot(weather_long, aes(x = hours_since_start, y = value)) +
  geom_ribbon(
    data = subset(weather_long, variable != "Rainfall (mm)"),
    aes(ymin = 0, ymax = value, fill = variable),
    alpha = 0.25
  ) +
  geom_smooth(
    data = subset(weather_long, variable != "Rainfall (mm)"),
    aes(color = variable),
    method = "loess",
    span = 0.25,
    se = FALSE,
    linewidth = 1.1
  ) +
  geom_col(
    data = subset(weather_long, variable == "Rainfall (mm)"),
    aes(fill = variable),
    width = 1,
    alpha = 0.8
  ) +
  facet_grid(variable ~ ., scales = "free_y") +
  scale_x_continuous(
    breaks = seq(0, max(weather_long$hours_since_start), by = 24),
    labels = \(hours) format(
      min(weather$time) + hours * 3600,
      "%b %d"
    )
  ) +
  scale_color_manual(values = c(
    "Temperature (°C)" = "#e84393",
    "Humidity (%)" = "#c4458f",
    "Wind speed (km/h)" = "#8f3d76"
  )) +
  scale_fill_manual(values = c(
    "Temperature (°C)" = "#f78ac1",
    "Humidity (%)" = "#df72ac",
    "Rainfall (mm)" = "#f4a6ce",
    "Wind speed (km/h)" = "#c781b2"
  )) +
  labs(
    title = "Sarasota, Florida",
    subtitle = "Hourly weather over the last seven days",
    x = NULL,
    y = NULL,
    caption = "Source: Open-Meteo"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.background = element_rect(fill = "#fff0f7", color = NA),
    panel.background = element_rect(fill = "#fff7fb", color = NA),
    panel.grid.major = element_line(color = "#f2d5e5"),
    panel.grid.minor = element_blank(),
    strip.text.y = element_text(color = "#8f3d76", face = "bold"),
    axis.text = element_text(color = "#75415f"),
    plot.title = element_text(color = "#8f3d76", face = "bold", size = 22),
    plot.subtitle = element_text(color = "#a65b86"),
    plot.caption = element_text(color = "#a65b86"),
    legend.position = "none"
  )

ggsave(
  "sarasota-weather.png",
  plot = weather_plot,
  width = 8,
  height = 10,
  dpi = 300,
  bg = "#fff0f7"
)
