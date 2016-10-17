source("code/00-common-functions.R", local = TRUE)

source("code/00-settings.R") # defines dbConnection
library(dplyr)
library(readr)

qry <- ("
-- Count number of galaxies per class
SELECT specobjid, gz2class
FROM  zoo2MainSpecz
WHERE specobjid > 0
")

dat <- RODBC::sqlQuery(RODBC::odbcDriverConnect(dbConnection), 
                       qry, as.is = TRUE
)

nrow(dat)
head(dat)

top12 <- dat %>% 
  group_by(gz2class) %>% 
  summarise(n = n()) %>%
  arrange(-n) %>% 
  head(12) 
top12$gz2class

dat[!dat$gz2class %in% top12$gz2class, "gz2class"] <- "other"
nrow(dat)
length(unique(dat$specobjid))
dat %>% 
  group_by(gz2class) %>% 
  summarise(n = n()) %>%
  arrange(-n)

head(dat)
str(dat)

write_csv(dat, path = "data/xdf/galaxy_class.csv")


