(** * Contractibility *)

Require Import Overture PathGroupoids.
Local Open Scope path_scope.

(** Naming convention: we consistently abbreviate "contractible" as "contr".  A theorem about a space [X] being contractible (which will usually be an instance of the typeclass [Contr]) is called [contr_X]. *)

(** Allow ourselves to implicitly generalize over types [A] and [B], and a function [f]. *)
Generalizable Variables A B f.

(** If a space is contractible, then any two points in it are connected by a path in a canonical way. *)
Definition path_contr `{Contr A} (x y : A) : x = y
  := (contr x)^ @ (contr y).

(** Any space of paths in a contractible space is contractible. *)
Instance contr_paths_contr `{Contr A} (x y : A) : Contr (x = y) | 10000.
Proof.
  apply (Build_Contr _ (path_contr x y)).
  intro r; destruct r; apply concat_Vp.
Defined.

(** It follows that  any two parallel paths in a contractible space are homotopic, which is just the principle UIP. *)
Definition path2_contr `{Contr A} {x y : A} (p q : x = y) : p = q
  := path_contr p q.

(** Also, the total space of any based path space is contractible.  We define the [contr] fields as separate definitions, so that we can give them [simpl nomatch] annotations. *)

Definition path_basedpaths {X : Type} {x y : X} (p : x = y)
  : (x;1) = (y;p) :> {z:X & x=z}.
Proof.
  destruct p; reflexivity.
Defined.

Arguments path_basedpaths {X x y} p : simpl nomatch.

Instance contr_basedpaths {X : Type} (x : X) : Contr {y : X & x = y} | 100.
Proof.
  apply (Build_Contr _ (x;1)).
  intros [y p]; apply path_basedpaths.
Defined.

(* Sometimes we end up with a sigma of a one-sided path type that's not eta-expanded, which Coq doesn't seem able to match with the previous instance. *)
Instance contr_basedpaths_etashort {X : Type} (x : X) : Contr (sig (@paths X x)) | 100
  := contr_basedpaths x.

(** Based path types with the second variable fixed. *)

Definition path_basedpaths' {X : Type} {x y : X} (p : y = x)
  : (x;1) = (y;p) :> {z:X & z=x}.
Proof.
  destruct p; reflexivity.
Defined.

Arguments path_basedpaths' {X x y} p : simpl nomatch.

Instance contr_basedpaths' {X : Type} (x : X) : Contr {y : X & y = x} | 100.
Proof.
  refine (Build_Contr _ (x;1) _).
  intros [y p]; apply path_basedpaths'.
Defined.

(** Some useful computation laws for based path spaces *)

Definition ap_pr1_path_contr_basedpaths {X : Type}
           {x y z : X} (p : x = y) (q : x = z)
  : ap pr1 (path_contr ((y;p) : {y':X & x = y'}) (z;q)) = p^ @ q.
Proof.
  destruct p, q; reflexivity.
Defined.

Definition ap_pr1_path_contr_basedpaths' {X : Type}
           {x y z : X} (p : y = x) (q : z = x)
  : ap pr1 (path_contr ((y;p) : {y':X & y' = x}) (z;q)) = p @ q^.
Proof.
  destruct p, q; reflexivity.
Defined.

Definition ap_pr1_path_basedpaths {X : Type}
           {x y : X} (p : x = y)
  : ap pr1 (path_basedpaths p) = p.
Proof.
  destruct p; reflexivity.
Defined.

Definition ap_pr1_path_basedpaths' {X : Type}
           {x y : X} (p : y = x)
  : ap pr1 (path_basedpaths' p) = p^.
Proof.
  destruct p; reflexivity.
Defined.

(** If the domain is contractible, the function is propositionally constant. *)
Definition contr_dom_equiv {A B} (f : A -> B) `{Contr A} : forall x y : A, f x = f y
  := fun x y => ap f ((contr x)^ @ contr y).

(** Any retract of a contractible type is contractible *)
Definition contr_retract {X Y : Type} `{Contr X} 
           (r : X -> Y) (s : Y -> X) (h : forall y, r (s y) = y)
  : Contr Y
  := Build_Contr _ (r (center X)) (fun y => (ap r (contr _)) @ h _).

(** Sometimes the easiest way to prove that a type is contractible doesn't produce the definitionally-simplest center.  (In particular, this can affect performance, as Coq spends a long time tracing through long proofs of contractibility to find the center.)  So we give a way to modify the center. *)
Definition contr_change_center {A : Type} (a : A) `{Contr A}
  : Contr A.
Proof.
  apply (Build_Contr _ a).
  intros; apply path_contr.
Defined.

(** The automatically generated induction principle for [IsTrunc_internal] produces two goals, so we define a custom induction principle for [Contr] that only produces the expected goal. *)
Definition Contr_ind@{u v|} (A : Type@{u}) (P : Contr A -> Type@{v})
  (H : forall (center : A) (contr : forall y, center = y), P (Build_Contr A center contr))
  (C : Contr A)
  : P C
  := match C as C0 in IsTrunc n _ return
          (match n as n0 return IsTrunc n0 _ -> Type@{v} with
           | minus_two => fun c0 => P c0
           | trunc_S k => fun _ => Unit
           end C0)
    with
    | Build_Contr center contr => H center contr
    | istrunc_S _ _ => tt
    end.
