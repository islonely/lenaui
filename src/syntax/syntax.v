module syntax

import v_tree_sitter.tree_sitter
import v_tree_sitter.languages.tree_sitter_v as tsv

pub enum Language {
	v
}

[noinit]
pub struct Token {
pub mut:
	@type string
	start u32
	end   u32
}

[params]
pub struct TokenizeParams {
__global:
	// todo: this does nothing right now. Only V is supported.
	language Language
	source   string
}

pub fn tokenize(params TokenizeParams) []Token {
	mut parser := tree_sitter.new_parser[tsv.NodeType](tsv.type_factory)
	parser.set_language(tsv.language)
	tree := parser.parse_string(source: params.source)
	root := tree.root_node()

	return gen_child_tokens[tsv.NodeType](root)
}

fn gen_child_tokens[T](node tree_sitter.Node[T]) []Token {
	mut tokens := []Token{cap: int(node.child_count())}
	for i in u32(0) .. node.child_count() {
		child := node.child(i) or {
			println('node.child(${i}) does not exist.')
			break
		}
		match node.type_name.str() {
			'function_declaration' {
				tokens << Token{
					@type: child.type_name.str()
					start: child.start_byte()
					end: child.end_byte()
				}
				tokens << gen_child_tokens[T](child)
			}
			else {
				tokens << Token{
					@type: child.type_name.str()
					start: child.start_byte()
					end: child.end_byte()
				}
			}
		}
	}
	return tokens
}
