# Nudge toward modern tools for searching/finding/editing. Wrappers always
# exec the real binary (warn, never block). Messages address Claude Code,
# which sources this via its shell snapshot and reads the stderr note in
# tool output.

grep() {
  echo "💡 For Claude: prefer 'rg' over grep — faster, respects .gitignore, also reads stdin" >&2
  command grep "$@"
}

find() {
  echo "💡 For Claude: prefer 'fd' over find — fd -x/-X also covers -exec" >&2
  command find "$@"
}

sed() {
  [[ -t 0 ]] && echo "💡 For Claude: prefer the Edit tool (or 'sd') over sed for editing files" >&2
  command sed "$@"
}
