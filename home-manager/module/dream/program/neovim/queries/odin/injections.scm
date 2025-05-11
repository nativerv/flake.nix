; extends

(
  (block_comment) @injection.language
  (string) @injection.content

  (#gsub! @injection.language "/%*%s*([%w%p]+)%s*%*/" "%1")
  (#gsub! @injection.content "^`%s*" "")
  (#gsub! @injection.content "`%s*$" "")

  (#set! injection.combined)
)
