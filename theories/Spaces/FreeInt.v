Require Import Basics Types WildCat.Core Truncations.Core Spaces.Int
  AbelianGroup AbHom Centralizer AbProjective Groups.FreeGroup AbGroups.Z.

(** * The free group on one generator *)

(** We can define the integers as the free group on one generator, which we denote [Z1] below. Results from Centralizer.v and Groups.FreeGroup let us show that [Z1] is abelian. *)

(** We define [Z1] as the free group with a single generator. *)
Definition Z1 := FreeGroup Unit.
Definition Z1_gen : Z1 := freegroup_in tt. (* The generator *)

(** The recursion principle of [Z1] and its computation rule. *)
Definition Z1_rec {G : Group} (g : G) : Z1 $-> G
  := FreeGroup_rec (unit_name g).

Definition Z1_rec_beta {G : Group} (g : G) : Z1_rec g Z1_gen = g
  := FreeGroup_rec_beta _ _ _.

(** The free group [Z1] on one generator is isomorphic to the subgroup of [Z1] generated by the generator.  And such cyclic subgroups are known to be commutative, by [commutative_cyclic_subgroup]. *)
Instance Z1_commutative `{Funext} : Commutative (@group_sgop Z1)
  := commutative_iso_commutative iso_subgroup_incl_freegroupon.
(* TODO: [Funext] is used in [isfreegroupon_freegroup], but there is a comment there saying that it can be removed.  If that is done, can remove it from many results in this file. A different proof of this result, directly using the construction of the free group, could probably also avoid [Funext]. *)

Definition ab_Z1 `{Funext} : AbGroup
  := Build_AbGroup Z1 _.

(** The universal property of [ab_Z1]. *)
Lemma equiv_Z1_hom@{u v | u < v} `{Funext} (A : AbGroup@{u})
  : GroupIsomorphism (ab_hom@{u v} ab_Z1@{u v} A) A.
Proof.
  snapply Build_GroupIsomorphism'.
  - refine (_ oE (equiv_freegroup_rec@{u u u v} A Unit)^-1).
    symmetry. exact (Build_Equiv _ _ (fun a => unit_name a) _).
  - intros f g. cbn. reflexivity.
Defined.

Definition nat_to_Z1 : nat -> Z1
  := fun n => grp_pow Z1_gen n.

Definition Z1_mul_nat `{Funext} (n : nat) : ab_Z1 $-> ab_Z1
  := Z1_rec (nat_to_Z1 n).

Lemma Z1_mul_nat_beta {A : AbGroup} (a : A) (n : nat)
  : Z1_rec a (nat_to_Z1 n) = ab_mul n a.
Proof.
  induction n as [|n H].
  1: done.
  exact (grp_pow_natural _ _ _).
Defined.

(** [ab_Z1] is projective. *)
Instance ab_Z1_projective `{Funext}
  : IsAbProjective ab_Z1.
Proof.
  intros A B p f H1.
  pose proof (a := @center _ (H1 (f Z1_gen))).
  strip_truncations.
  snrefine (tr (Z1_rec a.1; _)).
  cbn beta. apply ap10.
  apply ap. (* of the coercion [grp_homo_map] *)
  apply path_homomorphism_from_free_group.
  simpl.
  intros [].
  exact a.2.
Defined.

(** The map sending the generator to [1 : Int]. *)
Definition Z1_to_Z `{Funext} : ab_Z1 $-> abgroup_Z
  := Z1_rec (G:=abgroup_Z) 1%int.

(** TODO:  Prove that [Z1_to_Z] is a group isomorphism. *)
