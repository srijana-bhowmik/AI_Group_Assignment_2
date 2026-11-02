(define (domain rover_domain)

    (:requirements
        :strips :typing
    )

    (:types
    location rock bay
    )

    (:constants
    base - location
    )

    (:predicates
     (rover-at ?x - location) (connected ?x ?k - location) (have-drill) (y-rock-at-x ?x - location ?y - rock) (soft ?y - rock) (hard ?y - rock) (drill-at ?x - location) (empty ?z - bay) (y-rock-in-z-bay ?y - rock ?z - bay) 
    )

    (:action Move
        :parameters (?x ?k - location)
        :precondition (and (rover-at ?x) (connected ?x ?k))
        :effect (and (rover-at ?k) (not(rover-at ?x)))
    )
    
    (:action Pick-Drill
        :parameters (?x - location)
        :precondition (and (rover-at ?x) (drill-at ?x))
        :effect (and (not(drill-at ?x)) (have-drill))
    )
    
    (:action Collect-hard
        :parameters (?x - location ?y - rock ?z - bay)
        :precondition (and (rover-at ?x) (y-rock-at-x ?x ?y) (hard ?y) (have-drill) (empty ?z))
        :effect (and (not(empty ?z)) (not(y-rock-at-x ?x ?y)) (y-rock-in-z-bay ?y ?z))
    )

    (:action Collect-soft
        :parameters (?x - location ?y - rock ?z - bay)
        :precondition (and (rover-at ?x) (y-rock-at-x ?x ?y) (soft ?y) (empty ?z))
        :effect (and (not(empty ?z)) (not(y-rock-at-x ?x ?y))(y-rock-in-z-bay ?y ?z))
    )
    
    (:action deposit
        :parameters (?y - rock ?z - bay)
        :precondition (and (rover-at base) (y-rock-in-z-bay ?y ?z))
        :effect (and (not(y-rock-in-z-bay ?y ?z)) (empty ?z) (y-rock-at-x base ?y))
    )
)