; extends

(
  (element
    (start_tag
      (tag_name) @tag
    )
  ) @fold
  (#eq? @tag "details")
)
