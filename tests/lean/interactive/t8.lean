(* import("tactic.lua") *)
setoption tactic::proof_state::goal_names true.
theorem T (a : Bool) : a => a /\ a.
   apply Discharge.
   apply Conj.
   exact.
   done.
