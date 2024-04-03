# git
alias commit_messages='echo "add: :rocket:"; echo "delete: :x:"; echo "update: :arrow_up:"; echo "rename: :truck:"; echo "feature: :sparkles:"; echo "fix: :adhesive_bandage:";echo "revert: :rewind:"; echo "refactor: :hammer:"; echo "docs: :books:"; echo "style: :art:"; echo "format: :triangular_ruler:"; echo "test: :white_check_mark:"; echo "perf: :racehorse:"; echo "ci: :construction_worker:"; echo "sec: :lock:"; echo "init: first commit :tada:"'
if ! uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/' | /usr/bin/grep -q -i "el5"; then
  function gc-add { git commit -m "add: ${*:-'add file'} :rocket:"; }
  function gc-delete { git commit -m "delete: ${*:-'remove file'} :x:"; }
  function gc-update { git commit -m "update: ${*:-'update file'} :arrow_up:"; }
  function gc-rename { git commit -m "rename: ${*:-'rename file'} :truck:"; }
  function gc-feature { git commit -m "feature: ${*:-'add feature'} :sparkles:"; }
  function gc-fix { git commit -m "fix: ${*:-'fix problem'} :adhesive_bandage:"; }
  function gc-revert { git commit -m "revert: ${*:-'revert'} :rewind:"; }
  function gc-refactor { git commit -m "refector: ${*:-'refector code'} :hammer:"; }
  function gc-docs { git commit -m "docs: ${*:-'improve documentation'} :books:"; }
  function gc-style { git commit -m "style: ${*:-'improve style'} :art:"; }
  function gc-format { git commit -m "format: ${*:-'format code'} :triangular_ruler:"; }
  function gc-test { git commit -m "test: ${*:-'test'} :white_check_mark:"; }
  function gc-perf { git commit -m "perf: ${*:-'improve performance'} :racehorse:"; }
  function gc-ci { git commit -m "ci: ${*:-'improve ci'} :construction_worker:"; }
  function gc-sec { git commit -m "sec: ${*:-'improve security'} :lock:"; }
  function gc-init { git commit --allow-empty -m "init: ${*:-'first commit'} :tada:"; }
fi

# github cli
alias pr-mueller='gh pr create --reviewer bernd-mueller-1 --assignee florian-hild-1,bernd-mueller-1 --fill'
alias pr-scheub='gh pr create --reviewer Manuel-Scheub --assignee florian-hild-1,Manuel-Scheub --fill'
alias pr-woelk='gh pr create --reviewer fabian-woelk-1 --assignee florian-hild-1,fabian-woelk-1 --fill'
alias pr-seggelmann='gh pr create --reviewer robin-seggelmann --assignee florian-hild-1,robin-seggelmann --fill'
alias pr-ansible='gh pr create --reviewer bernd-mueller-1,Manuel-Scheub,fabian-woelk-1 --assignee florian-hild-1,bernd-mueller-1,Manuel-Scheub,fabian-woelk-1 --fill'
