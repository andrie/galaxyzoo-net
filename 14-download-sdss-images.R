qry <- ("
        SELECT zoo2MainSpecz.specobjid, 
       zoo2MainSpecz.ra, 
        zoo2MainSpecz.dec, 
        zoo2MainSpecz.gz2class, 
        zoo2MainSpecz.total_classifications, 
        PhotoObjDR7.run, 
        PhotoObjDR7.rerun, 
        PhotoObjDR7.camcol, 
        PhotoObjDR7.field, 
        PhotoObjDR7.petroMag_r, 
        PhotoObjDR7.type, 
        PhotoObjDR7.psfMag_r, 
        PhotoObjDR7.psfMagErr_r, 
        PhotoObjDR7.modelMag_r,
        PhotoObjDR7.petroR90_r
        FROM   PhotoObjDR7 INNER JOIN zoo2MainSpecz 
        ON PhotoObjDR7.dr7objid = zoo2MainSpecz.dr7objid
        ")

dbConnection <- 'Driver={SQL Server};Server=adv-win-dsvm.westeurope.cloudapp.azure.com\\SQL16,8484;Database=GalaxyZoo;Uid=andrie;Pwd=voyager70$'

library(RODBC)
conn <- odbcDriverConnect(dbConnection)
dat <- sqlQuery(conn, qry, as.is=TRUE)
head(dat)
str(dat)

make_image_url <- function(dat){
  # url <- "http://dr12.sdss3.org/fields/runCamcolField?run=%s&camcol=%s&field=%s"
  # with(dat, sprintf(url, run, camcol, field))
  url <- "http://dr12.sdss3.org/sas/dr12/boss/photoObj/frames/301/%s/%s/frame-irg-%06d-%s-%04d.jpg"
  with(dat, sprintf(url, run, camcol, run, camcol, field))
}

library(magrittr)
make_image_url(dat) %>% head()

# http://dr12.sdss3.org/fields/runCamcolField?run=4570&camcol=4&field=135
# http://dr12.sdss3.org/sas/dr12/boss/photoObj/frames/301/4570/4/frame-irg-004570-4-0135.jpg

download_image <- function(url){
  download.file(url, destfile = )
}

# for(i in 1:12477){
# for(i in seq_len(nrow(dat))){
#   message(i)
#   try(
#     download.file(
#       make_image_url(dat[i, ]), 
#       mode = "wb",
#       quiet = TRUE,
#       destfile = file.path(
#         "sdss_images", 
#         paste0(as.character(dat$specobjid[i]), ".jpg")
#       )
#     )
#   )
# }

# http://skyservice.pha.jhu.edu/DR10/ImgCutout/getjpeg.aspx?ra=224.5941&dec=-1.09&width=512&height=512


make_image_url <- function(dat, size = 424){
  url <- "http://skyservice.pha.jhu.edu/DR10/ImgCutout/getjpeg.aspx?ra=%s&dec=%s&scale=%s&width=%s&height=%s"
  with(dat, sprintf(url, ra, dec, 0.02 * petroR90_r, size, size))
}

# 151.4666 SDSS image pixels per arcmimnute
# 2.524443 SDSS image pixels per arcsec
# 0.0001100353 arcsec per pixel
#
# Images of galaxies for classification were generated from the
# SDSS ImgCutout web service (Nieto-Santisteban, Szalay &                               Gray 2004) from the Legacy and Stripe 82 normal depth
# surveys. Each image is a gri colour composite 424 × 424
# pixels in size, scaled to (0.02×petroR90_r) arcsec per pixel.
#
# petroR90_r	real	4	arcsec	EXTENSION_RAD	Radius containing 90% of Petrosian flux

make_image_url(dat) %>% head()

for(i in seq_len(nrow(dat))){
  message(i)
  try(
    download.file(
      make_image_url(dat[i, ]),
      mode = "wb",
      quiet = TRUE,
      destfile = file.path(
        "sdss_cutout",
        paste0(dat$specobjid[i], ".jpg")
      )
    )
  )
  Sys.sleep(0.025)
}


