{ mkDerivation, fetchFromGitHub
, async, base, bytestring, c2hs, clock, containers
, grpc, managed, pipes, proto3-suite, proto3-wire, QuickCheck, safe
, sorted-list, stdenv, stm, tasty, tasty-hunit, tasty-quickcheck
, text, time, transformers, turtle, unix, vector
}:
mkDerivation {
  pname = "grpc-haskell-core";
  version = "0.0.0.0";
  src = "${fetchFromGitHub {
    owner = "awakesecurity";
    repo = "gRPC-haskell";
    rev = "c83eacd1f30f20b0661fb651ad4234faf19c8160";
    sha256 = "1l95rjrnsiy23gqmjxirqc4yn38nl94whq25dd6lgj44pgikd72n";
  }}/core";
  libraryHaskellDepends = [
    async base bytestring clock containers managed pipes proto3-suite
    proto3-wire safe sorted-list stm tasty tasty-hunit tasty-quickcheck
    transformers vector
  ];
  librarySystemDepends = [ grpc ];
  libraryToolDepends = [ c2hs ];
  testHaskellDepends = [
    async base bytestring clock containers managed pipes proto3-suite
    QuickCheck safe tasty tasty-hunit tasty-quickcheck text time
    transformers turtle unix
  ];
  homepage = "https://github.com/awakenetworks/gRPC-haskell";
  description = "Haskell implementation of gRPC layered on shared C library";
  license = stdenv.lib.licenses.asl20;
}
