summary(df)

df %>% count(alarm)
df %>%
  count(alarm, type) %>%
  arrange(alarm, type) %>%
  ggplot(aes(alarm, type, fill = n)) +
  geom_tile()

df %>% ggplot(aes(start, pi)) + geom_line() + facet_wrap(~equipment_ID)
df %>% ggplot(aes(start, po)) + geom_line() + facet_wrap(~equipment_ID)
df %>% ggplot(aes(pi, po)) + geom_line() + facet_wrap(~equipment_ID)
plotly::ggplotly()

df %>%
  pivot_longer(pi:po) %>%
  ggplot(aes(start, value)) +
  geom_line(aes(colour = name)) +
  facet_wrap(~equipment_ID)
