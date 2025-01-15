# git

if ! uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/' | command grep -q -i "el5"; then
  function gc-fix {      git commit -m "fix${*:-': fix problem'}"; }
  function gc-feature {  git commit -m "feat${*:-': add feature'}"; }
  function gc-build {    git commit -m "build${*:-': improve build'}"; }
  function gc-chore {    git commit -m "chore${*:-': update)'}"; }
  function gc-docs {     git commit -m "docs${*:-': improve documentation'}"; }
  function gc-style {    git commit -m "style${*:-': improve style'}"; }
  function gc-refactor { git commit -m "refector${*:-': refector code'}"; }
  function gc-perf {     git commit -m "perf${*:-': improve performance'}"; }
  function gc-test {     git commit -m "test${*:-': test'}"; }
  function gc-revert {   git commit -m "revert${*:-': revert changes'}"; }
  function gc-delete {   git commit -m "delete${*:-': remove file'}"; }
  function gc-init {     git commit --allow-empty -m "init${*:-': first commit'}"; }
fi
