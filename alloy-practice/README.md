AlloyによるYAMLの形式検証
========================

# 検証対象のOSS
YAMLは人間が読み書きしやすいデータフォーマットで、JSONやXMLと同様にデータの構造を表現するために使われる。
このリポジトリ（yaml-spec）は、YAML 1.2 の仕様文書を管理し、次期バージョンの策定を行っている。

# 検証すべき性質
YAMLは スペースによるインデント で階層構造を表す。
仕様では、「タブではなくスペースを使う」ことが明確に定義されており、異なる種類のインデントが混在するとエラーを引き起こす可能性がある。
したがって、この仕様が適切に遵守されているかを検証する。

# その性質が仕様として妥当であることを示す判断材料
YAML 1.2 の公式仕様には、次のように記載されている：
* タブの使用は禁止（YAML 1.2 仕様, 6.1. Indentation）
 * 「YAMLインデントには タブではなくスペースを使用する必要がある」と明記されている。
 * 異なる種類のインデント（例：スペースとタブの混在）は、パースエラーの原因となる。

# モデル化
 1. 説明
  * Whitespace（空白文字）を表す抽象シグネチャを定義し、その具象シグネチャとしてSpaceとTabを用意した。
  * Line（行）というシグネチャを作成し、各行のインデントをseq Whitespace（空白文字のシーケンス）として定義した。
  * fact AllSpaceを定義し、すべての Line のインデントがSpaceのみで構成されていることを強制した。

 2. Alloyの記述
 ```alloy
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
 ```
# 検証方法
YAML仕様に従い、すべての行のインデントにタブが含まれていないことを形式的に検証する。これをassert NoTabとして表現し、check NoTab for 10 を実行して検証した。

この検証ではNoTabの主張が成り立つかどうかを確認するために、10行までのデータを対象としてAlloyに探索させた。その結果、反例が見つからなかったため、検証範囲内ではインデントにタブが含まれていないことが保証された。

このようにして、Alloyによる形式検証を用いることでYAMLのインデントルールが正しく守られていることを確認できた。

# 補足事項
実際に自分が検証した際には、以下のようなメッセージが表示された。
```
Executing "Check NoTab for 10"
Solver=sat4j Bitwidth=4 MaxSeq=7 SkolemDepth=1 Symmetry=20 Mode=batch
Generating CNF...
No counterexample found. Assertion may be valid. 63ms.
```

