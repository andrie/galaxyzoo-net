library(tidyr)
library(ggplot2)


prevLogName <- tail(
  list.files(path = "logs", pattern = "scored_model.*.txt", full.names = TRUE),
  1)
prevLog <- readLines(prevLogName)
head(prevLog)


plot_log <- function(filename){
  stopifnot(require(tidyr))
  stopifnot(require(ggplot2))
  x <-readLines(prevLogName)
  
  learningrate <- as.numeric(
    gsub("Learning rate adapted to: ([\\d\\.]*)", "\\1", x[grepl("Learning rate", x)])
  )
  
  x <- x[!grepl("Learning rate", x)]
  dat <- data.frame(
    iteration = as.numeric(gsub(".*?(\\d+)/\\d+.*", "\\1", x)),
    error = as.numeric(gsub(".*?(\\d+\\.\\d+).*", "\\1", x))
  )
  dat$learningrate <- rep(learningrate, each = 5)[1:nrow(dat)]
  head(dat)
  
  dat %>% gather(measure, value, -iteration) %>% 
    ggplot(aes(x=iteration, y = value, group = measure)) + 
    geom_point(size = 1) + 
    geom_smooth(span = 0.2) +
    facet_grid(measure~., scales = "free_y") +
    scale_x_continuous(limits = c(0, 100))
  
  ggplot(dat, aes(x = iteration, y = error)) + 
    geom_point() + 
    geom_smooth(span = 0.2) +
    ggtitle("Model error") +
    scale_y_continuous(limits = c(0, NA))
  
}

plot_log(prevLogName)
