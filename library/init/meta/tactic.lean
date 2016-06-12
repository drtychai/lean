/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import init.meta.base_tactic init.meta.environment init.trace

meta_constant tactic_state : Type₁

namespace tactic_state
meta_constant env         : tactic_state → environment
meta_constant to_format   : tactic_state → format
meta_constant format_expr : tactic_state → expr → format
end tactic_state

meta_definition tactic_state.has_to_format [instance] : has_to_format tactic_state :=
has_to_format.mk tactic_state.to_format

meta_definition tactic [reducible] (A : Type) := base_tactic tactic_state A

namespace tactic
open tactic_state

meta_definition get_env : tactic environment :=
do s ← read,
   return (env s)

meta_definition get_decl (n : name) : tactic declaration :=
do s ← read,
   returnex (environment.get (env s) n)

meta_definition trace (s : string) : tactic unit :=
return (_root_.trace s (λ u, ()))

meta_definition trace_fmt (fmt : format) : tactic unit :=
return (_root_.trace_fmt fmt (λ u, ()))

meta_definition trace_expr (e : expr) : tactic unit :=
do s ← read,
   trace_fmt (format_expr s e)

meta_definition trace_state : tactic unit :=
do s ← read,
   trace_fmt (to_fmt s)

inductive transparency :=
| all | semireducible | reducible | none

meta_constant result     : tactic expr
meta_constant main_type  : tactic expr
meta_constant intro      : name → tactic unit
meta_constant assumption : tactic unit
meta_constant rename     : name → name → tactic unit
meta_constant revert_lst : list name → tactic unit
meta_constant infer_type : expr → tactic expr
meta_constant whnf       : expr → tactic expr
meta_constant unify_core : expr → expr → transparency → tactic bool
meta_constant get_local  : name → tactic expr
open list

meta_definition intros : tactic unit :=
do t ← main_type,
   match t with
   | expr.pi   _ _ _ _ := do intro "_", intros
   | expr.elet _ _ _ _ := do intro "_", intros
   | _                 := skip
   end

meta_definition intro_lst : list name → tactic unit
| []      := skip
| (n::ns) := do intro n, intro_lst ns

meta_definition revert (n : name) : tactic unit :=
revert_lst [n]

meta_definition unify (a b : expr) : tactic bool :=
unify_core a b transparency.semireducible

meta_definition get_local_type (n : name) : tactic expr :=
do e ← get_local n,
   infer_type e

end tactic