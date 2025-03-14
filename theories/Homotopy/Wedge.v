Require Import Basics Types.
Require Import Pointed.Core Pointed.pSusp.
Require Import Colimits.Pushout.
Require Import WildCat.
Require Import Homotopy.Suspension.

Local Set Universe Minimization ToSet.

(** * Wedge sums *)

Local Open Scope pointed_scope.

Definition Wedge (X Y : pType) : pType
  := [Pushout (fun _ : Unit => point X) (fun _ => point Y), pushl (point X)].

Notation "X \/ Y" := (Wedge X Y) : pointed_scope.

Definition wedge_inl {X Y} : X $-> X \/ Y.
Proof.
  snapply Build_pMap.
  - exact (fun x => pushl x).
  - reflexivity.
Defined.

Definition wedge_inr {X Y} : Y $-> X \/ Y.
Proof.
  snapply Build_pMap.
  - exact (fun x => pushr x).
  - symmetry.
    by rapply pglue.
Defined.

Definition wglue {X Y : pType}
  : pushl (point X) = (pushr (point Y)) :> (X \/ Y) := pglue tt.

(** Wedge recursion into an unpointed type. *)
Definition wedge_rec' {X Y : pType} {Z : Type}
  (f : X -> Z) (g : Y -> Z) (w : f pt = g pt)
  : Wedge X Y -> Z.
Proof.
  snapply Pushout_rec.
  - exact f.
  - exact g.
  - intro.
    exact w.
Defined.

Definition wedge_rec {X Y : pType} {Z : pType} (f : X $-> Z) (g : Y $-> Z)
  : X \/ Y $-> Z.
Proof.
  snapply Build_pMap.
  - snapply (wedge_rec' f g).
    exact (point_eq f @ (point_eq g)^).
  - exact (point_eq f).
Defined.

Definition wedge_rec_beta_wglue {X Y Z : pType} (f : X $-> Z) (g : Y $-> Z)
  : ap (wedge_rec f g) wglue = point_eq f @ (point_eq g)^
  := Pushout_rec_beta_pglue _ f g _ tt.

Definition wedge_pr1 {X Y : pType} : X \/ Y $-> X
  := wedge_rec pmap_idmap pconst.

Definition wedge_pr2 {X Y : pType} : X \/ Y $-> Y
  := wedge_rec pconst pmap_idmap.

Definition wedge_incl (X Y : pType) : X \/ Y $-> X * Y
  := pprod_corec _ wedge_pr1 wedge_pr2.

Definition wedge_incl_beta_wglue {X Y : pType}
  : ap (@wedge_incl X Y) wglue = 1.
Proof.
  lhs_V napply eta_path_prod.
  lhs napply ap011.
  - lhs_V napply ap_compose.
    napply wedge_rec_beta_wglue.
  - lhs_V napply ap_compose.
    napply wedge_rec_beta_wglue.
  - reflexivity.
Defined.

(** 1-universal property of wedge. *)
Lemma wedge_up X Y Z (f g : X \/ Y $-> Z)
  : f $o wedge_inl $== g $o wedge_inl
  -> f $o wedge_inr $== g $o wedge_inr
  -> f $== g.
Proof.
  intros p q.
  snapply Build_pHomotopy.
  - snapply (Pushout_ind _ p q).
    intros [].
    transport_paths FlFr.
    lhs napply (whiskerL _ (dpoint_eq q)).
    rhs napply (whiskerR (dpoint_eq p)).
    clear p q.
    lhs napply concat_p_pp.
    simpl.
    apply moveR_pV.
    lhs napply whiskerL.
    { napply whiskerR.
      apply ap_V. }
    lhs napply concat_p_pp.
    lhs napply whiskerR.
    1: apply concat_pV.
    rhs napply concat_p_pp.
    apply moveL_pM.
    lhs_V napply concat_p1.
    lhs napply concat_pp_p.
    lhs_V napply whiskerL.
    1: apply (inv_pp 1).
    rhs napply whiskerL.
    2: apply ap_V.
    apply moveL_pV.
    reflexivity.
  - simpl; pelim p q.
    f_ap.
    1: apply concat_1p.
    lhs napply inv_pp.
    apply concat_p1.
Defined.

Instance hasbinarycoproducts : HasBinaryCoproducts pType.
Proof.
  intros X Y.
  snapply Build_BinaryCoproduct.
  - exact (X \/ Y).
  - exact wedge_inl.
  - exact wedge_inr.
  - intros Z f g.
    by apply wedge_rec.
  - intros Z f g.
    snapply Build_pHomotopy.
    1: reflexivity.
    by simpl; pelim f.
  - intros Z f g.
    snapply Build_pHomotopy.
    1: reflexivity.
    simpl.
    apply moveL_pV.
    apply moveL_pM.
    refine (_ @ (ap_V _ (pglue tt))^).
    apply moveR_Mp.
    apply moveL_pV.
    apply moveR_Vp.
    refine (Pushout_rec_beta_pglue _ f g _ _  @ _).
    simpl.
    by pelim f g.
  - intros Z f g p q.
    by apply wedge_up.
Defined.

(** *** Lemmas about wedge functions *)

Lemma wedge_pr1_inl {X Y} : wedge_pr1 $o (@wedge_inl X Y) $== pmap_idmap.
Proof.
  reflexivity.
Defined.

Lemma wedge_pr1_inr {X Y} : wedge_pr1 $o (@wedge_inr X Y) $== pconst.
Proof.
  snapply Build_pHomotopy.
  1: reflexivity.
  rhs napply concat_p1.
  rhs napply concat_p1.
  rhs napply (ap_V _ wglue).
  exact (inverse2 (wedge_rec_beta_wglue pmap_idmap pconst)^).
Defined.

Lemma wedge_pr2_inl {X Y} : wedge_pr2 $o (@wedge_inl X Y) $== pconst.
Proof.
  reflexivity.
Defined.

Lemma wedge_pr2_inr {X Y} : wedge_pr2 $o (@wedge_inr X Y) $== pmap_idmap.
Proof.
  snapply Build_pHomotopy.
  1: reflexivity.
  rhs napply concat_p1.
  rhs napply concat_p1.
  rhs napply (ap_V _ wglue).
  exact (inverse2 (wedge_rec_beta_wglue pconst pmap_idmap)^).
Defined.

(** Wedge of an indexed family of pointed types *)

(** Note that the index type is not necessarily pointed. An empty wedge is the unit type which is the zero object in the category of pointed types. *)
Definition FamilyWedge (I : Type) (X : I -> pType) : pType.
Proof.
  snapply Build_pType.
  - srefine (Pushout (A := I) (B := sig X) (C := pUnit) _ _).
    + exact (fun i => (i; pt)).
    + exact (fun _ => pt).
  - apply pushr.
    exact pt.
Defined.

Definition fwedge_in' (I : Type) (X : I -> pType)
  : forall i, X i $-> FamilyWedge I X
  := fun i => Build_pMap _ _ (fun x => pushl (i; x)) (pglue i).

(** We have an inclusion map [pushl : sig X -> FamilyWedge X].  When [I] is pointed, so is [sig X], and then this inclusion map is pointed. *)
Definition fwedge_in (I : pType) (X : I -> pType)
  : psigma (pointed_fam X) $-> FamilyWedge I X
  := Build_pMap _ _ pushl (pglue pt).

(** Recursion principle for the wedge of an indexed family of pointed types. *)
Definition fwedge_rec (I : Type) (X : I -> pType) (Z : pType)
  (f : forall i, X i $-> Z)
  : FamilyWedge I X $-> Z.
Proof.
  snapply Build_pMap.
  - snapply Pushout_rec.
    + exact (sig_rec f).
    + exact pconst.
    + intros i.
      exact (point_eq (f i)).
  - exact idpath.
Defined.

(** We specify a universe variable here to prevent minimization to [Set]. *)
Instance hasallcoproducts_ptype : HasAllCoproducts pType@{u}.
Proof.
  intros I X.
  snapply Build_Coproduct.
  - exact (FamilyWedge I X).
  - exact (fwedge_in' I X).
  - exact (fwedge_rec I X).
  - intros Z f i.
    snapply Build_pHomotopy.
    1: reflexivity.
    simpl.
    apply moveL_pV.
    apply equiv_1p_q1.
    symmetry.
    exact (Pushout_rec_beta_pglue Z _ (unit_name pt) (fun i => point_eq (f i)) _).
  - intros Z f g h.
    snapply Build_pHomotopy.
    + snapply Pushout_ind.
      * intros [i x].
        napply h.
      * intros [].
        exact (point_eq _ @ (point_eq _)^).
      * intros i; cbn.
        transport_paths FlFr.
        lhs napply concat_p_pp.
        apply moveR_pV.
        rhs napply concat_pp_p.
        apply moveL_pM.
        symmetry.
        exact (dpoint_eq (h i)).
    + reflexivity.
Defined.

(** Wedge inclusions into the product can be defined if the indexing type has decidable paths. This is because we need to choose which factor a given wedge summand should land in. *)
Definition fwedge_incl `{Funext} (I : Type) `(DecidablePaths I) (X : I -> pType)
  : FamilyWedge I X $-> pproduct X
  := cat_coprod_prod X.

(** ** The pinch map on the suspension *)

(** Given a suspension, there is a natural map from the suspension to the wedge of the suspension with itself. This is known as the pinch map.

This is the image to keep in mind:
<<
                                    *
                                   /|\
                                  / | \
    Susp X                       /  |  \
                                /   |   \
       *                       * merid(x)*
      /|\                       \   |   /
     / | \                       \  |  /
    /  |  \                       \ | /
   /   |   \      Pinch            \|/
  * merid(x)*   ---------->         *
   \   |   /                       /|\
    \  |  /                       / | \
     \ | /                       /  |  \
      \|/                       /   |   \
       *                       * merid(x)*
                                \   |   /
                                 \  |  /
                                  \ | /
                                   \|/
                                    *
>>

Note that this is only a conceptual picture as we aren't working with "reduced suspensions". This means we have to track back along [merid pt] making this map a little trickier to imagine. *)

(** The pinch map for a suspension. *)
Definition psusp_pinch (X : pType) : psusp X $-> psusp X \/ psusp X.
Proof.
  refine (Build_pMap _ _ (Susp_rec pt pt _) idpath).
  intros x.
  refine (ap wedge_inl _ @ wglue @ ap wedge_inr _ @ wglue^).
  1,2: exact (loop_susp_unit X x).
Defined.

(** It should compute when [ap]ed on a merid. *)
Definition psusp_pinch_beta_merid {X : pType} (x : X)
  : ap (psusp_pinch X) (merid x)
    = ap wedge_inl (loop_susp_unit X x) @ wglue
    @ ap wedge_inr (loop_susp_unit X x) @ wglue^.
Proof.
  rapply Susp_rec_beta_merid.
Defined.

(** Doing wedge projections on the pinch map gives the identity. *)
Definition wedge_pr1_psusp_pinch {X}
  : wedge_pr1 $o psusp_pinch X $== Id (psusp X).
Proof.
  snapply Build_pHomotopy.
  - snapply Susp_ind_FlFr.
    + reflexivity.
    + exact (merid pt).
    + intros x.
      rhs napply concat_1p.
      rhs napply ap_idmap.
      apply moveR_pM.
      change (?t = _) with (t = loop_susp_unit X x).
      lhs napply (ap_compose (psusp_pinch X)).
      lhs napply (ap _ (psusp_pinch_beta_merid x)).
      lhs napply ap_pp.
      lhs napply (ap (fun x => _ @ x) (ap_V _ _)).
      apply moveR_pV.
      rhs napply (whiskerL _ (wedge_rec_beta_wglue _ _)).
      lhs napply ap_pp.
      lhs napply (ap (fun x => _ @ x)).
      { lhs_V napply ap_compose.
        apply ap_const. }
      lhs napply concat_p1.
      lhs napply ap_pp.
      lhs napply (ap (fun x => _ @ x) (wedge_rec_beta_wglue _ _)).
      f_ap.
      lhs_V napply (ap_compose wedge_inl).
      apply ap_idmap.
  - reflexivity.
Defined.

Definition wedge_pr2_psusp_pinch {X}
  : wedge_pr2 $o psusp_pinch X $== Id (psusp X).
Proof.
  snapply Build_pHomotopy.
  - snapply Susp_ind_FlFr.
    + reflexivity.
    + exact (merid pt).
    + intros x.
      rhs napply concat_1p.
      rhs napply ap_idmap.
      apply moveR_pM.
      change (?t = _) with (t = loop_susp_unit X x).
      lhs napply (ap_compose (psusp_pinch X)).
      lhs napply (ap _ (psusp_pinch_beta_merid x)).
      lhs napply ap_pp.
      lhs napply (ap (fun x => _ @ x) (ap_V _ _)).
      apply moveR_pV.
      rhs napply (whiskerL _ (wedge_rec_beta_wglue _ _)).
      lhs napply ap_pp.
      lhs napply (ap (fun x => _ @ x) _).
      { lhs_V napply ap_compose.
        apply ap_idmap. }
      rhs napply concat_p1.
      apply moveR_pM.
      lhs napply ap_pp.
      rhs napply concat_pV.
      lhs napply (ap _ (wedge_rec_beta_wglue _ _)).
      apply moveR_pM.
      lhs_V napply (ap_compose wedge_inl).
      rapply ap_const.
  - reflexivity.
Defined.

