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

