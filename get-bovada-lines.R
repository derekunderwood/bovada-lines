# Install libraries if not installed
{
  list.of.packages <- c("jsonlite",
                        "dplyr")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
}

library(dplyr)
library(jsonlite)
url <- "https://www.bovada.lv/services/sports/event/coupon/events/A/description/hockey?marketFilterId=def&preMatchOnly=true&eventsLimit=50&lang=en"


data <- jsonlite::fromJSON(url)
events <- data$events[[1]]

games <- events %>%
  filter(live == FALSE) %>%
  select(link)
games <- as.vector(games$link)

line_scrape <- function(game_links) {
  
  
  furl = paste0("https://www.bovada.lv/services/sports/event/coupon/events/A/description", game_links, "?lang=en")
  
  col_data = jsonlite::fromJSON(furl)
  col_data = col_data$events
  shots_mkt = col_data[[1]][["displayGroups"]][[1]][["markets"]][[7]]
  
  
  outlist <- list()
  
  for(i in 4:length(shots_mkt)) {
    x = data.frame(
      skater = rep(shots_mkt$description[i], 2),
      shots_mkt$outcomes[i]
    )
    
    outlist[[i]] = x
    
  }
  
  outlist = outlist[!sapply(outlist,is.null)]
  dplyr::bind_rows(outlist)
  
}

games
output_list <- lapply(games[2:length(games)], line_scrape)
output <- dplyr::bind_rows(output_list)