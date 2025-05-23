Require Import
  HoTT.Classes.interfaces.abstract_algebra.

(** If [B] is a (bounded) lattice, then so is [A -> B], pointwise.
    This relies on functional extensionality. *)
Section contents.
  Context `{Funext}.

  Context {A B : Type}.
  Context `{BJoin : Join B}.
  Context `{BMeet : Meet B}.
  Context `{BBottom : Bottom B}.
  Context `{BTop : Top B}.

  #[export] Instance bot_fun : Bottom (A -> B)
    := fun _ => ⊥.

  #[export] Instance top_fun : Top (A -> B)
    := fun _ => ⊤.

  #[export] Instance join_fun : Join (A -> B) :=
    fun (f g : A -> B) (a : A) => (f a) ⊔ (g a).

  #[export] Instance meet_fun : Meet (A -> B) :=
    fun (f g : A -> B) (a : A) => (f a) ⊓ (g a).

  (** Try to solve some of the lattice obligations automatically *)
  Create HintDb lattice_hints.
  #[local]
  Hint Resolve
       associativity
       absorption
       commutativity | 1 : lattice_hints.
  Local Ltac reduce_fun := compute; intros; apply path_forall; intro.

  #[export] Instance lattice_fun `{!IsLattice B} : IsLattice (A -> B).
  Proof.
    repeat split; try apply _; reduce_fun.
    1,4: apply associativity.
    1,3: apply commutativity.
    1,2: apply binary_idempotent.
    1,2: apply absorption.
  Defined.

  Instance boundedjoinsemilattice_fun
   `{!IsBoundedJoinSemiLattice B} :
    IsBoundedJoinSemiLattice (A -> B).
  Proof.
    repeat split; try apply _; reduce_fun.
    * apply associativity.
    * apply left_identity.
    * apply right_identity.
    * apply commutativity.
    * apply binary_idempotent.
  Defined.

  Instance boundedmeetsemilattice_fun
   `{!IsBoundedMeetSemiLattice B} :
    IsBoundedMeetSemiLattice (A -> B).
  Proof.
    repeat split; try apply _; reduce_fun.
    * apply associativity.
    * apply left_identity.
    * apply right_identity.
    * apply commutativity.
    * apply binary_idempotent.
  Defined.

  #[export] Instance boundedlattice_fun
   `{!IsBoundedLattice B} : IsBoundedLattice (A -> B).
  Proof.
    repeat split; try apply _; reduce_fun; apply absorption.
  Defined.
End contents.

#[export]
  Hint Resolve
       associativity
       absorption
       commutativity | 1 : lattice_hints.

