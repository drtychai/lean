import Int.
definition f1 (f : Int -> Int) (x : Int) : Int := f (f (f (f x)))
definition f2 (f : Int -> Int) (x : Int) : Int := f1 (f1 (f1 (f1 f))) x
definition f3 (f : Int -> Int) (x : Int) : Int := f1 (f2 (f2 f)) x
variable f : Int -> Int.
setoption pp::width 80.
setoption lean::pp::max_depth 2000.
eval f3 f 0.