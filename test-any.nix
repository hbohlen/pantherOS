# Test lib.any behavior
{ lib }:
let
  testList = [ 1 2 3 ];
  result = lib.any (x: x > 2) testList;
in
{
  result = result;
  type = builtins.typeOf result;
}
