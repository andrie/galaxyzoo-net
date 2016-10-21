source("code/00-common-functions.R", local = TRUE)

source("code/00-settings.R") # defines dbConnection
library(dplyr)

qry <- ("
-- Count number of galaxies per class
SELECT specobjid, gz2class
FROM  zoo2MainSpecz
")

dat <- rxImport(
  RxSqlServerData(sqlQuery = qry, connectionString = dbConnection),
  colClasses = c(specobjid = "character")
)

head(dat)

top12 <- dat %>% 
  group_by(gz2class) %>% 
  summarise(n = n()) %>%
  arrange(-n) %>% 
  head(12) 
top12$gz2class

dat[!dat$gz2class %in% top12$gz2class, "gz2class"] <- "other"
dat %>% 
  group_by(gz2class) %>% 
  summarise(n = n()) %>%
  arrange(-n)

write_csv(dat, path = "data/xdf/galaxy_class.csv")


# dat %>% select(-GalaxyID) %>% summarise_each(funs(mean))
# dat %>% filter(Spiral > 0.9)
# dat %>% filter(`Disk edge-on` > 0.9)
# dat %>% filter(Other > 0.9)
# dat %>% arrange(desc(Ambiguous))
# 
# read_galaxy("471090") %>% plot()
# 
