{ lib, buildGoModule, fetchFromGitHub, installShellFiles, testers, dnscontrol }:

buildGoModule rec {
  pname = "dnscontrol";
  version = "4.14.0";

  src = fetchFromGitHub {
    owner = "StackExchange";
    repo = "dnscontrol";
    rev = "v${version}";
    hash = "sha256-XKsP6ZJCY196wYsp54d0OgF4zj0b9H8820wBAOjrDbg=";
  };

  vendorHash = "sha256-6ePEgHVFPtkW+C57+cPLj5yc9YaCRKrnBFo2Y1pcglM=";

  nativeBuildInputs = [ installShellFiles ];

  subPackages = [ "." ];

  ldflags = [ "-s" "-w" "-X=main.version=${version}" ];

  postInstall = ''
    installShellCompletion --cmd dnscontrol \
      --bash <($out/bin/dnscontrol shell-completion bash) \
      --zsh <($out/bin/dnscontrol shell-completion zsh)
  '';

  preCheck = ''
    # requires network
    rm pkg/spflib/flatten_test.go pkg/spflib/parse_test.go
  '';

  passthru.tests = {
    version = testers.testVersion {
      command = "${lib.getExe dnscontrol} version";
      package = dnscontrol;
    };
  };

  meta = with lib; {
    description = "Synchronize your DNS to multiple providers from a simple DSL";
    homepage = "https://dnscontrol.org/";
    changelog = "https://github.com/StackExchange/dnscontrol/releases/tag/${src.rev}";
    license = licenses.mit;
    maintainers = with maintainers; [ SuperSandro2000 ];
    mainProgram = "dnscontrol";
  };
}
