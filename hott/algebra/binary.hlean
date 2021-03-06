/-
Copyright (c) 2014 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Jeremy Avigad

General properties of binary operations.
-/
open eq.ops function

namespace binary
  section
    variable {A : Type}
    variables (op₁ : A → A → A) (inv : A → A) (one : A)

    local notation a * b := op₁ a b
    local notation a ⁻¹  := inv a

    definition commutative        := Πa b, a * b = b * a
    definition associative        := Πa b c, (a * b) * c = a * (b * c)
    definition left_identity      := Πa, one * a = a
    definition right_identity     := Πa, a * one = a
    definition left_inverse       := Πa, a⁻¹ * a = one
    definition right_inverse      := Πa, a * a⁻¹ = one
    definition left_cancelative   := Πa b c, a * b = a * c → b = c
    definition right_cancelative  := Πa b c, a * b = c * b → a = c

    definition inv_op_cancel_left  := Πa b, a⁻¹ * (a * b) = b
    definition op_inv_cancel_left  := Πa b, a * (a⁻¹ * b) = b
    definition inv_op_cancel_right  := Πa b, a * b⁻¹ * b =  a
    definition op_inv_cancel_right  := Πa b, a * b * b⁻¹ = a

    variable (op₂ : A → A → A)

    local notation a + b := op₂ a b

    definition left_distributive  := Πa b c, a * (b + c) = a * b + a * c
    definition right_distributive  := Πa b c, (a + b) * c = a * c + b * c

    definition right_commutative  {B : Type} (f : B → A → B) := Π b a₁ a₂, f (f b a₁) a₂ = f (f b a₂) a₁
    definition left_commutative  {B : Type}  (f : A → B → B) := Π a₁ a₂ b, f a₁ (f a₂ b) = f a₂ (f a₁ b)
  end

  section
    variable {A : Type}
    variable {f : A → A → A}
    variable H_comm : commutative f
    variable H_assoc : associative f
    local infixl `*` := f
    theorem left_comm : left_commutative f :=
    take a b c, calc
      a*(b*c) = (a*b)*c  : H_assoc
        ...   = (b*a)*c  : H_comm
        ...   = b*(a*c)  : H_assoc

    theorem right_comm : right_commutative f :=
    take a b c, calc
      (a*b)*c = a*(b*c) : H_assoc
        ...   = a*(c*b) : H_comm
        ...   = (a*c)*b : H_assoc

    theorem comm4 (a b c d : A) : a*b*(c*d) = a*c*(b*d) :=
    calc
      a*b*(c*d) = a*b*c*d   : H_assoc
        ...     = a*c*b*d   : right_comm H_comm H_assoc
        ...     = a*c*(b*d) : H_assoc
  end

  section
    variable {A : Type}
    variable {f : A → A → A}
    variable H_assoc : associative f
    local infixl `*` := f
    theorem assoc4helper (a b c d) : (a*b)*(c*d) = a*((b*c)*d) :=
    calc
      (a*b)*(c*d) = a*(b*(c*d)) : H_assoc
              ... = a*((b*c)*d) : H_assoc
  end

  definition right_commutative_compose_right
    {A B : Type} (f : A → A → A) (g : B → A) (rcomm : right_commutative f) : right_commutative (compose_right f g) :=
  λ a b₁ b₂, !rcomm

  definition left_commutative_compose_left
    {A B : Type} (f : A → A → A) (g : B → A) (lcomm : left_commutative f) : left_commutative (compose_left f g) :=
  λ a b₁ b₂, !lcomm
end binary

open eq
namespace is_equiv
  definition inv_preserve_binary {A B : Type} (f : A → B) [H : is_equiv f]
    (mA : A → A → A) (mB : B → B → B) (H : Π(a a' : A), f (mA a a') = mB (f a) (f a'))
    (b b' : B) : f⁻¹ (mB b b') = mA (f⁻¹ b) (f⁻¹ b') :=
  begin
  have H2 : f⁻¹ (mB (f (f⁻¹ b)) (f (f⁻¹ b'))) = f⁻¹ (f (mA (f⁻¹ b) (f⁻¹ b'))), from ap f⁻¹ !H⁻¹,
  rewrite [+right_inv f at H2,left_inv f at H2,▸* at H2,H2]
  end

  definition preserve_binary_of_inv_preserve {A B : Type} (f : A → B) [H : is_equiv f]
    (mA : A → A → A) (mB : B → B → B) (H : Π(b b' : B), f⁻¹ (mB b b') = mA (f⁻¹ b) (f⁻¹ b'))
    (a a' : A) : f (mA a a') = mB (f a) (f a') :=
  begin
  have H2 : f (mA (f⁻¹ (f a)) (f⁻¹ (f a'))) = f (f⁻¹ (mB (f a) (f a'))), from ap f !H⁻¹,
  rewrite [right_inv f at H2,+left_inv f at H2,▸* at H2,H2]
  end
end is_equiv
namespace equiv
  open is_equiv
  definition inv_preserve_binary {A B : Type} (f : A ≃ B)
    (mA : A → A → A) (mB : B → B → B) (H : Π(a a' : A), f (mA a a') = mB (f a) (f a'))
    (b b' : B) : f⁻¹ (mB b b') = mA (f⁻¹ b) (f⁻¹ b') :=
  inv_preserve_binary f mA mB H b b'

  definition preserve_binary_of_inv_preserve {A B : Type} (f : A ≃ B)
    (mA : A → A → A) (mB : B → B → B) (H : Π(b b' : B), f⁻¹ (mB b b') = mA (f⁻¹ b) (f⁻¹ b'))
    (a a' : A) : f (mA a a') = mB (f a) (f a') :=
  preserve_binary_of_inv_preserve f mA mB H a a'
end equiv
