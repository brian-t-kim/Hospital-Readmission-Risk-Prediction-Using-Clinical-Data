library(tidyverse)
library(janitor)

# Load Data
data <- read.csv("data/diabetic_data.csv")

# Check Structure
glimpse(data)

# Clean data 
data <- clean_names(data)

glimpse(data)

# Binary Readmission 
data$readmit_30 <- ifelse(data$readmitted == "<30", 1, 0)

#Plot of Readmission
ggplot(data, aes(x = factor(readmit_30))) +
  geom_bar() +
  labs(
    title = "30-Day Hospital Readmission Distribution",
    x = "Readmitted within 30 days (1 = Yes)",
    y = "Count"
  )

#Save Output 
ggsave("outputs/plots/readmission_distribution.png")