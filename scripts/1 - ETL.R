# dataset kindly provided by Kaggle : https://www.kaggle.com/datasets/orvile/packaging-industry-anomaly-detection-dataset

library(tidyverse)
library(lubridate)

df <- read_csv("data/raw_data.csv")

glimpse(df)

df <- df %>%
  mutate(
    across(c(start, end), ~ as.POSIXct(.x, origin = "1970-01-01", tz = "UTC")),
    elapsed = dmilliseconds(elapsed)
  )

write_rds(df, "data/clean_data.rds")
