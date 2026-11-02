(define (problem rover_problem)
(:domain rover_domain)
(:objects
SiteE SiteA SiteB SiteC SiteD SiteF - location
Rock1 Rock2 Rock3 Rock4 Rock5 - rock
bay1 bay2 - bay 
)
(:init
(rover-at base) (y-rock-at-x SiteA Rock1) (y-rock-at-x SiteB Rock2) (y-rock-at-x SiteC Rock3) (y-rock-at-x SiteD Rock4) (y-rock-at-x SiteF Rock5)
(drill-at SiteE) 
(soft Rock1) (soft Rock2) (hard Rock3) (soft Rock4) (hard Rock5)
(empty bay1) (empty bay2)
(connected base SiteA) (connected SiteA base)  (connected base SiteB) (connected SiteB base) (connected SiteA SiteC)  (connected SiteC SiteA) (connected SiteB SiteD) (connected SiteD SiteB) (connected SiteC SiteE) (connected SiteE SiteC) (connected SiteD SiteE) (connected SiteE SiteD) (connected SiteE SiteF) (connected SiteF SiteE) (connected SiteC SiteD)
)

(:goal
(and
(y-rock-at-x base Rock1) (y-rock-at-x base Rock2) (y-rock-at-x base Rock3) (y-rock-at-x base Rock4) (y-rock-at-x base Rock5)
(rover-at base)
(empty bay1) (empty bay2)
)
)
)