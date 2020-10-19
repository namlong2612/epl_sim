library(tidyverse)
library(ggthemes)
epl_set <- read.csv("EPL_Set.csv", stringsAsFactors = FALSE)



# average goals scored and conceded by teams over seasons
ave_home <- epl_set %>% group_by(Season, HomeTeam) %>%
  summarize(avg_scored_h = mean(FTHG),
            avg_conceded_h = mean(FTAG)) %>%
  rename(Team = HomeTeam)

ave_away <- epl_set %>% group_by(Season, AwayTeam) %>%
  summarize(avg_scored_a = mean(FTAG),
            avg_conceded_a = mean(FTHG)) %>%
  rename(Team = AwayTeam)

epl_avg <- merge(ave_home, ave_away, by = c("Season", "Team"))
rm(ave_home, ave_away)

# total goals scored and conceded by teams over seasons
g_home <- epl_set %>% group_by(Season, HomeTeam) %>%
  summarize(total_scored_h = sum(FTHG),
            total_conceded_h = sum(FTAG)) %>%
  rename(Team = HomeTeam)

g_away <- epl_set %>% group_by(Season, AwayTeam) %>%
  summarize(total_scored_a = sum(FTAG),
            total_conceded_a = sum(FTHG)) %>%
  rename(Team = AwayTeam)

epl_goal <- merge(g_home, g_away, by = c("Season", "Team"))
rm(g_home, g_away)


# dataframe with teams' total, average goals scored and conceded over seasons
epl_stat <- merge(epl_goal, epl_avg, by = c("Season", "Team"))
epl_stat <-
  epl_stat %>% mutate(total_scored = total_scored_h + total_scored_a) %>%
  mutate(total_conceded = total_conceded_h + total_conceded_a)
colnames(epl_stat)[3:12] <-
  c(
    "Home Goals",
    "Home Conceded",
    "Away Goals",
    "Away Conceded",
    "Average Home Goals",
    "Average Home Conceded",
    "Average Away Goals",
    "Average Away Conceded",
    "Total Goals",
    "Total Conceded"
  )
epl_stat[7:10] <- round(epl_stat[7:10], 3)


# epl dataframe for League sim
epl_perf <- epl_avg %>% mutate(Team = paste(Team, Season))




# Function to simulate a match between 2 teams
match_sim <-
  function(home,
           h_season,
           away,
           a_season,
           max_goals = 9,
           nsim = 1000)
  {
    # Extract Attack and Defense stats for Home and Away teams
    t_avg_h_s = epl_avg[epl_avg$Team == home &
                          epl_avg$Season == h_season,]$avg_scored_h
    t_avg_h_c = epl_avg[epl_avg$Team == home &
                          epl_avg$Season == h_season,]$avg_conceded_h
    t_avg_a_s = epl_avg[epl_avg$Team == away &
                          epl_avg$Season == a_season,]$avg_scored_a
    t_avg_a_c = epl_avg[epl_avg$Team == away &
                          epl_avg$Season == a_season,]$avg_conceded_a
    match_score = character(length(nsim))
    
    # Use Poisson Dist. to simulate a result for the match
    for (i in 1:nsim)
    {
      h_scored = rpois(1, 1 / 2 * (t_avg_h_s + t_avg_a_c))
      a_scored = rpois(1, 1 / 2 * (t_avg_a_s + t_avg_h_c))
      
      match_score[i] = paste0(h_scored, "-", a_scored)
    }
    
    # Results Matrix
    matrix <-
      dpois(0:max_goals, 1 / 2 * (t_avg_h_s + t_avg_a_c)) %o% dpois(0:max_goals, 1 /
                                                                      2 * (t_avg_a_s + t_avg_h_c))
    
    h_w <-
      sum(matrix[lower.tri(matrix)]) # home team win probability
    a_w <-
      sum(matrix[upper.tri(matrix)]) # away team win probability
    draw <- sum(diag(matrix))             # draw probability
    sl <-
      names(which.max(table(match_score))) # scoreline that repeated the most
    times <-
      max(table(match_score))        # times the scoreline repeat
    
    
    # Return results
    # home, h_season, "vs", away, a_season, "\n",
    cat(
      "RESULTS:",
      "\n",
      "The most probable score is:",
      sl,
      ", which occurs",
      times,
      "time(s) after",
      nsim,
      "simulations",
      "\n",
      "Home win probability: ",
      round(h_w, digits = 2),
      "\n",
      "Away team win probability: ",
      round(a_w, digits = 2),
      "\n",
      "Draw probability: ",
      round(draw, digits = 2),
      "\n"
      
    )
    
  }


# get match score for a random sim
get_score <- function(home, away) {
  t_avg_h_s = epl_perf[epl_perf$Team == home, ]$avg_scored_h
  t_avg_h_c = epl_perf[epl_perf$Team == home, ]$avg_conceded_h
  t_avg_a_s = epl_perf[epl_perf$Team == away, ]$avg_scored_a
  t_avg_a_c = epl_perf[epl_perf$Team == away, ]$avg_conceded_a
  
  # Use Poisson Dist. to simulate a result for the match
  h_scored = rpois(1, 1 / 2 * (t_avg_h_s + t_avg_a_c))
  a_scored = rpois(1, 1 / 2 * (t_avg_a_s + t_avg_h_c))
  
  return (list(h_scored, a_scored))
}




# League Sim
fixtures <-
  read.csv("fixtures.csv", stringsAsFactors = FALSE)
fixtures$Week <- rep(1:38, each = 10)

#choose 20 random teams
#chosen.team <- sample_n(epl_perf, size = 20)$Team






# Create fixture function
create_fixture <- function(teams) {
  #teams <- chosen.team
  match.team <- data.frame(unique(fixtures$HomeTeam), teams)
  colnames(match.team) <- c("Team", "ChosenTeam")
  
  # Match the teams to make fixtures
  c.fix <- fixtures
  c.fix$Chosen.HTeam <-
    match.team$ChosenTeam[match(unlist(fixtures$HomeTeam), match.team$Team)]
  c.fix$Chosen.ATeam <-
    match.team$ChosenTeam[match(unlist(fixtures$AwayTeam), match.team$Team)]
  
  #Remove original fixtures and return new fixtures
  c.fix <- c.fix %>% select(-HomeTeam,-AwayTeam)
  
  return(c.fix)
}




# Create league table
rank <- function (m_result) {
  table <-
    data.frame(
      name = unique(m_result$Chosen.HTeam),
      point = rep(as.integer(0), 20),
      win = rep(as.integer(0), 20),
      draw = rep(as.integer(0), 20),
      lose = rep(as.integer(0), 20),
      goal_score = rep(as.integer(0), 20),
      goal_conceded = rep(as.integer(0), 20)
    )
  
  # loop through all the results and then update
  for (i in 1:nrow(m_result)) {
    home = m_result$Chosen.HTeam[i]
    away = m_result$Chosen.ATeam[i]
    h_goal = m_result$h_scored[i]
    a_goal = m_result$a_scored[i]
    
    # add goal
    table[table$name == home, ]$goal_score = table[table$name == home, ]$goal_score + h_goal
    table[table$name == home, ]$goal_conceded = table[table$name == home, ]$goal_conceded + a_goal
    table[table$name == away, ]$goal_score = table[table$name == away, ]$goal_score + a_goal
    table[table$name == away, ]$goal_conceded = table[table$name == away, ]$goal_conceded + h_goal
    
    
    # calculate point
    if (h_goal > a_goal) {
      table[table$name == home, ]$point = table[table$name == home, ]$point + as.integer(3)
      table[table$name == home, ]$win = table[table$name == home, ]$win + as.integer(1)
      table[table$name == away, ]$lose = table[table$name == away, ]$lose + as.integer(1)
    }
    else if (h_goal < a_goal) {
      table[table$name == away, ]$point = table[table$name == away, ]$point + as.integer(3)
      table[table$name == away, ]$win = table[table$name == away, ]$win + as.integer(1)
      table[table$name == home, ]$lose = table[table$name == home, ]$lose + as.integer(1)
    }
    else{
      table[table$name == home, ]$point = table[table$name == home, ]$point + as.integer(1)
      table[table$name == away, ]$point = table[table$name == away, ]$point + as.integer(1)
      table[table$name == home, ]$draw = table[table$name == home, ]$draw + as.integer(1)
      table[table$name == away, ]$draw = table[table$name == away, ]$draw + as.integer(1)
    }
  }
  
  table$goal_dif <- table$goal_score - table$goal_conceded
  table <-
    table[order(-table$point,-table$goal_dif,-table$goal_score),]
  table$pos <- seq(1, 20) # add final standings
  
  colnames(table) <-
    c("Club", "Pts", "W", "D", "L", "GF", "GA", "GD", "Pos")
  table <-
    table[, c("Pos", "Club", "Pts", "W", "D", "L", "GF", "GA", "GD")]
  
  return (table)
}


# simulate a league
simulate <- function(teams) {
  fixtures <- create_fixture(teams)
  matches <-
    mapply(get_score,
           fixtures$Chosen.HTeam,
           fixtures$Chosen.ATeam,
           SIMPLIFY = FALSE)
  fixtures$h_scored <- unlist(sapply(matches, function(x)
    x[1]))
  fixtures$a_scored <- unlist(sapply(matches, function(x)
    x[2]))
  fixtures$score <-
    paste0(fixtures$h_scored, "-", fixtures$a_scored)
  fixtures$result <-
    factor(ifelse(
      fixtures$h_scored > fixtures$a_scored,
      "H",
      ifelse(fixtures$h_scored < fixtures$a_scored, "A", "D")
    ))
  
  return (fixtures)
}
