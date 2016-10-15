source("0-common-functions.R")
library(readr)
library(magrittr)
library(dplyr)

solutions <- "data/training_solutions_rev1.csv"
solutions_data <- read_csv(solutions)

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
# dat %>% select(-GalaxyID) %>% summarise_each(funs(mean))
# special

plot_galaxy_type <- function(type, dat, n = 12){
  # type <- as.name(type)
  subs <- dat %>% 
    arrange_(type) %>% 
    select_("GalaxyID", type) %>% 
    tail(12) %>% 
    select_("GalaxyID")

  
  oldpar <- par(mfrow = c(3, 4))
  on.exit(par(oldpar))
  for(ff in subs$GalaxyID){
    read_galaxy(as.character(ff)) %>% plot_pretty()
  }
}

plot_galaxy_type("Globular", dat)
plot_galaxy_type("Star", dat)
plot_galaxy_type("Spiral", dat)
plot_galaxy_type("Disk", dat)
plot_galaxy_type("Other", dat)
plot_galaxy_type("Ambiguous", dat)

