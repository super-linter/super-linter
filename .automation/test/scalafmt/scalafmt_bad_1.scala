object a {
  class a[
   t1,
   t2 // comment
  ](a1: Int,
    a2: Int // comment
  )(
    b1: String,
    b2: String // comment
  )(implicit
    c1: SomeType1,
    c2: SomeType2 // comment
  ) {
    def this(
      a1: Int,
      a2: Int // comment
    )(
      b1: String,
      b2: String // comment
    )(implicit
      c1: SomeType1,
      c2: SomeType2 // comment
    ) = this(
      a1,
      a2 // comment
    ) (
      b1,
      b2 // comment
    )
  }
}
