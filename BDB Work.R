library(readxl)
players <- read_excel("C:/Users/jrbal/Downloads/Big Data Bowl/playersXLSX.xlsx")
View(players)

week1 <- read_excel("C:/Users/jrbal/Downloads/Big Data Bowl/week1XLSX.xlsx")

library(dplyr)

olinePos <- c("T", "C", "G")
dlinePos <- c("DE", "NT", "DT")

linePos <- c(olinePos, dlinePos)

oline <- players %>%
  filter(officialPosition %in% olinePos)
View(oline)

qbs <- players %>%
  filter(officialPosition == "QB")


testPLay <- week1 %>%
  filter(playId == 97)

qbInfo <- testPLay %>%
  filter(nflId %in% qbs$nflId)

olineInfo <- testPLay %>%
  filter(nflId %in% oline$nflId)

test_join <- inner_join(olineInfo, qbInfo, by = "frameId", suffix = c(".oline", ".qb"))

distFromQB <- function(play){
  xdis <- as.numeric(play[9]) - as.numeric(play[24])
  ydis <- as.numeric(play[10]) - as.numeric(play[25])
  disFromQB <- sqrt(xdis^2 + ydis^2)
  play["distFromQB"] <- disFromQB
}

qb_dist_test <- apply(test_join, MARGIN = 1, FUN = distFromQB)
new_test <- cbind(test_join, qb_dist_test)
View(new_test)
