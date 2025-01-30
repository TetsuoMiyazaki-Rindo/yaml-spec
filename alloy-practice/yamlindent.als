module yamlindent

abstract sig Whitespace {} // 空白文字の抽象シグネチャ
one sig Space extends Whitespace {}  // スペース
one sig Tab extends Whitespace {}    // タブ（使用禁止）

sig Line { 
  indent: seq Whitespace  // 各行のインデントは空白文字の並び
}

// インデントはすべてスペースでなければならない
fact AllSpace {
  all l: Line, i: Int | i >= 0 and i < #l.indent => l.indent[i] = Space
}

// タブが含まれていないことを検証
assert NoTab { 
  all l: Line, i: Int | i >= 0 and i < #l.indent => l.indent[i] != Tab
} 

check NoTab for 10
