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

markdown_include = buildPythonPackage rec {
  pname = "markdown-include";
  version = "0.5.1";
  src = fetchPypi {
    inherit pname version;
    sha256 = "03r521ysbjjmxps8ar0q6scr19azbk4kp2akhw49lj49nmhm993j";
  };
  propagatedBuildInputs = [ markdown ];
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

pymdown-extensions = buildPythonPackage rec {
  pname = "pymdown-extensions";
  version = "4.9.2";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0a9p46il20vn95xc9qsj6q85ph64zfyqw3rg0r68dkicxmdmr4f9";
  };
  checkInputs = [ pyyaml pytest ];
  propagatedBuildInputs = [ markdown ];
};

mkdocs = buildPythonApplication rec {
  pname = "mkdocs";
  version = "0.17.3";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1faga4arlaq5y883zgpfgmf4iqfszmk50dycrkx7gc6y3a3rnvhj";
  };
  propagatedBuildInputs = [ tornado livereload click pyyaml markdown_include jinja2 ];
};

in

buildPythonApplication {
  name = "mkdocs-factsheet";
  propagatedBuildInputs = [ mkdocs pylint flake8 ];
}
