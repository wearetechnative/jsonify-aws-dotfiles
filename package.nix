{ lib, buildGoModule, go }:
buildGoModule rec {
  pname = "jsonify-aws-dotfiles";

  version = "1.0";

  src = ./.;

  doCheck = false;

  env.CGO_ENABLED = "0";

  vendorHash = "sha256-W6XVd68MS0ungMgam8jefYMVhyiN6/DB+bliFzs2rdk=";

  meta = with lib; {
    description = ''
      Convert aws config and credential files into a single JSON object
    '';
    homepage = "https://github.com/wearetechnative/jsonify-aws-dotfiles";
    license = licenses.mit;
  };

}
