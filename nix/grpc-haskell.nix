{ mkDerivation, fetchFromGitHub
, async, base, bytestring, clock, containers
, criterion, grpc-haskell-core, managed, pipes, proto3-suite
, proto3-wire, QuickCheck, random, safe, stdenv, tasty, tasty-hunit
, tasty-quickcheck, text, time, transformers, turtle, unix
}:
mkDerivation {
  pname = "grpc-haskell";
  version = "0.0.0.0";
  src = fetchFromGitHub {
    owner = "awakesecurity";
    repo = "gRPC-haskell";
    rev = "be70fc49b0dc25313f57d0e6c6ba2a9fa46b9e6b";
    sha256 = "19ksm41w3yys2l0a4mfc2z5samrjvsiisr59b813gy1g2rzdqc17";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    async base bytestring grpc-haskell-core managed proto3-suite
    proto3-wire
  ];
  testHaskellDepends = [
    async base bytestring clock containers managed pipes proto3-suite
    QuickCheck safe tasty tasty-hunit tasty-quickcheck text time
    transformers turtle unix
  ];
  benchmarkHaskellDepends = [
    async base bytestring criterion proto3-suite random
  ];
  homepage = "https://github.com/awakenetworks/gRPC-haskell";
  description = "Haskell implementation of gRPC layered on shared C library";
  license = stdenv.lib.licenses.asl20;
}
