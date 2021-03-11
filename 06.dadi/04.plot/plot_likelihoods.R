install.packages('tidyverse')
library(tidyverse)


max_likes <- read_csv2('max_likes.csv', na = '.')
max_likes <- pivot_longer(max_likes, cols=c(2:3,5:6), names_to = "model", values_to = "likelihoods")
max_likes$model <- as_factor(max_likes$model)
max_likes$pair <- as_factor(max_likes$pair)
max_likes$colour <- c('#489CDA','#489CDA','#489CDA','#489CDA','#D10000','#D10000','#D10000','#D10000')
view(max_likes$pair)
ggplot(data = subset(max_likes, model %in% c('no_mig','sym_mig','asym_mig','sec_contact_sym_mig','sec_contact_asym_mig')),
    aes(x = model, y = likelihoods, group = pair, color = pair)) +  
    geom_line(cex = 0.7, color = max_likes$colour) +
    geom_point(cex = 2, color = max_likes$colour) +
    theme_classic()

ggsave('pair.png', width = 8, height = 5)

view(max_likes)




