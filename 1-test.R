source("0-common-functions.R")

#  ------------------------------------------------------------------------

read_zoo(1) %>%  dim()
read_zoo(1) %>% plot()
read_zoo(121) %>% plot()
read_zoo("100263") %>% plot()

read_zoo_image_name("data/images_training_rev1/100263.jpg") %>% plot()

read_zoo(2) %>% resample_zoo(c(20, 20)) %>% dim()
read_zoo(2) %>% resample_zoo(c(20, 20)) %>% plot()
read_zoo(2) %>% resample_zoo(c(20, 20)) %>% flatten_zoo()
read_zoo(2) %>% resample_zoo(c(20, 20)) %>% flatten_zoo() %>% dim()
read_zoo(5) %>% resample_zoo(c(50, 50)) %>% plot()

read_zoo(2) %>% resample_zoo(c(50, 50)) %>% plot()
read_zoo(2) %>% trim_zoo(0.2) %>% resample_zoo(c(50, 50)) %>% plot()
read_zoo(2) %>% trim_zoo(0.2) %>% resample_zoo(c(50, 50)) %>% flatten_zoo() 
read_zoo(2) %>% trim_zoo(0.2) %>% resample_zoo(c(50, 50)) %>% flatten_zoo() %>% dim()

read_zoo(2) %>% trim_zoo(0.2) %>% resample_zoo(c(10, 10)) %>% plot()
read_zoo(121) %>% plot()
read_zoo(121) %>% trim_zoo(0.26) %>% plot()


read_zoo(121) %>% plot()
read_zoo(121) %>% trim_zoo(0.26) %>% plot()
read_zoo(121) %>% trim_zoo(0.26) %>% resample_zoo(c(69, 69)) %>% plot()
read_zoo(121) %>% trim_zoo(0.26) %>% resample_zoo(c(30, 30)) %>% plot()


#  ------------------------------------------------------------------------
