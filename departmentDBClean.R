library(dplyr)
library(RSQLite)

# Database path
dirPath <- ifelse(exists("dirPath"), dirPath, "C:/Users/jmc6538/Documents/BDSHProjects/CART")

# Connect to database
BDSHProjects <- dbConnect(dbDriver("SQLite"), paste0(dirPath, "/BDSHProjects.sqlite"))

# read in researcher table
researchers <- tbl(BDSHProjects, "researchers") %>% 
  collect() %>% 
  as.data.frame(stringsAsFactors = FALSE)


# list of department options
deptList <- list(`Dell Medical School` = 
       list("Dell Pediatric Research Institute",
            "Diagnostic Medicine",
            "Health Social Work",
            "Internal Medicine",
            "Medical Education",
            "Neurology",
            "Neurosurgery",
            "Oncology",
            "Ophthalmology",
            "Pediatrics",
            "Population Health",
            "Psychiatry",
            "Surgery and Perioperative Care",
            "Women's Health",
            "Other Dell Medical School"),
     `UT` = list("School of Social Work",
                 "School of Nursing",
                 "College of Pharmacy",
                 "Other UT Austin", 
                 "Other UT System"),
     `Other` = list("Other"))
deptList <- unlist(deptList, use.names = FALSE)



# Update Primary department -----------------------------------------------

# remove `Department of ` from any departments
researchers$primaryDept <- gsub("Department of | - Division of Dermatology|Department Chair, ", 
                                "", researchers$primaryDept, ignore.case = TRUE)

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]


# It was verified that everybody with department "medicine" was Internal
# Medicine. Those observations are updated here.
researchers[which(!researchers$primaryDept %in% deptList), "primaryDept"] <- 
  gsub("Medicine", "Internal Medicine", 
       researchers[which(!researchers$primaryDept %in% deptList), "primaryDept"], ignore.case = TRUE)

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]


# Edit Population Health variants
researchers$primaryDept <- gsub("Pop Health", "Population Health", researchers$primaryDept)

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]


# Change Molly Lopez department to School of Social Work (which still needs to
# be updated after this update)
researchers$primaryDept <- gsub("Office of the Associate Dean for Research", "School of Social Work", researchers$primaryDept)

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]


# Dermatology is within internal medicine make change here
researchers$primaryDept <- gsub("Dermatology", "Internal Medicine", researchers$primaryDept)

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]



# change anesthesiology to surgery and preoperative care
researchers$primaryDept <- gsub("Anesthesiology ", "Surgery and Perioperative Care", researchers$primaryDept)

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]


# Change Womens Health to Women's Health
researchers$primaryDept <- gsub("Womens Health", "Women's Health", researchers$primaryDept)

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]


# UTHealth to Other UT System
researchers$primaryDept <- gsub("UTHealth", "Other UT System", researchers$primaryDept)

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]


# add school of to social work and nursing
researchers$primaryDept <- 
  ifelse(researchers$primaryDept %in% c("Social Work", "Nursing "), 
         paste0("School of ", researchers$primaryDept), 
         researchers$primaryDept)

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]


# trim extra whitespace
researchers$primaryDept <- trimws(researchers$primaryDept)

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]


# Change outside to Other
researchers[grepl("outside", researchers$primaryDept), "primaryDept"] <- "Other"

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]


# change the departments of students/residents

# Emily Clarke, Harrison Miner, and Charlotte Heron should be Medical Education
researchers[grepl("Emily Clarke|Harrison Miner|Charlotte Heron|Benjamin Kopp", researchers$researcherName), "primaryDept"] <- "Medical Education"

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]


# Savannah Wooten should be Surgery and Perioperative Care
researchers[grepl("Savannah Wooten", researchers$researcherName), "primaryDept"] <- "Surgery and Perioperative Care"

# Remaining entries to be updated
researchers[which(!researchers$primaryDept %in% deptList), ]





# Secondary Department ----------------------------------------------------

# remove `Department of ` from any departments
researchers$secondaryDept <- gsub("Department of | - Division of Dermatology|Department Chair, ", 
                                "", researchers$secondaryDept, ignore.case = TRUE)

# Remaining entries to be updated
researchers[which(!(researchers$secondaryDept %in% deptList) & !is.na(researchers$secondaryDept)), ]


# there is someone with Psychology, which is not a department. Replacing with NA
researchers[researchers$secondaryDept == "Psychology" & !is.na(researchers$secondaryDept), "secondaryDept"] <- NA

# Remaining entries to be updated
researchers[which(!(researchers$secondaryDept %in% deptList) & !is.na(researchers$secondaryDept)), ]


# Those with department "medicine" should be Internal Medicine
researchers[which(!researchers$secondaryDept %in% deptList), "secondaryDept"] <- 
  gsub("Medicine", "Internal Medicine", 
       researchers[which(!researchers$secondaryDept %in% deptList), "secondaryDept"], ignore.case = TRUE)

# Remaining entries to be updated
researchers[which(!(researchers$secondaryDept %in% deptList) & !is.na(researchers$secondaryDept)), ]


# Molly Lopez's primary department is school of social work, secondary should be missing
researchers[researchers$researcherName == "Molly Lopez" & !is.na(researchers$researcherName), "secondaryDept"] <- NA

# Remaining entries to be updated
researchers[which(!(researchers$secondaryDept %in% deptList) & !is.na(researchers$secondaryDept)), ]


# Marissa Mery does not have secondary department according to directory it is removed
researchers[researchers$researcherName == "Marissa Mery" & !is.na(researchers$researcherName), "secondaryDept"] <- NA

# Remaining entries to be updated
researchers[which(!(researchers$secondaryDept %in% deptList) & !is.na(researchers$secondaryDept)), ]


# Adrienne Dula's secondary department should be Diagnostic Medicine
researchers[researchers$researcherName == "Adrienne Dula" & !is.na(researchers$researcherName), "secondaryDept"] <- "Diagnostic Medicine"

# Remaining entries to be updated
researchers[which(!(researchers$secondaryDept %in% deptList) & !is.na(researchers$secondaryDept)), ]


# Corrine Jones' secondary department should be Other UT Austin
researchers[grepl("Corinne", researchers$researcherName), "secondaryDept"] <- "Other UT Austin"

# Remaining entries to be updated
researchers[which(!(researchers$secondaryDept %in% deptList) & !is.na(researchers$secondaryDept)), ]



# I feel like Carmen Valdez's primary department is pop health and secondary
# department should be social work
researchers[grepl("Carmen", researchers$researcherName), c("primaryDept", "secondaryDept")] <- c("Population Health", "School of Social Work")

# Remaining entries to be updated
researchers[which(!(researchers$secondaryDept %in% deptList) & !is.na(researchers$secondaryDept)), ]
