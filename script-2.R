library(ggplot2)

set.seed(123)
diamonds_sample <- diamonds[sample(nrow(diamonds), 50000), ]

hist_p <- ggplot(diamonds_sample, aes(x = carat)) +
  geom_histogram(binwidth = 0.1, fill = "steelblue", color = "white") +
  labs(
    title = "Carat (Weight) of 50,000 Diamonds",
    x = "Carat",
    y = "Number of diamonds"
  )

ggsave(plot = hist_p, file = "diamonds.png")
