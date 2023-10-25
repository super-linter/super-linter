using System;

namespace HelloWorld;

internal enum Foo
{
  Bar = 1,
  Baz = 2
}

public class TestClass
{
  public required Foo Bar { get; set; }
}
