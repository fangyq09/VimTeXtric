" Vim plugin: Rust run with F2
if exists('b:rust_settings')
	finish
endif
let b:rust_settings = 1

set foldmethod=syntax
set foldnestmax=1
set columns=120
