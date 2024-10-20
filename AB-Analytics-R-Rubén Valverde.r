# CELL INDEX: 0
library(stringr)
library(ggplot2)
library(tidyr)
library(dplyr)
library(readr)

# CELL INDEX: 1
df <- read_csv("inflation_corruption_1995_2023_Ruben_Valverde.csv")

# CELL INDEX: 2
head(df)

# CELL INDEX: 3
str(df)

# CELL INDEX: 4
# Count "no data" values in each column
inflation <- df %>% select(starts_with("inflation"))
no_data_count <- colSums(inflation == "no data", na.rm = TRUE)
print("-------------------")
print(no_data_count)
print(paste("Total:", sum(no_data_count)))

# CELL INDEX: 5
# Replace "no data" values with NA in the entire DataFrame
df[df == "no data"] <- NA

# CELL INDEX: 6
# Convert inflation columns from 1995 to 2023 to numeric values
for (year in 1995:2023) {
    column <- paste("inflation", year, sep = "_")
    df[[column]] <- as.numeric(df[[column]])
}

# CELL INDEX: 7
# Count and display the number of null values per column
print(colSums(is.na(df)))
print("------------------------------")
print(paste("There are a total of", sum(is.na(df)), "null values"))

# CELL INDEX: 8
# Transform the DataFrame from wide format to long format for analyzing inflation, score, and rank data over time
df_melted <- df %>%
    pivot_longer(cols = starts_with("inflation_") | starts_with("score_") | starts_with("rank_"),
                 names_to = "variable", values_to = "value") %>%
    mutate(year = as.integer(str_extract(variable, "\\d{4}")),
           variable = str_replace(variable, "_\\d{4}", "")) %>%
    pivot_wider(names_from = variable, values_from = value) %>%
    arrange(country, iso, region, year)

# CELL INDEX: 9
# Convert the columns "inflation", "rank" and "score" to float in the DataFrame df_melted
df_melted <- df_melted %>%
    mutate(across(c(inflation, rank, score), as.numeric))

# CELL INDEX: 11
# Create a DataFrame with the average annual inflation by region
df_avg_inflation <- df_melted %>%
    group_by(region, year) %>%
    summarize(inflation = median(inflation, na.rm = TRUE))

# CELL INDEX: 12
# Set the style of the graphs
theme_set(theme_minimal())

# Create the line plot
ggplot(df_avg_inflation, aes(x = year, y = inflation, color = region)) +
    geom_line() +
    geom_point() +
    ylim(0, 25) +
    geom_text(data = df_avg_inflation %>% filter(inflation > 25),
              aes(label = round(inflation, 1)), vjust = -0.5, color = "green") +
    labs(title = "Evolución de la Inflación Promedio Anual por Región",
         x = "Año", y = "Inflación Promedio") +
    theme(legend.title = element_text(size = 10))


