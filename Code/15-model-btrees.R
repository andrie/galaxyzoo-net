# Compute context ---------------------------------------------------------

source("code/00-settings.R") # defines dbConnection

sql_share_directory <- file.path("c:", "AllShare", Sys.getenv("USERNAME"))
#dir.create(sql_share_directory, recursive = TRUE)

sql <- RxInSqlServer(connectionString = dbConnection,
                     shareDir = sql_share_directory)
local <- RxLocalParallel()


# Train model -------------------------------------------------------------

sql_query = ("
SELECT
(petroMag_u - petroMag_g) AS petroMag_diff_ug, 
(petroMag_g - petroMag_r) AS petroMag_diff_gr, 
(petroMag_r - petroMag_i) AS petroMag_diff_ri, 
(petroMag_i - petroMag_z) AS petroMag_diff_iz, 
(fiberMag_u - fiberMag_g) AS fiberMag_diff_ug, 
(fiberMag_g - fiberMag_r) AS fiberMag_diff_gr, 
(fiberMag_r - fiberMag_i) AS fiberMag_diff_ri, 
(fiberMag_i - fiberMag_z) AS fiberMag_diff_iz, 
(fiber2Mag_u - fiber2Mag_g) AS fiber2Mag_diff_ug, 
(fiber2Mag_g - fiber2Mag_r) AS fiber2Mag_diff_gr, 
(fiber2Mag_r - fiber2Mag_i) AS fiber2Mag_diff_ri, 
(fiber2Mag_i - fiber2Mag_z) AS fiber2Mag_diff_iz, 
(psfMag_u - psfMag_g) AS psfMag_diff_ug, 
(psfMag_g - psfMag_r) AS psfMag_diff_gr, 
(psfMag_r - psfMag_i) AS psfMag_diff_ri, 
(psfMag_i - psfMag_z) AS psfMag_diff_iz, 
(devMag_u - devMag_g) AS devMag_diff_ug, 
(devMag_g - devMag_r) AS devMag_diff_gr, 
(devMag_r - devMag_i) AS devMag_diff_ri, 
(devMag_i - devMag_z) AS devMag_diff_iz, 
(expMag_u - expMag_g) AS expMag_diff_ug, 
(expMag_g - expMag_r) AS expMag_diff_gr, 
(expMag_r - expMag_i) AS expMag_diff_ri, 
(expMag_i - expMag_z) AS expMag_diff_iz, 
(modelMag_u - modelMag_g) AS modelMag_diff_ug, 
(modelMag_g - modelMag_r) AS modelMag_diff_gr, 
(modelMag_r - modelMag_i) AS modelMag_diff_ri, 
(modelMag_i - modelMag_z) AS modelMag_diff_iz, 
(cModelMag_u - cModelMag_g) AS cModelMag_diff_ug,
(cModelMag_g - cModelMag_r) AS cModelMag_diff_gr, 
(cModelMag_r - cModelMag_i) AS cModelMag_diff_ri, 
(cModelMag_i - cModelMag_z) AS cModelMag_diff_iz, 
petroRad_u, petroR50_u, petroR90_u, 
q_u, u_u, 
mE1_u, mE2_u, 
deVRad_u, deVAB_u, deVPhi_u, 
expRad_u, expAB_u, 
lnLStar_u, lnLDeV_u, 
fracDev_u, type_u,
petroRad_g, petroR50_g, petroR90_g, 
q_g, u_g, 
mE1_g, mE2_g, 
deVRad_g, deVAB_g, deVPhi_g, 
expRad_g, expAB_g, 
lnLStar_g, lnLDeV_g, 
fracDev_g, type_g, 
petroRad_r, petroR50_r, petroR90_r, 
q_r, u_r, 
mE1_r, mE2_r, 
deVRad_r, deVAB_r, deVPhi_r, 
expRad_r, expAB_r, 
lnLStar_r, lnLDeV_r, 
fracDev_r, type_r, 
petroRad_i, petroR50_i, petroR90_i, 
q_i, u_i, 
mE1_i, mE2_i, 
deVRad_i, deVAB_i, deVPhi_i, 
expRad_i, expAB_i, 
lnLStar_i, lnLDeV_i, 
fracDev_i, type_i, 
petroRad_z, petroR50_z, petroR90_z, 
q_z, u_z, 
mE1_z, mE2_z, 
deVRad_z, deVAB_z, deVPhi_z, 
expRad_z, expAB_z, 
lnLStar_z, lnLDeV_z, 
fracDev_z, type_z,
zs.class
FROM [galaxyzoo].[dbo].[gz2_labels] zs, [galaxyzoo].[dbo].[zooSpecPhotoObjDR12] po12
Where zs.dr8objid = po12.objid
")

train_table <- RxSqlServerData(sqlQuery = sql_query,
                               connectionString = dbConnection,
                               colInfo = list(class = list(type = "factor"), 
                                              sample = list(type = "factor")), 
                               rowsPerRead = 5000 )

predictions_table <- RxSqlServerData(table = "predictions",
                                     connectionString = dbConnection, 
                                     rowsPerRead = 5000)


# Multi-classification model evaluation metrics ---------------------------

evaluate_model <- function(data, observed, predicted) {
  confusion <- table(data[[observed]], data[[predicted]])
  print(confusion)
  num_classes <- nrow(confusion)
  
  zeroes <- rep(0, num_classes)
  tp <- zeroes
  fn <- zeroes
  fp <- zeroes
  tn <- zeroes
  accuracy  <- zeroes
  precision <- zeroes
  recall    <- zeroes
  
  for(i in 1:num_classes) {
    tp[i] <- sum(confusion[ i,  i])
    fn[i] <- sum(confusion[-i,  i])
    fp[i] <- sum(confusion[ i, -i])
    tn[i] <- sum(confusion[-i, -i])
  }
  accuracy  <- (tp + tn) / (tp + fn + fp + tn)
  precision <- tp / (tp + fp)
  recall    <- tp / (tp + fn)
  
  
  print(paste(c("Accuracy: ",  accuracy), collapse = " "))
  print(paste(c("Precision: ", precision), collapse = " "))
  print(paste(c("Recall: ",    recall), collapse = " "))
  
  overall_accuracy <- sum(tp) / sum(confusion)
  average_accuracy <- sum(accuracy) / num_classes
  micro_precision  <- sum(tp) / (sum(tp) + sum(fp))
  macro_precision  <- sum(precision) / num_classes
  micro_recall     <- sum(tp) / (sum(tp) + sum(fn))
  macro_recall     <- sum(recall) / num_classes
  
  metrics <- c("Overall accuracy" = overall_accuracy,
               "Average accuracy" = average_accuracy,
               "Micro-averaged Precision" = micro_precision,
               "Macro-averaged Precision" = macro_precision,
               "Micro-averaged Recall" = micro_recall,
               "Macro-averaged Recall" = macro_recall)
  return(metrics)
}

formula = ("
class ~ petroMag_diff_ug + petroMag_diff_gr + petroMag_diff_ri + petroMag_diff_iz +
fiberMag_diff_ug + fiberMag_diff_gr + fiberMag_diff_ri + fiberMag_diff_iz +
fiber2Mag_diff_ug + fiber2Mag_diff_gr + fiber2Mag_diff_ri + fiber2Mag_diff_iz +
psfMag_diff_ug + psfMag_diff_gr + psfMag_diff_ri + psfMag_diff_iz +
devMag_diff_ug + devMag_diff_gr + devMag_diff_ri + devMag_diff_iz +
expMag_diff_ug + expMag_diff_gr + expMag_diff_ri + expMag_diff_iz +
modelMag_diff_ug + modelMag_diff_gr + modelMag_diff_ri + modelMag_diff_iz +
cModelMag_diff_ug + cModelMag_diff_gr + cModelMag_diff_ri + cModelMag_diff_iz +
petroRad_u + petroR50_u + petroR90_u + q_u + u_u + mE1_u + mE2_u + deVRad_u + deVAB_u + deVPhi_u + expRad_u + expAB_u + lnLStar_u + lnLDeV_u + fracDev_u + type_u +
petroRad_g + petroR50_g + petroR90_g + q_g + u_g + mE1_g + mE2_g + deVRad_g + deVAB_g + deVPhi_g + expRad_g + expAB_g + lnLStar_g + lnLDeV_g + fracDev_g + type_g + 
petroRad_r + petroR50_r + petroR90_r + q_r + u_r + mE1_r + mE2_r + deVRad_r + deVAB_r + deVPhi_r + expRad_r + expAB_r + lnLStar_r + lnLDeV_r + fracDev_r + type_r + 
petroRad_i + petroR50_i + petroR90_i + q_i + u_i + mE1_i + mE2_i + deVRad_i + deVAB_i + deVPhi_i + expRad_i + expAB_i + lnLStar_i + lnLDeV_i + fracDev_i + type_i +
petroRad_z + petroR50_z + petroR90_z + q_z + u_z + mE1_z + mE2_z + deVRad_z + deVAB_z + deVPhi_z + expRad_z + expAB_z + lnLStar_z + lnLDeV_z + fracDev_z + type_z
")


# Boosted tree modeling ---------------------------------------------------

rxSetComputeContext(sql)
boosted_model <- rxBTrees(formula = formula,
                          data = train_table,
                          learningRate = 0.2,
                          minSplit = 10,
                          minBucket = 5,
                          nTree = 10,
                          seed = 5,
                          lossFunction = "multinomial")



# Evaluate Multi-classification model -------------------------------------

rxPredict(modelObject = boosted_model,
          data = train_table,
          outData = predictions_table,
          type = "prob",
          writeModelVars = FALSE,
          extraVarsToWrite = "class",
          overwrite = TRUE)



#  ------------------------------------------------------------------------


qry <- ("
SELECT class, 
       class_Pred, 
       count(class) as count
FROM   predictions
GROUP By class_Pred, 
         class
")
confusion_data <- RxSqlServerData(sqlQuery = qry, connectionString = dbConnection)
x <- rxImport(confusion_data)

head(x)


#  ------------------------------------------------------------------------


xtabs(count ~ class + class_Pred, x)

rxFactors(predictions_table, factorInfo = c("class", "class_Pred"))

predictions_df = rxDataStep(predictions, varsToKeep = c("class", "class_Pred"))
predictions_df[, "class"]      = as.factor(predictions_df[, "class"] )
predictions_df[, "class_Pred"] = as.factor(predictions_df[, "class_Pred"])
levels(predictions_df[, "class_Pred"]) = levels(predictions_df[, "class"])
head(predictions_df)

boosted_metrics <- evaluate_model(data = predictions_df,
                                  observed = "class",
                                  predicted = "class_Pred")


# Multi-classification model evaluation metrics results -------------------

metrics_df <- rbind(boosted_metrics)
metrics_df <- as.data.frame(metrics_df)
rownames(metrics_df) <- NULL
Algorithms <- c("Boosted Decision Tree")
metrics_df <- cbind(Algorithms, metrics_df)
print(metrics_df)

metrics_table <- RxSqlServerData(table = "metrics",
                                 connectionString = dbConnection)
rxSetComputeContext(local)

rxDataStep(inData = metrics_df,
           outFile = metrics_table,
           overwrite = TRUE)
