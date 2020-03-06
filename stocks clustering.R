
# load libs -----------------------------------------------------

library(tidyverse)
library(tidyquant)
library(rvest)
library(factoextra)

# stocks ID -----------------------------------------------------

emiten <- xml2::read_html("https://britama.com/index.php/perusahaan-tercatat-di-bei/") %>% 
  html_nodes(xpath = "//a") %>% 
  html_text() %>% 
  as.data.frame() %>% 
  tail(-45) %>% 
  head(-11) %>% 
  pull() %>% 
  as.character()


# stocks price --------------------------------------------------
stocks <-  tq_get(x = emiten, from = "2019-01-01", to = "2020-01-01")
write.csv(stocks, "Documents/David/stocks.csv", row.names = F)
head(stocks)


stocks_wider <- stocks %>% 
  mutate(change = (lag(close) - close)/close*100) %>% 
  select(symbol, date, change, volume) %>% 
  na.omit() %>% 
  filter(!symbol %in% c("GOLD", "ANDI")) %>% 
  pivot_wider(names_from = date, values_from = c(change, volume)) %>% 
  drop_na()


stocks_wider %>% select(1:3)
# clustering stocks ---------------------------------------------

## PCA
stocks_PCA <- stocks_wider %>% 
  column_to_rownames(var = "symbol") %>% 
  prcomp(scale. = TRUE)

stocks_PCA %>% summary()

stocks_cluster <- stocks_PCA$x[,1:30] %>% 
  as.data.frame() %>% 
  kmeans(centers = 5)


fviz_cluster(stocks_cluster,data =stocks_PCA$x[,1:30] )


