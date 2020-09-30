library(tidyverse)
epl_set <- read.csv("EPL_Set.csv", stringsAsFactors = FALSE)



# average goals scored and conceded by teams over seasons
ave_home <- epl_set %>% group_by(Season, HomeTeam) %>% 
  summarize(avg_scored_h = mean(FTHG), avg_conceded_h = mean(FTAG)) %>%
  rename(Team = HomeTeam)

ave_away <- epl_set %>% group_by(Season, AwayTeam) %>% 
  summarize(avg_scored_a = mean(FTAG), avg_conceded_a = mean(FTHG)) %>%
  rename(Team = AwayTeam)

epl_avg <- merge(ave_home, ave_away, by=c("Season", "Team"))
rm(ave_home, ave_away)

# total goals scored and conceded by teams over seasons
g_home <- epl_set %>% group_by(Season, HomeTeam) %>% 
  summarize(total_scored_h = sum(FTHG), total_conceded_h = sum(FTAG)) %>%
  rename(Team = HomeTeam)

g_away <- epl_set %>% group_by(Season, AwayTeam) %>% 
  summarize(total_scored_a = sum(FTAG), total_conceded_a = sum(FTHG)) %>%
  rename(Team = AwayTeam)

epl_goal <- merge(g_home, g_away, by=c("Season", "Team"))
rm(g_home, g_away)


# dataframe with teams' total, average goals scored and conceded over seasons
epl_stat <- merge(epl_goal, epl_avg, by=c("Season", "Team"))
epl_stat <- epl_stat %>% mutate(total_scored = total_scored_h + total_scored_a) %>%
  mutate(total_conceded = total_conceded_h + total_conceded_a)
colnames(epl_stat)[3:12] <- c("Home Goals", "Home Conceded", "Away Goals", "Away Conceded", 
                              "Average Home Goals", "Average Home Conceded", "Average Away Goals",  "Average Away Conceded", 
                              "Total Goals", "Total Conceded")
epl_stat[7:10] <- round(epl_stat[7:10], 3)




# Function to simulate a match between 2 teams
match_sim <- function(home, h_season, away, a_season, max_goals=9, nsim=1000)
{
  # Extract Attack and Defense stats for Home and Away teams
  t_avg_h_s = epl_avg[epl_avg$Team == home & epl_avg$Season == h_season,]$avg_scored_h
  t_avg_h_c = epl_avg[epl_avg$Team == home & epl_avg$Season == h_season,]$avg_conceded_h
  t_avg_a_s = epl_avg[epl_avg$Team == away & epl_avg$Season == a_season,]$avg_scored_a
  t_avg_a_c = epl_avg[epl_avg$Team == away & epl_avg$Season == a_season,]$avg_conceded_a
  match_score = character(length(nsim))
  
  # Use Poisson Dist. to simulate a result for the match
  for (i in 1:nsim)
  {
    h_scored = rpois(1, 1/2 * (t_avg_h_s + t_avg_a_c))
    a_scored = rpois(1, 1/2 * (t_avg_a_s + t_avg_h_c))
    
    match_score[i] = paste0(h_scored, "-", a_scored)
  }
  
  # Results Matrix
  matrix <- dpois(0:max_goals, 1/2 * (t_avg_h_s + t_avg_a_c)) %o% dpois(0:max_goals, 1/2 * (t_avg_a_s + t_avg_h_c))
  
  h_w <- sum(matrix[lower.tri(matrix)]) # home team win probability
  a_w <- sum(matrix[upper.tri(matrix)]) # away team win probability
  draw <- sum(diag(matrix))             # draw probability
  sl <- names(which.max(table(match_score))) # scoreline that repeated the most
  times <- max(table(match_score))        # times the scoreline repeat
  
  
  # Return results
  # home, h_season, "vs", away, a_season, "\n",
  cat(
    "RESULTS:", "\n",
    "The most probable score is:", sl, ", which occurs", times, "time(s) after", nsim, "simulations", "\n",
    "Home win probability: ", round(h_w, digits=2),"\n",
    "Away team win probability: ", round(a_w, digits=2), "\n",
    "Draw probability: ", round(draw, digits=2), "\n"
    
  )
  
}
