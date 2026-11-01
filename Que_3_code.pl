% ROYAL ARCHIVE ACCESS VERIFICATION USING RESOLUTION REFUTATION
% AI Group Assignment 2 - Problem 3

:- dynamic res/4.      
:- dynamic sk_count/1.
sk_count(0).             
:- dynamic counter/1.   

% =====================================================================
% STEP 1: PREDICATE LOGIC REPRESENTATION
% ---------------------------------------------------------------------
% Constants  : mira, scroll_7, royal_archive
% Variables  : x (a person), r (a record)
% Predicates : archivist(x)        x is an archivist
% verifies(x,r)       x verifies record r
% trusted(x)          x is trusted
% access(x,r)         x has access to r
% sealed(r)           r is sealed
% permitted(x,r)      x is permitted to inspect r
% inspects(x,r)       x inspects r
% finds_mark(x,r)     x finds a hidden mark in r
% stored_in(r,a)      r is stored in archive a
% =====================================================================

% fol(Number, EnglishText, Formula)
fol(1, 'Every archivist who verifies a record is trusted',
    forall(v(x), forall(v(r),
        imp(and(archivist(v(x)), verifies(v(x),v(r))), trusted(v(x)))))).

fol(2, 'Every trusted person with access to a sealed record is permitted to inspect it',
    forall(v(x), forall(v(r),
        imp(and(and(trusted(v(x)), access(v(x),v(r))), sealed(v(r))),
            permitted(v(x),v(r)))))).

fol(3, 'Anyone who inspects a record and finds a hidden mark in it verifies that record',
    forall(v(x), forall(v(r),
        imp(and(inspects(v(x),v(r)), finds_mark(v(x),v(r))), verifies(v(x),v(r)))))).

fol(4, 'Every record stored in the royal archive is sealed',
    forall(v(r),
        imp(stored_in(v(r),royal_archive), sealed(v(r))))).

fol(5, 'scroll_7 is stored in the royal archive',
    stored_in(scroll_7, royal_archive)).

fol(6, 'Mira has access to scroll_7',
    access(mira, scroll_7)).

fol(7, 'Mira inspects scroll_7 and finds a hidden mark in it',
    and(inspects(mira, scroll_7), finds_mark(mira, scroll_7))).

fol(8, 'Mira is an archivist',
    archivist(mira)).

% Goal to be proved
goal(trusted(mira)).

% =====================================================================
% STEP 2: NEGATION OF THE GOAL
% Resolution refutation: add  ~Goal  to the KB; if the KB becomes
% contradictory (empty clause derivable), the Goal follows.
% It is numbered 9 so that it travels through steps 3-7 with the KB.
% =====================================================================
negated_goal(not(G)) :- goal(G).

all_formulas(L) :-
    findall(N-F, fol(N,_,F), L0),
    negated_goal(NG),
    append(L0, [9-NG], L).

% =====================================================================
% STEP 3: IMPLICATION REMOVAL        (A => B)  becomes  (~A | B)
% =====================================================================
rm_imp(imp(A,B), or(not(A1),B1)) :- !, rm_imp(A,A1), rm_imp(B,B1).
rm_imp(forall(V,B), forall(V,B1)) :- !, rm_imp(B,B1).
rm_imp(exists(V,B), exists(V,B1)) :- !, rm_imp(B,B1).
rm_imp(and(A,B), and(A1,B1))     :- !, rm_imp(A,A1), rm_imp(B,B1).
rm_imp(or(A,B),  or(A1,B1))      :- !, rm_imp(A,A1), rm_imp(B,B1).
rm_imp(not(A),   not(A1))        :- !, rm_imp(A,A1).
rm_imp(A, A).

stage3(L3) :- all_formulas(L), maplist(map_pair(rm_imp), L, L3).

% =====================================================================
% STEP 4: MOVE NEGATIONS INWARD (De Morgan, double negation,
% ~forall = exists~, ~exists = forall~)
% =====================================================================
nnf(not(not(A)), R)            :- !, nnf(A,R).
nnf(not(and(A,B)), or(A1,B1))  :- !, nnf(not(A),A1), nnf(not(B),B1).
nnf(not(or(A,B)), and(A1,B1))  :- !, nnf(not(A),A1), nnf(not(B),B1).
nnf(not(forall(V,B)), exists(V,B1)) :- !, nnf(not(B),B1).
nnf(not(exists(V,B)), forall(V,B1)) :- !, nnf(not(B),B1).
nnf(forall(V,B), forall(V,B1)) :- !, nnf(B,B1).
nnf(exists(V,B), exists(V,B1)) :- !, nnf(B,B1).
nnf(and(A,B), and(A1,B1))      :- !, nnf(A,A1), nnf(B,B1).
nnf(or(A,B),  or(A1,B1))       :- !, nnf(A,A1), nnf(B,B1).
nnf(L, L).                                  % literal (atom or ~atom)

stage4(L4) :- stage3(L3), maplist(map_pair(nnf), L3, L4).

% =====================================================================
% STEP 5: STANDARDIZE VARIABLES APART
% Every quantified variable of formula N gets the suffix N
% (x -> x1, r -> r1, ...), so no two formulas share a variable name.
% =====================================================================
standardize(forall(v(X),B), N, forall(v(X1),B2)) :- !,
    atom_concat(X, N, X1),
    subst_var(v(X), v(X1), B, B1),
    standardize(B1, N, B2).
standardize(exists(v(X),B), N, exists(v(X1),B2)) :- !,
    atom_concat(X, N, X1),
    subst_var(v(X), v(X1), B, B1),
    standardize(B1, N, B2).
standardize(and(A,B), N, and(A1,B1)) :- !, standardize(A,N,A1), standardize(B,N,B1).
standardize(or(A,B),  N, or(A1,B1))  :- !, standardize(A,N,A1), standardize(B,N,B1).
standardize(F, _, F).

std_pair(N-F, N-F1) :- standardize(F, N, F1).

stage5(L5) :- stage4(L4), maplist(std_pair, L4, L5).

% =====================================================================
% STEP 6: SKOLEMIZATION
% Each existential variable is replaced by a Skolem constant/function of
% the universal variables in whose scope it lies.
% This knowledge base contains NO existential quantifier, so nothing
% needs to be replaced and every formula passes through unchanged.
% (The general procedure is implemented anyway.)
% =====================================================================
skolemize(forall(V,B), U, forall(V,B1)) :- !, skolemize(B, [V|U], B1).
skolemize(exists(V,B), U, B2) :- !,
    retract(sk_count(K)), K1 is K+1, assertz(sk_count(K1)),
    format(atom(Sk), 'sk~w', [K1]),
    (   U == [] -> T = Sk ; reverse(U, Ur), T =.. [Sk|Ur] ),
    subst_var(V, T, B, B1),
    skolemize(B1, U, B2).
skolemize(and(A,B), U, and(A1,B1)) :- !, skolemize(A,U,A1), skolemize(B,U,B1).
skolemize(or(A,B),  U, or(A1,B1))  :- !, skolemize(A,U,A1), skolemize(B,U,B1).
skolemize(F, _, F).

sk_pair(N-F, N-F1) :- skolemize(F, [], F1).

stage6(L6) :- stage5(L5), maplist(sk_pair, L5, L6).

% =====================================================================
% STEP 7: CONJUNCTIVE NORMAL FORM (clauses)
% Drop the universal quantifiers (all remaining variables are universal),
% distribute | over &, and split the conjunction into separate clauses.
% =====================================================================
strip_univ(forall(_,B), M) :- !, strip_univ(B, M).
strip_univ(F, F).

clauses(and(A,B), Cs) :- !,
    clauses(A, CA), clauses(B, CB), append(CA, CB, Cs).
clauses(or(A,B), Cs) :- !,
    clauses(A, CA), clauses(B, CB),
    findall(C, (member(X,CA), member(Y,CB), append(X,Y,C)), Cs).
clauses(L, [[L]]).

% cnf_clauses(-List) : list of Id-origin(N)-Literals  (variables still v(Name))
cnf_clauses(Cl) :-
    stage6(L6),
    findall(N-C, ( member(N-F, L6), strip_univ(F, M), clauses(M, Cs), member(C, Cs) ), NC),
    number_clauses(NC, 1, Cl).

number_clauses([], _, []).
number_clauses([N-C|T], I, [cl(I,N,C)|T1]) :- I1 is I+1, number_clauses(T, I1, T1).

% =====================================================================
% STEP 8: RESOLUTION REFUTATION
% - Clauses are lists of literals; a negative literal is not(P).
% - Two clauses resolve on a pair of complementary literals that unify;
% the resolvent is the union of the remaining literals under the
% most general unifier (duplicates removed).
% - Strategy: breadth-first, SET OF SUPPORT. Only clauses descended from
% the negated goal are expanded; each is resolved against the whole
% knowledge base and against earlier support clauses. This is complete
% and keeps the search directed at the goal.
% - Search stops as soon as the empty clause [] appears; the proof is
% then reconstructed from the parent links and printed in order.
% =====================================================================

lift_clause(C, C2) :- lift_list(C, [], _, C2).
lift_list([], M, M, []).
lift_list([T|Ts], M0, M, [T2|Ts2]) :- lift(T, M0, M1, T2), lift_list(Ts, M1, M, Ts2).
lift(v(X), M0, M, V) :- !,
    (   memberchk(X-V0, M0) -> V = V0, M = M0 ; M = [X-V|M0] ).
lift(T, M, M, T) :- atomic(T), !.
lift(T, M0, M, T2) :-
    T =.. [F|Args], lift_list(Args, M0, M, Args2), T2 =.. [F|Args2].

next_id(Id) :- retract(counter(N)), Id is N+1, assertz(counter(Id)).

key(Lits, K) :- copy_term(Lits, C), numbervars(C, 0, _), sort(C, K).

complementary(not(P), LB, P) :- LB \= not(_), LB = P.
complementary(LA, not(P), P) :- LA \= not(_), LA = P.

resolvent(Id1, Id2, P, R) :-
    res(Id1, C1, _, _), res(Id2, C2, _, _),
    copy_term(C1, A), copy_term(C2, B),            % rename apart
    select(LA, A, RA), select(LB, B, RB),
    complementary(LA, LB, P),                      % unifies the two literals
    append(RA, RB, All), list_to_set(All, R).

refute([Id|Rest], Done, KBIds, Found) :-
    append(KBIds, [Id|Done], Pool0), list_to_set(Pool0, Pool),
    expand(Pool, Id, [], NewIds, Empty),
    (   nonvar(Empty) -> Found = Empty
    ;   append(Rest, NewIds, Rest1),
        refute(Rest1, [Id|Done], KBIds, Found) ).

expand([], _, Acc, NewIds, _) :- reverse(Acc, NewIds).
expand([Id2|Ps], Id, Acc, NewIds, Empty) :-
    findall(P-R, resolvent(Id, Id2, P, R), Rs),
    add_new(Rs, Id, Id2, Acc, Acc1, Empty),
    (   nonvar(Empty) -> reverse(Acc1, NewIds)
    ;   expand(Ps, Id, Acc1, NewIds, Empty) ).

add_new([], _, _, A, A, _).
add_new([P-R|Rs], I1, I2, A0, A, Empty) :-
    key(R, K),
    (   res(_, _, _, K)                            % variant already known
    ->  add_new(Rs, I1, I2, A0, A, Empty)
    ;   next_id(New),
        assertz(res(New, R, from(I1,I2,P), K)),
        (   R == []
        ->  Empty = New, A = [New|A0]
        ;   add_new(Rs, I1, I2, [New|A0], A, Empty) ) ).

% ---- proof reconstruction -------------------------------------------
ancestors(Id, Acc, Acc) :- memberchk(Id, Acc), !.
ancestors(Id, Acc0, Acc) :-
    res(Id, _, Info, _),
    (   Info = from(A,B,_)
    ->  ancestors(A, [Id|Acc0], Acc1), ancestors(B, Acc1, Acc)
    ;   Acc = [Id|Acc0] ).

% ---------------------------------------------------------------------
% Pretty printing
% ---------------------------------------------------------------------
pp(v(X), X) :- !.
pp(forall(V,B), S) :- !, pp(V,SV), pp(B,SB), format(atom(S), 'forall ~w. ~w', [SV,SB]).
pp(exists(V,B), S) :- !, pp(V,SV), pp(B,SB), format(atom(S), 'exists ~w. ~w', [SV,SB]).
pp(imp(A,B), S) :- !, pp(A,SA), pp(B,SB), format(atom(S), '(~w => ~w)', [SA,SB]).
pp(and(A,B), S) :- !, pp(A,SA), pp(B,SB), format(atom(S), '(~w & ~w)',  [SA,SB]).
pp(or(A,B),  S) :- !, pp(A,SA), pp(B,SB), format(atom(S), '(~w | ~w)',  [SA,SB]).
pp(not(A),   S) :- !, pp(A,SA), atom_concat('~', SA, S).
pp(T, T) :- atomic(T), !.
pp(T, S) :- T =.. [F|Args], maplist(pp, Args, As),
            atomic_list_concat(As, ',', AS), format(atom(S), '~w(~w)', [F,AS]).

pp_clause_named([], '[]  (empty clause)') :- !.
pp_clause_named(Lits, S) :- maplist(pp, Lits, Ss), atomic_list_concat(Ss, ' | ', S).

% clause with real Prolog variables -> readable text (variables X, Y, Z, ...)
pp_clause([], '[]  (empty clause)') :- !.
pp_clause(Lits, S) :-
    copy_term(Lits, C), term_variables(C, Vs), name_vars(Vs, 0),
    maplist(pl, C, Ss), atomic_list_concat(Ss, ' | ', S).
name_vars([], _).
name_vars(['$VAR'(Nm)|T], I) :-
    Letters = ['X','Y','Z','U','V','W'],
    (   nth0(I, Letters, Nm) -> true ; format(atom(Nm), 'V~w', [I]) ),
    I1 is I+1, name_vars(T, I1).
pl(not(P), S) :- !, pl(P, S0), atom_concat('~', S0, S).
pl(P, S) :- format(atom(S), '~W', [P, [numbervars(true), quoted(false)]]).

map_pair(P, N-F, N-F2) :- call(P, F, F2).

subst_var(Old, New, T, New) :- T == Old, !.
subst_var(_, _, T, T) :- atomic(T), !.
subst_var(O, N, T, T2) :- T =.. [F|Args], maplist(subst_var(O,N), Args, Args2), T2 =.. [F|Args2].

banner(Title) :-
    format('~n~`=t~72|~n~w~n~`=t~72|~n', [Title]).

print_stage(L) :-
    forall(member(N-F, L), ( pp(F,S), format('  [~w]  ~w~n', [N,S]) )).

% =====================================================================
% MAIN
% =====================================================================
main :-
    banner('STEP 1: PREDICATE LOGIC REPRESENTATION'),
    format('Constants : mira, scroll_7, royal_archive~n'),
    format('Variables : x (person), r (record)~n'),
    format('Predicates: archivist/1, verifies/2, trusted/1, access/2, sealed/1,~n'),
    format('            permitted/2, inspects/2, finds_mark/2, stored_in/2~n~n'),
    forall(fol(N,Txt,F),
           ( pp(F,S), format('  [~w]  ~w~n        ~w~n', [N,Txt,S]) )),
    goal(G), pp(G,GS), format('~n  GOAL: ~w   ("Mira is trusted")~n', [GS]),

    banner('STEP 2: NEGATION OF THE GOAL (added to the knowledge base)'),
    negated_goal(NG), pp(NG,NGS), format('  [9]  ~w~n', [NGS]),

    banner('STEP 3: IMPLICATION REMOVAL   (A => B  ==>  ~A | B)'),
    stage3(L3), print_stage(L3),

    banner('STEP 4: NEGATION MOVED INWARD'),
    stage4(L4), print_stage(L4),
    format('  (only negated atoms remain; nothing further to push in)~n'),

    banner('STEP 5: STANDARDIZE VARIABLES APART  (suffix = formula number)'),
    stage5(L5), print_stage(L5),

    banner('STEP 6: SKOLEMIZATION'),
    stage6(L6), print_stage(L6),
    format('  (no existential quantifiers exist, so no Skolem terms are needed)~n'),

    banner('STEP 7: CNF CLAUSES  (universal quantifiers dropped, split on &)'),
    cnf_clauses(Cl),
    forall(member(cl(I,N,C), Cl),
           ( pp_clause_named(C,S), format('  C~w  (from formula ~w):  ~w~n', [I,N,S]) )),

    banner('STEP 8: RESOLUTION REFUTATION'),
    resolution_run(Cl),

    banner('CROSS-CHECK WITH ORDINARY PROLOG (SLD resolution)'),
    (   chk_trusted(mira)
    ->  format('  ?- chk_trusted(mira).   true.~n')
    ;   format('  ?- chk_trusted(mira).   false.~n') ).

resolution_run(Cl) :-
    retractall(res(_,_,_,_)), retractall(counter(_)),
    length(Cl, Total), assertz(counter(Total)),
    forall(member(cl(I,N,C), Cl),
           ( lift_clause(C, LC), key(LC, K),
             assertz(res(I, LC, given(N), K)) )),
    last(Cl, cl(GoalId, _, _)),
    findall(I, ( member(cl(I,_,_), Cl), I \== GoalId ), KBIds),
    format('Strategy: set of support, breadth first. Support clause = C~w (negated goal).~n', [GoalId]),
    (   refute([GoalId], [], KBIds, Empty)
    ->  ancestors(Empty, [], Anc0), msort(Anc0, Anc),
        include(is_resolvent, Anc, Steps),
        include(is_given, Anc, Used),
        format('~nDerivation (each line resolves two clauses on a complementary pair):~n~n'),
        print_steps(Steps, Steps),
        format('~n  Clauses used in the proof : ~w~n', [Used]),
        findall(I, ( member(cl(I,_,_), Cl), \+ memberchk(I, Used) ), Unused),
        format('  Clauses NOT needed          : ~w  (rules 2, 4 and the facts feeding only them)~n', [Unused]),
        banner('RESULT'),
        label(Empty, Steps, ELabel),
        format('  The empty clause [] was derived (step ~w).~n', [ELabel]),
        format('  KB + ~~trusted(mira) is contradictory, so  trusted(mira)  is PROVED.~n')
    ;   format('No refutation found - goal does not follow.~n') ).

is_resolvent(Id) :- res(Id, _, from(_,_,_), _).
is_given(Id)     :- res(Id, _, given(_), _).

label(Id, Steps, L) :-
    (   nth1(K, Steps, Id) -> format(atom(L), 'R~w', [K]) ; format(atom(L), 'C~w', [Id]) ).

print_steps([], _).
print_steps([Id|T], Steps) :-
    res(Id, R, from(A,B,P), _),
    res(A, CA, _, _), res(B, CB, _, _),
    label(Id, Steps, LR), label(A, Steps, LA), label(B, Steps, LB),
    pp_clause(CA, SA), pp_clause(CB, SB), pp_clause(R, SR),
    pp_pred(P, SP),
    format('  ~w:  resolve ~w  with  ~w   on  ~w~n', [LR,LA,LB,SP]),
    format('        ~w : ~w~n', [LA,SA]),
    format('        ~w : ~w~n', [LB,SB]),
    format('        ==> ~w : ~w~n~n', [LR,SR]),
    print_steps(T, Steps).

pp_pred(P, S) :- copy_term(P, C), term_variables(C, Vs), name_vars(Vs, 0), pl(C, S).

% ---------------------------------------------------------------------
% Independent sanity check: the same knowledge as a Prolog program
% (predicates prefixed chk_ to keep them apart from the logic above).
% ---------------------------------------------------------------------
chk_archivist(mira).
chk_inspects(mira, scroll_7).
chk_finds_mark(mira, scroll_7).
chk_verifies(X, R) :- chk_inspects(X, R), chk_finds_mark(X, R).
chk_trusted(X)     :- chk_archivist(X), chk_verifies(X, _).