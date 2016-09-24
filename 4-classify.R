source("0-common-functions.R")

library(readr)
library(dplyr)
library(magrittr)


solutions <- "data/training_solutions_rev1.csv"
solutions_data <- read_csv(solutions)
head(solutions_data)
View(solutions_data)

dat <- solutions_data %>% 
  # select(GalaxyID, one_of(type_questions)) %>% 
  rename(
    Globular = Class1.1,
    Star     = Class1.3
  ) %>% 
  mutate(
    Disk     = Class2.1,
    Spiral   = Class4.1,
    Other    = Class4.2
  ) %>% 
  select(
    -starts_with("Class")
  ) 

dat %>% 
  mutate(
    sum = rowSums(.[, -1])
  )


dat$Ambiguous <- 1 - dat %>% select(-GalaxyID) %>% apply(1, max)
dat
hist(dat$Ambiguous,
     breaks = seq(0, 1, length.out = 11))

dat$Ambiguous %>% hist(breaks = seq(0, 1, length.out = 11), plot = FALSE) %$% counts

dat %>% summarise_each(funs(mean))

dat$Class <- dat %>% select(-GalaxyID) %>% apply(1, which.max) %>% names(dat)[-1][.]
dat

write_csv(dat[, c("GalaxyID", "Class")], path = "data/galaxy_class.csv")


# dat %>% select(-GalaxyID) %>% summarise_each(funs(mean))
# dat %>% filter(Spiral > 0.9)
# dat %>% filter(`Disk edge-on` > 0.9)
# dat %>% filter(Other > 0.9)
# dat %>% arrange(desc(Ambiguous))
# 
# read_galaxy("471090") %>% plot()
# 
