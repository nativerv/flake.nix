;;extends

; conceals - operators
; lambda
(lambda ("\\") @operator (#set! conceal "λ"))
; composition
((operator) @operator (#eq? @operator ".") (#set! conceal "∘")) 

; replacable with ligatures (and asymmetric with my font unfortunately)
;((("->") @conceal) (#set! conceal "🡢"))
;((("<-") @conceal) (#set! conceal "🡠"))
