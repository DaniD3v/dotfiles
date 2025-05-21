#!/usr/bin/env nu
# pkg-shell script

def main [missing_deps_closure: closure] {
  let missing_deps = find-missing-deps $missing_deps_closure
  if ($missing_deps | is-empty) {return}

  $missing_deps
    | exec "nix-shell" --command "nu" -p pkg-config ...$in
}

def "main cargo" [] {
  "cc" | assert-installed
  "pkg-config" | assert-installed

  main {
    cargo b --keep-going | complete | get stderr | split row " "
      | parse -r "`(.*\\.pc)`" | get "capture0" | uniq
  }
}

def find-missing-deps [
  missing_deps_closure: closure,
  inherit_dep_paths: list = [],
] {
  # build in a clean environment
  $env.PKG_CONFIG_FOR_TARGET = "pkg-config"
  $env.PKG_CONFIG_PATH_FOR_TARGET = $inherit_dep_paths | str join ':';

  let missing_deps = do $missing_deps_closure;
  if ($missing_deps | is-empty) {return}

  $missing_deps
    # find the libraries to install to satisfy the dependencies
    | par-each {{index:$in, libs: (ns pkg-config $in)}}
    # remove ambiguities in which package to install with user-input
    | reduce -f [] {|it, acc| $acc | append (
      let libs = $it | get libs;
      if (not ($libs | any {$in in $acc})) {
        $libs | input opt-list $"Choose a package for ($it | get index)"
      }
    )}
    | do {print $"installing ($in)"; $in}
    | append (find-missing-deps $missing_deps_closure (
      $in | pkg-config-exports | append $inherit_dep_paths
    ))
    | uniq # duplicate package installs can sometimes occur because of cached build failures
}
 
def "ns pkg-config" [lib_filename: string, --include-deps (-i)] {
  nix-locate --minimal -w $"/pkgconfig/($lib_filename)" | lines
    | filter {$include_deps or not ($in | str starts-with "(")}
}

def "pkg-config-exports" []: list<string> -> string {
  (nix-shell --run "echo $PKG_CONFIG_PATH_FOR_TARGET"
    --pure -p pkg-config ...$in)
}

def "input opt-list" [msg: string]: list<any> -> any {(
  if (($in | length) == 1) {$in | get 0}
    else ($in | input list $msg)
)}

def "assert-installed" []: string -> bool {
  if (which $in | is-empty) {
    error make {
      msg: $"($in) is not installed. 'pkg-shell' will not work properly",
      help: $"install ($in)"
    }
  }
}
