
# load libs -----------------------------------------------------
library(dplyr)
library(tidyquant)
library(rvest)
library(jsonlite)

# setup ---------------------------------------------------------
sector <- c("AGRI","BASIC-IND","CONSUMER","FINANCE",
            "INFRASTRUCT","MINING","MISC-IND","PROPERTY")
papan <- c("Akselerasi","PENGEMBANGAN","Utama")
IDX_final <- NULL


# get TRADE sector ----------------------------------------------
for (l in 2:length(papan)) {
  trade <- read_json(paste0("https://www.idx.co.id/umbraco/Surface/StockData/GetSecuritiesStock?code=&sector=TRADE&board=",papan[l],"&draw=2&length=1"))
  total_emiten <- trade$recordsTotal
  trade <- read_json(paste0("https://www.idx.co.id/umbraco/Surface/StockData/GetSecuritiesStock?code=&sector=TRADE&board=",papan[l],"&draw=2&length=",total_emiten))
  for (j in 1:total_emiten) {
    temp <- trade$data[[j]] %>% 
      as.data.frame() %>% 
      select(1:5) %>% 
      mutate(sector = "TRADE")
    IDX_final <- bind_rows(IDX_final,temp)
  }
}

# Alasan kenapa sector trade dipisah adalah karena total length yang bisa diambil hanya 150, 
# sedangkan total emiten trade sekitar 167, oleh sebab itu crawling sector trade dipecah berdasarkan papan

# get other sector ----------------------------------------------

for (i in 1:length(sector)) {
  temp <- read_json(paste0("https://www.idx.co.id/umbraco/Surface/StockData/GetSecuritiesStock?code=&sector=",sector[i],"&board=&draw=2&length=1") )
  total_emiten <- temp$recordsTotal
    full_sector <- read_json(paste0("https://www.idx.co.id/umbraco/Surface/StockData/GetSecuritiesStock?code=&sector=",sector[i],"&board=&draw=2&length=",total_emiten))
  for (j in 1:total_emiten) {
      temp <- full_sector$data[[j]] %>% 
        as.data.frame() %>% 
        select(1:5) %>% 
        mutate(sector = sector[i])
      IDX_final <- bind_rows(IDX_final,temp)
  }
}


# write data into csv -------------------------------------------
IDX_final %>% 
  write.csv("daftar_saham.csv", row.names = F)


