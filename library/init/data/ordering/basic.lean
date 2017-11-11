/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import init.data.repr init.data.prod init.data.sum.basic

universes u v

inductive ordering
| lt | eq | gt

namespace ordering
  def swap : ordering → ordering
  | lt := gt
  | eq := eq
  | gt := lt

  def or_else : ordering → thunk ordering → ordering
  | lt _ := lt
  | eq f := f ()
  | gt _ := gt

  theorem swap_swap : ∀ (o : ordering), o.swap.swap = o
  | lt := rfl
  | eq := rfl
  | gt := rfl
end ordering

open ordering

instance : has_repr ordering :=
⟨(λ s, match s with | ordering.lt := "lt" | ordering.eq := "eq" | ordering.gt := "gt" end)⟩

class has_ordering (α : Type u) :=
(cmp : α → α → ordering)

protected def nat.cmp (a b : nat) : ordering :=
if a < b      then ordering.lt
else if a = b then ordering.eq
else               ordering.gt

instance : has_ordering nat :=
⟨nat.cmp⟩

instance (n) : has_ordering (fin n) :=
⟨λ a b, nat.cmp a.val b.val⟩

instance : has_ordering char :=
⟨λ c d, nat.cmp c.val d.val⟩

instance : has_ordering unsigned :=
fin.has_ordering _

protected def list.cmp {α : Type u} [has_ordering α] : list α → list α → ordering
| []     []      := ordering.eq
| []     (b::l') := ordering.lt
| (a::l) []      := ordering.gt
| (a::l) (b::l') := (has_ordering.cmp a b).or_else (list.cmp l l')

instance {α : Type u} [has_ordering α] : has_ordering (list α) :=
⟨list.cmp⟩

/- Remark: this function has a VM builtin efficient implementation. -/
protected def string.cmp (s1 s2 : string) : ordering :=
list.cmp s1.to_list s2.to_list

instance : has_ordering string :=
⟨string.cmp⟩

section
open prod

variables {α : Type u} {β : Type v} [has_ordering α] [has_ordering β]

protected def prod.cmp : α × β → α × β → ordering
| (a₁, b₁) (a₂, b₂) := (has_ordering.cmp a₁ a₂).or_else (has_ordering.cmp b₁ b₂)

instance {α : Type u} {β : Type v} [has_ordering α] [has_ordering β] : has_ordering (α × β) :=
⟨prod.cmp⟩
end

section
open sum

variables {α : Type u} {β : Type v} [has_ordering α] [has_ordering β]

protected def sum.cmp : α ⊕ β → α ⊕ β → ordering
| (inl a₁) (inl a₂) := has_ordering.cmp a₁ a₂
| (inr b₁) (inr b₂) := has_ordering.cmp b₁ b₂
| (inl a₁) (inr b₂) := lt
| (inr b₁) (inl a₂) := gt

instance {α : Type u} {β : Type v} [has_ordering α] [has_ordering β] : has_ordering (α ⊕ β) :=
⟨sum.cmp⟩
end

section
open option

variables {α : Type u} [has_ordering α]

protected def option.cmp : option α → option α → ordering
| (some a₁) (some a₂) := has_ordering.cmp a₁ a₂
| (some a₁) none      := gt
| none      (some a₂) := lt
| none      none      := eq

instance {α : Type u} [has_ordering α] : has_ordering (option α) :=
⟨option.cmp⟩
end

export has_ordering (cmp)

section cmp_relations
variables {α : Type u} [has_ordering α]

@[reducible] def cmp_lt (a b : α) : Prop :=
cmp a b = ordering.lt

@[reducible] def cmp_eq (a b : α) : Prop :=
cmp a b = ordering.eq

@[reducible] def cmp_gt (a b : α) : Prop :=
cmp a b = ordering.gt

infix ` <_cmp `:50 := cmp_lt
infix ` =_cmp `:50 := cmp_eq
infix ` >_cmp `:50 := cmp_gt

end cmp_relations