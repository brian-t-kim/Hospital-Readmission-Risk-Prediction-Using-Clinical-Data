library(tidyverse)
library(janitor)

data <- read.csv("data/diabetic_data.csv")
data <- clean_names(data)

#Diagnosis Categories 
data$diag_group <- case_when(
  grepl("250", data$diag_1) ~ "Diabetes",
  grepl("414|428|410", data$diag_1) ~ "Cardiac",
  grepl("486|491|492", data$diag_1) ~ "Respiratory",
  TRUE ~ "Other"
)

table(data$diag_group)

ggplot(data, aes(x = diag_group, fill = factor(readmitted))) +
  geom_bar(position = "fill") +
  labs(
    title = "Readmission by Diagnosis Category",
    x = "Diagnosis Group",
    y = "Proportion"
  )

ggsave("outputs/plots/Readmission_DiagnosisCategory.png")

# Co-morbidity Proxy - Risk Score Proxy
data$risk_score <- data$num_medications +
  data$num_lab_procedures +
  data$number_diagnoses

data$risk_level <- cut(
  data$risk_score,
  breaks = quantile(data$risk_score, probs = seq(0, 1, 0.33)),
  labels = c("Low", "Medium", "High"),
  include.lowest = TRUE
)

table(data$risk_level)

# Logistic Model Upgraded 
data$readmit_30 <- ifelse(data$readmitted == "<30", 1, 0)

model2 <- glm(
  readmit_30 ~ age + time_in_hospital + num_medications +
    diag_group + risk_level,
  data = data,
  family = binomial,
  na.action = na.omit
)

summary(model2)
exp(coef(model2))

# Confusion Matrix 
pred_probs <- predict(model2, type = "response")
pred_class <- ifelse(pred_probs > 0.5, 1, 0)
model_data <- model2$model
table(
  Predicted = pred_class,
  Actual = model_data$readmit_30
)

# Model Evaluation
install.packages("pROC")
library(pROC)


pred_probs <- predict(model2, type = "response")
roc_obj <- roc(model_data$readmit_30, pred_probs)
auc(roc_obj)

# ROC Curve
roc_obj <- roc(model_data$readmit_30, pred_probs)

plot(roc_obj, col = "blue", lwd = 3, main = "ROC Curve - Readmission Model")
abline(a = 0, b = 1, lty = 2, col = "gray")
dev.off()

ggsave("outputs/plots/roc_curve.png")

auc(roc_obj)


#Logistic Regression
exp(coef(model2))
sort(exp(coef(model2)), decreasing = TRUE)