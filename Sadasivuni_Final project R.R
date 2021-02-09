library(tidyverse)
library(lubridate)
library(maps)
library(ggplot2)
library(purrr)
library(mapproj)
library(dplyr)
suppressPackageStartupMessages(library(tidyverse))
library(stringr)
library(ggthemes)
suppressPackageStartupMessages(library(maps))
library(viridisLite)
library(viridis)
library(hrbrthemes)
library(corrplot)

# read in the data we'll need
listings <- read_csv("Inpatient_Prospective_Payment_System__IPPS__Provider_Summary_for_the_Top_100_Diagnosis-Related_Groups__DRG__-_FY2011.csv")
any(is.na(listings)) #checking for any NA values
listings$`Hospital Referral Region Description`=substring(listings$`Hospital Referral Region Description`, 5) #removing first 5 characters from the column "Hospital Referral Region Description" 

names(listings) <- c('drg_def', 'prov_id', 'prov_name', 'prov_address', 'prov_city', 'prov_state', 
                    'prov_zip', 'referral_reg', 'total_discharges', 'mean_covered_charges',
                    'mean_total_payments', 'mean_medicare_payments')
colnames(listings)

state.abb <- append(state.abb, c("DC"))
state.name <- append(state.name, c("District of Columbia"))
listings$region <- map_chr(listings$prov_state, function(x) { tolower(state.name[grep(x, state.abb)]) })
state_map <- map_data('state')

#displaying top most 10 common drg procedures
listings %>%
  group_by(drg_def) %>%
  summarize(n = n()) %>%
  arrange(-n) %>%
  head(10)

#SIMPLE PNEUMONIA & PLEURISY W CC as it is first 
plot_state <- function(data, proc, col) {
  measure <- enquo(col)
  data %>% 
    filter(drg_def == proc) %>%
    group_by(region) %>%
    summarize(m = mean(!!measure)) %>%
    right_join(state_map, by = 'region') %>%
    ggplot(aes(x = long, y = lat, group = group, fill = m)) + 
    geom_polygon() + 
    geom_path(color = 'white') + 
    scale_fill_continuous(low = "white", 
                          high = "gray0",
                          name = 'Mean covered charges($)') + 
    theme_map() + 
    coord_map('albers', lat0=30, lat1=40) + 
    ggtitle(paste("Mean Covered Charges for", gsub('[0-9]{3}.{3}', '', proc))) + 
    theme(plot.title = element_text(hjust = 0.5))
}
plot_state(listings, '194 - SIMPLE PNEUMONIA & PLEURISY W CC', mean_covered_charges)

#displaying the data on map for mean covered charges for all procedures
listings %>% 
  group_by(region) %>%
  summarize(m = mean(mean_covered_charges)) %>%
  right_join(state_map, by = 'region') %>%
  ggplot(aes(x = long, y = lat, group = group, fill = m)) + 
  geom_polygon() + 
  geom_path(color = 'white') + 
  scale_fill_continuous(low = "lightblue", 
                        high = "dodgerblue4",
                        name = 'Mean covered charges($)') + 
  theme_map() + 
  coord_map('albers', lat0=30, lat1=40) + 
  ggtitle("Mean Covered Charges for all Procedures") + 
  theme(plot.title = element_text(hjust = 0.5))

#Displaying the hospitals which have the highest ratio of medicare payments to total charges.
listings %>%
  mutate(payments_to_charges = mean_medicare_payments / mean_covered_charges) %>%
  group_by(prov_name) %>%
  summarize(m = mean(payments_to_charges)) %>%
  arrange(-m) %>%
  head(20) %>%
  ggplot(aes(x=reorder(prov_name, -m), y = m)) + 
  geom_bar(stat = 'identity', fill = 'dodgerblue4', color = 'white') + 
  labs(x = '', y = '%', title = 'Total Medicare payments - % of Covered Charges') + 
  scale_y_continuous(labels = scales::percent) + 
  theme(axis.text.x = element_text(angle = 75, hjust = 1) )

#Number of discharges in 2011 in each state
discharges= listings %>% 
group_by(region)%>% 
  summarise(total_discharges= n())
discharges=as.data.frame(discharges)
head(discharges,10)

ggplot(discharges, aes(x=discharges$region, y=discharges$total_discharges))   +
      geom_bar(stat="identity", fill=alpha("gray0", 0.6)) +
     theme_minimal()+
   theme(axis.text.x = element_text(angle = 75, hjust = 1) )+
labs(x="states",y="Number of discharges",title="Number of discharges in 2011 in each state")

#Statewise boxplot of mean medicare payments
listings %>%
  ggplot( aes(x=listings$prov_state, y=listings$mean_medicare_payments, fill=listings$prov_state)) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE, alpha=0.6, option="A") +
  theme_minimal()+
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("Statewise boxplot of mean medicare payments") +
  xlab("States")+
  ylab("Mean medicare payments ($)")

#Diagnostic plots
mod=lm(listings$total_discharges~listings$mean_covered_charges+listings$mean_total_payments+listings$mean_medicare_payments)
par(mfrow=c(2,2))
plot(mod)
summary(mod)

#Correlation Analysis and Plot
cordata=listings[,c(2,7,9:12)]
cor(cordata)
corrplot(cor(cordata), method = "circle", tl.col = "black", title = "Correlation Plot")

#Hypothesis test
mean(listings$total_discharges)
sd(listings$total_discharges)
t.test(listings$total_discharges,mu = 0.5)




