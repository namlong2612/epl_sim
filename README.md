About EPL What If
=================

Have you ever wondered who would win between The Invincibles Arsenal
side and the 100-point record-breaking Manchester City side? I have had
several arguments with my friends in this kind of hypothetical “Who
would Win?” debates and became quite tired of it. So with my Statistical
tools and Football curiosity, I decided to build a simple app simulating
a match between any Premier League sides (ever).

The idea of the app is for a user to choose a Home side and an Away side
at any given Season of the English Premier League and see how they
perform against each other. The user can also choose any 20 teams from
the history to simulate a “Fantasy League” to see which team come out on
top/bottom. The stats for any team are also provided in the third tab.

Methodology
-----------

The fundamental assumption I will be making is that the number of goals
scored by a team follows a [Poisson
distribution](https://en.wikipedia.org/wiki/Poisson_distribution) with
mean dependent on the teams’ attacking strength and the oppositions’
defensive strength. This is a reasonable assumption since the Poisson
distribution is typically skewed towards lower numbers when the mean is
small (and football is a low-scoring game). However it is not perfect
for several reasons – for example, given a Poisson distribution with
mean λ, then the number of events in half that time period follows a
Poisson distribution with mean λ/2. In football terms, according to our
Poisson model, there should be an equal number of goals in the first and
second halves. Unfortunately, that is not true in a football game. Since
this is just for fun I decided not to look too far for the perfect model
and stuck with what I had.

The [Home Field
Advantage](https://www.nytimes.com/2008/10/12/sports/soccer/12score.html#:~:text=The%20home%2Dfield%20advantage%20is,in%20perhaps%20any%20other%20sport.&text=With%203%20points%20for%20a,uniform%20across%20Europe's%20top%20leagues.)
is a well-established phenomenon in football and so for every teams, I
want to look at how they performed at home and away, treating each
separately. Therefore for each team I need to find out four things:
their home attack, home defence, away attack and away defence. With data
collected from [this site](http://www.football-data.co.uk/englandm.php),
I computed the mean of home goals (HG), home conceded (HC), away goals
(AG), and away conceded (AC) for every teams in the EPL from 1993 to
2020. For 2 selected teams, I generate goals for the home team by a
Poisson-distributed sample with a mean equal to 1/2(HG + AC), taking
into account both attacking strength of the home side and defensive
strength of visitor. Reversely, the visitor’s goals are sampled from a
Poisson distribution with mean equal to 1/2(HC + AG).

The most probable score and the probability for each outcome is
provided.

Data source
-----------

The [football-data.uk
website](http://www.football-data.co.uk/englandm.php) which has Excel
results files for every seasons.

#### Link to this app:

<https://longtr.shinyapps.io/supersim/>

#### Code for this app:

<https://github.com/namlong2612/epl_sim>

### By Long Tran
