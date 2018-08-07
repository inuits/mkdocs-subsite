{ pkgs ? import <nixpkgs> { config = { allowBroken = true; }; } }:
with pkgs;
with pkgs.pythonPackages;

let

livereload = buildPythonPackage rec {
  pname = "livereload";
  version = "2.5.1";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0b2yyfnpddmrwjfqsndidzchkf3l9jlgzfkwl8dplim9gq6y2ba2";
  };
  propagatedBuildInputs = [ markdown six tornado ];
};

markdown = buildPythonPackage rec {
  pname = "Markdown";
  version = "2.6.11";
  src = fetchPypi {
    inherit pname version;
    sha256 = "108g80ryzykh8bj0i7jfp71510wrcixdi771lf2asyghgyf8cmm8";
  };
  checkInputs = [ nose pyyaml pytest ];
};

mkdocs = buildPythonApplication rec {
  pname = "mkdocs";
  version = "1.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "00m8yx14plclq9yqdm7qh3v38ichma17ly33vis2xjnn9hbd4cgp";
  };
  propagatedBuildInputs = [ tornado livereload click pyyaml jinja2 ];
};

in

buildPythonApplication {
  name = "mkdocs-factsheet";
  propagatedBuildInputs = [ mkdocs pylint flake8 ];
}
