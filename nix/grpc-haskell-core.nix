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
    rev = "be70fc49b0dc25313f57d0e6c6ba2a9fa46b9e6b";
    sha256 = "19ksm41w3yys2l0a4mfc2z5samrjvsiisr59b813gy1g2rzdqc17";
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
