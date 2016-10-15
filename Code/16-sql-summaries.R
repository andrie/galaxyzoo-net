source("00-settings.R") # defines dbConnection

sql_share_directory <- file.path("c:", "AllShare", Sys.getenv("USERNAME"))
#dir.create(sql_share_directory, recursive = TRUE)

sql <- RxInSqlServer(connectionString = dbConnection,
                     shareDir = sql_share_directory)



#  ------------------------------------------------------------------------



qry <- ("
-- Count number of galaxies per class
SELECT gz2class, 
       count(specobjid) as count_class
FROM            zoo2MainSpecz
GROUP BY gz2class
ORDER BY count_class DESC
")

galaxy_class_count <- rxImport(
  RxSqlServerData(sqlQuery = qry, connectionString = dbConnection)
)

galaxy_class_count <- galaxy_class_count %>% mutate(
  class = factor(gz2class, levels = galaxy_class_count$gz2class)
)

head(galaxy_class_count, 10)
str(galaxy_class_count, 10)
nrow(galaxy_class_count)


#  ------------------------------------------------------------------------

galaxy_class_count[1:20, ] %>% arrange(-count_class)


library(ggplot2)
ggplot(galaxy_class_count[1:20, ], 
       aes(x=class, y = count_class)) + 
  geom_bar(stat = "identity") +
  xlab("Galaxy class") +
  ylab(NULL) +
  coord_flip()
1  



#  ------------------------------------------------------------------------

qry <- ("
SELECT specobjid, gz2class, petroR90_r
FROM (
  SELECT zoo2MainSpecz.gz2class, 
         PhotoObjDR7.petroR90_r, 
         zoo2MainSpecz.specobjid, 
         Rank()
  OVER (PARTITION BY zoo2MainSpecz.gz2class 
        ORDER BY PhotoObjDR7.petroR90_r DESC) as petrosian_rank
  FROM zoo2MainSpecz 
  INNER JOIN PhotoObjDR7 
  ON zoo2MainSpecz.dr7objid = PhotoObjDR7.dr7objid
) AS derived
WHERE petrosian_rank <= 12
")

brightest_galaxies <- rxImport(
  RxSqlServerData(sqlQuery = qry, 
                  connectionString = dbConnection,
                  colClasses = c(specobjid = "character"))
)

head(brightest_galaxies, 10)

library(dplyr)
brightest_galaxies %>% filter(gz2class %in% galaxy_class_count$gz2class[1:10])




