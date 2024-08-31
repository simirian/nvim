hi clear
let g:colors_name="yicks"

lua << EOF

require("yicks").set(({
  "yicks_yellow",
  "yicks_blue",
  -- "yicks_green",
})[vim.fn.rand() % 2 + 1])

EOF
