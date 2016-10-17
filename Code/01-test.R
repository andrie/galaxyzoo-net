source("code/00-common-functions.R", local = TRUE)

#  ------------------------------------------------------------------------

read_galaxy(1) %>%  dim()
read_galaxy(1) %>%  class()
read_galaxy(1) %>% plot_pretty()
read_galaxy(121) %>% plot_pretty()
read_galaxy("100263") %>% plot_pretty()

read_galaxy_image_name("data/images_training_rev1/100263.jpg") %>% plot_pretty()

read_galaxy("100263") %>% resize_galaxy(c(20, 20)) %>% dim()
read_galaxy("100263") %>% resize_galaxy(c(20, 20)) %>% plot_pretty
read_galaxy("100263") %>% resize_galaxy(c(20, 20)) %>% flatten_galaxy()
read_galaxy("100263") %>% resize_galaxy(c(20, 20)) %>% flatten_galaxy() %>% dim()
read_galaxy(5) %>% resize_galaxy(c(50, 50)) %>% plot_pretty()

read_galaxy("100263") %>% resize_galaxy(c(50, 50)) %>% plot_pretty()
read_galaxy("100263") %>% crop_galaxy(0.2) %>% resize_galaxy(c(50, 50)) %>% plot_pretty()
read_galaxy("100263") %>% crop_galaxy(0.2) %>% resize_galaxy(c(50, 50)) %>% flatten_galaxy() 
read_galaxy("100263") %>% crop_galaxy(0.2) %>% resize_galaxy(c(50, 50)) %>% flatten_galaxy() %>% dim()

read_galaxy("100263") %>% crop_galaxy(0.2) %>% resize_galaxy(c(10, 10)) %>% plot_pretty()
read_galaxy(121) %>% plot_pretty
read_galaxy(121) %>% crop_galaxy(0.26) %>% plot_pretty


read_galaxy(121) %>% plot_pretty()
read_galaxy(121) %>% crop_galaxy(0.26) %>% plot_pretty()
read_galaxy(121) %>% crop_galaxy(0.26) %>% resize_galaxy(c(69, 69)) %>% plot_pretty()
read_galaxy(121) %>% crop_galaxy(0.26) %>% resize_galaxy(c(30, 30)) %>% plot_pretty()


read_galaxy(121) %>% dim()
read_galaxy(121) %>% rotate_galaxy(45) %>% dim()
read_galaxy(121) %>% rotate_galaxy(45) %>% crop.borders(nx = (599-424)/2, ny = 599-424) %>% dim()
read_galaxy(121) %>% plot_pretty()
# read_galaxy(121) %>% rotate_galaxy(45) %>% crop.borders(nx = (599-424)/2, ny = (599-424)/2) %>% plot_pretty()
read_galaxy(121) %>% plot_pretty()
read_galaxy(121) %>% rotate_galaxy(15) %>% plot_pretty()
read_galaxy(121) %>% rotate_galaxy(30) %>% plot_pretty()
read_galaxy(121) %>% rotate_galaxy(45) %>% plot_pretty()


read_galaxy(121) %>% plot_pretty()
read_galaxy(121) %>% isoblur(2) %>% plot_pretty()
read_galaxy(121) %>% isoblur(5) %>% plot_pretty()
read_galaxy(121) %>% isoblur(7) %>% plot_pretty()


#  ------------------------------------------------------------------------


gxy <- read_galaxy("100263")
layout(matrix(1:4, nrow = 2))
library(foreach)
foreach(i = seq(0, 6, by = 2)) %do% {
  gxy %>% isoblur(i) %>% plot_pretty()
  invisible(NULL)
}
layout(1)


#  ------------------------------------------------------------------------
