library(tidyverse)
library(janitor)

data <- read.csv("data/diabetic_data.csv")
data <- clean_names(data)

table(data$age)

#Plot for Readmission by age
ggplot(data, aes(x = age, fill = factor(readmitted))) +
  geom_bar(position = "fill") +
  labs(
    title = "Readmission Rate by Age Group",
    x = "Age Group",
    y = "Proportion"
  )
ggsave("outputs/plots/readmissionbyage_distribution.png")

#Plot for Time in Hospital vs. Readmission 
ggplot(data, aes(x = time_in_hospital, fill = factor(readmitted))) +
  geom_bar(position = "fill") +
  labs(
    title = "Readmission by Length of Stay",
    x = "Days in Hospital",
    y = "Proportion"
  )
ggsave("outputs/plots/Readmission_LengthofStay.png")

#Medication Burden
data$med_count <- data$num_medications

ggplot(data, aes(x = num_medications, fill = factor(readmitted))) +
  geom_histogram(position = "fill", bins = 30) +
  labs(
    title = "Medication Count vs Readmission",
    x = "Number of Medications",
    y = "Proportion"
  )
ggsave("outputs/plots/MedicationBurden_Readmission.png")

#Logistic Regression
data$readmit_30 <- ifelse(data$readmitted == "<30", 1, 0)

model <- glm(
  readmit_30 ~ age + time_in_hospital + num_medications,
  data = data,
  family = binomial
)

summary(model)

# Odds Ratio
exp(coef(model))