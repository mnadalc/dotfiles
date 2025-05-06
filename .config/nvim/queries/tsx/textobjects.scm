;; For selecting outer tag (vat)
((jsx_element) @tag.outer)
((jsx_self_closing_element) @tag.outer)

;; For selecting inside tag (vit)
((jsx_element
  (jsx_opening_element) 
  (jsx_closing_element)) @tag.inner)

((jsx_self_closing_element) @tag.inner)
