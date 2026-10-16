url <- paste0(
  "https://api.open-meteo.com/v1/forecast",
  "?latitude=27.3364&longitude=-82.5307",
  "&hourly=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m",
  "&past_days=7&forecast_days=1",
  "&timezone=America%2FNew_York&format=csv"
)

# Skip the API's location metadata and blank line before the hourly table.
weather <- read.csv(url, skip = 3, check.names = FALSE)

weather$time <- as.POSIXct(
  weather$time,
  format = "%Y-%m-%dT%H:%M",
  tz = "America/New_York"
)

end_time <- Sys.time()
start_time <- end_time - 7 * 24 * 60 * 60
weather <- weather[weather$time >= start_time & weather$time <= end_time, ]

write.csv(weather, "sarasota_weather.csv", row.names = FALSE)
