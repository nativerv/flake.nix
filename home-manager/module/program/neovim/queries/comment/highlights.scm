(_) @spell

((tag
  (name) @text.todo @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#eq? @text.todo "TODO"))

("text" @text.todo @nospell
 (#eq? @text.todo "TODO"))

((tag
  (name) @text.note @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @text.note "NOTE" "XXX" "INFO"))

("text" @text.note @nospell
 (#any-of? @text.note "NOTE" "XXX" "INFO"))

((tag
  (name) @text.warning @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @text.warning "HACK" "WARNING" "SAFETY" "PERF"))

("text" @text.warning @nospell
 (#any-of? @text.warning "HACK" "WARNING" "SAFETY" "PERF"))

((tag
  (name) @text.danger @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @text.danger "FIXME" "BUG" "DANGER"))

("text" @text.danger @nospell
 (#any-of? @text.danger "FIXME" "BUG" "DANGER"))

; Issue number (#123)
("text" @number
 (#lua-match? @number "^#[0-9]+$"))

; User mention (@user)
("text" @constant @nospell
 (#lua-match? @constant "^[@][a-zA-Z0-9_-]+$")
 (#set! "priority" 95))
