#!/bin/bash
# ------------------------------------------------------------------
#  fzf (Git最新版) & FDclone (fd2rcカスタム) 統合インストールスクリプト
# ------------------------------------------------------------------

# 1. 権限チェック
if [ "$(id -u)" -ne 0 ]; then
  echo "[!] ERROR: You need to be root."
  exit 1
fi

echo "[*] 1/4: 依存パッケージと周辺便利ツールの導入 (ripgrep, bat, fd-find)..."
if [ -x "$(command -v apt)" ]; then
    apt update && apt install -y git curl ripgrep bat fd-find fdclone tree
else
    echo "[!] Error: apt not found. Support Debian/Ubuntu only."
    exit 1
fi

# 2. FDclone の設定 (/etc/fdclone/fd2rc) の流し込み
echo "[*] 2/4: FDcloneの設定を適用中..."
[ ! -d /etc/fdclone ] && mkdir -p /etc/fdclone

# fd2rc.org がまだ存在せず、fd2rc だけがある場合のみバックアップ（退避）
if [ ! -f /etc/fdclone/fd2rc.org ] && [ -f /etc/fdclone/fd2rc ]; then
    mv /etc/fdclone/fd2rc /etc/fdclone/fd2rc.org
fi

# fd2rc を上書き作成
cat <<'EOF' > /etc/fdclone/fd2rc
# /etc/fdclone/fd2rc: FD用初期化ファイル
#
#  このDebianパッケージでは、サイト固有の設定用に
#  /etc/fdclone/fd2rc.siteconfig を提供しています。
#  スムーズなアップグレードのために、カスタマイズの際はこちらのファイルは
#  変更せず、siteconfigをご利用ください。
#
#  この設定ファイルには、アップストリーム（開発元）のデフォルトとは
#  異なる設定がいくつかあります:
#
#     DISPLAYMODE=3 (シンボリックリンクの状態とファイルタイプ記号を表示)
#     ADJTTY=1 (終了時にTTYを調整)
#     TMPDIR=$HOME   (セキュリティ上の理由)
#     TMPUMASK=077   (同上)
#     LANGUAGE=$LANG
#     INPUTKCODE=$LANG
#     FNAMEKCODE=$LANG
#
#     ランチャー設定
#        .zip, .Z, .gz, .bz2 拡張子のファイル用
#        Debianパッケージ (.deb) および RPMパッケージ (.rpm) 用
#     アーカイバ設定
#        .zip 拡張子のファイル用
#        Debianパッケージ (.deb) および RPMパッケージ (.rpm) 用
#
#     linux console, xterm, kterm 向けのいくつかのキーコード設定
#
#  fdclone は環境変数 PAGER や EDITOR を利用できますが、
#  /etc/fdclone/fd2rc や $HOME/.fd2rc などの設定ファイルによる設定が
#  優先され、その場合環境変数の設定は無視されます。
#  （/etc/fdclone/fd2rc は /etc/fdclone/fd2rc.siteconfig を読み込みます）
#
#  そのため、このパッケージのデフォルト runcom ファイル（つまりこのファイル）では
#  これらの変数をデフォルトで設定していません。
#  PAGER と EDITOR の設定をサイトのデフォルトとして設定したい場合は、
#  /etc/fdclone/fd2rc.siteconfig に以下の2行を記述してください。
#
#    PAGER=/usr/bin/pager%K  (またはお好みのページャー)
#    EDITOR=/usr/bin/editor  (またはお好みのエディタ)
#
#  `%K` はページャー終了時に FD がキー入力を待機することを意味します。
#  これは `more` のような簡単なページャーで役立ちます（指定されたファイルの
#  全内容を表示するとすぐに終了してしまうため）。
#  しかし、`less` や `lv` などを利用する場合、ページャー自体がユーザーに
#  終了を促すため、末尾の `%K` を削除してこの機能を無効化したいと思うでしょう。
#  詳細は `fd` のマニュアルページを参照してください。

# デフォルトのソートタイプの設定
#	0: ソートしない (デフォルト)
#	1: アルファベット順	9: アルファベット逆順
#	2: 拡張子順		10: 拡張子逆順
#	3: サイズ順		11: サイズ逆順
#	4: 日付順		12: 日付逆順
#	5: 長さ順		13: 長さ逆順
#	100-113: 前回のソートタイプを維持
#		(下2桁は初期化直後のみ有効)
SORTTYPE=1

# デフォルトの表示モードの設定
#	0: 通常 (デフォルト)
#	1: シンボリックリンクの状態
#	2: 			ファイルタイプ記号
#	3: シンボリックリンクの状態 &	ファイルタイプ記号
#	4: 						ドットファイル非表示
#	5: シンボリックリンクの状態 &				ドットファイル非表示
#	6: 			ファイルタイプ記号 &	ドットファイル非表示
#	7: シンボリックリンクの状態 &	ファイルタイプ記号 &	ドットファイル非表示
DISPLAYMODE=3

# ツリーモードでソートするかどうか
#	0: ソートしない (デフォルト)
#	>= 1: SORTTYPEに従ってソート
SORTTREE=1

# ファイルシステム上のディレクトリへの上書き動作
#	0: ディレクトリ配置後に上書き確認する (デフォルト)
#	1: 指示された場合のみディレクトリを書き込む
#	2: 指示されてもディレクトリを上書きしない
#WRITEFS=0

# ファイル名比較時に大文字・小文字を無視するかどうか
#	0: 無視しない (デフォルト)
#	>= 1: 無視する
#IGNORECASE=0

# コピー時にタイムスタンプを継承するかどうか
#	0: 継承しない (デフォルト)
#	>= 1: 継承する
INHERITCOPY=1

# ファイルのコピーや移動時に進捗状況を表示します.
PROGRESSBAR=1

# 終了時に tty を調整するかどうか
#	0: 調整しない (デフォルト)
#	>= 1: 調整する
ADJTTY=1

# 端末サイズ取得時に VT100 エスケープシーケンスを優先するかどうか
#	0: 優先しない (デフォルト)
#	>= 1: 優先する
USEGETCURSOR=0

# 1行あたりのファイルのデフォルト列数の設定
#	1: 1列
#	2: 2列 (デフォルト)
#	3: 3列
#	5: 5列
#DEFCOLUMNS=2

# ファイル名フィールドの最小列数
#	デフォルト: 12
#MINFILENAME=12

# 大きなファイルサイズを SI 接頭子 (KB, MB, ...) で表現します.
SIZEUNIT=1

# shモードの履歴ファイル
#	デフォルト: ~/.fd_history
#HISTFILE=~/.fd_history

# shモードの履歴サイズ
#	デフォルト: 50
#HISTSIZE=50

# パス入力の履歴サイズ
#	デフォルト: 50
#DIRHIST=50

# 保存される履歴のサイズ
#	デフォルト: 50
#SAVEHIST=50

# ツリーモードでのディレクトリ内ファイルカウントの上限
#	デフォルト: 50
#DIRCOUNTLIMIT=50

# MS-DOSドライブを有効にするかどうか
#	0: 使用しない (デフォルト)
#	>= 1: 有効にする
#DOSDRIVE=0

# 時計の秒針を表示するかどうか
#	0: 表示しない (デフォルト)
#	>= 1: 表示する
#SECOND=0

# 従来の「FD」に基づいた画面レイアウトを使用するかどうか
#	0: オリジナルレイアウト (デフォルト)
#	>= 1: 従来のレイアウト
#TRADLAYOUT=0

# ファイルサイズの情報を表示するかどうか
#	0: 表示しない (デフォルト)
#	>= 1: 表示する
#SIZEINFO=0

# ANSIカラーエスケープシーケンスをサポートするかどうか
#	0: モノクロ (デフォルト)
#	1: カラー
#	2: カラー & 背景色を強制的に黒にする
#	3: カラー & 前景色を強制的に黒にする
ANSICOLOR=1

# ANSIカラーモードでのカラーパレットの指定
#	デフォルト: なし
#	0: 黒
#	1: 赤
#	2: 緑
#	3: 黄
#	4: 青
#	5: マゼンタ
#	6: シアン
#	7: 白
#	8: 前景色のデフォルトカラー
#	9: 背景色のデフォルトカラー
#	デフォルトパレット: 8962435188
#	                 ||||||||||
#	通常ファイル -------+|||||||||
#	背景色 ------------+||||||||
#	ディレクトリ ---------+|||||||
#	書き込み不可 --------+||||||
#	読み込み不可 ---------+|||||
#	シンボリックリンク ------+||||
#	ソケット ---------------+|||
#	FIFO (名前付きパイプ) ----+||
#	ブロックデバイス ----------+|
#	キャラクタデバイス --------+
#ANSIPALETTE=""

# お好みのエディタタイプで編集モードを選択
#	emacs: ^P, ^N, ^F, ^B, ... (デフォルト)
#	wordstar ^E, ^X, ^D, ^S, ...
#	vi: k, j, l, h, ...
#EDITMODE=emacs

# 同一ページ内でカーソル移動をループさせるかどうか
#	0: ループしない (デフォルト)
#	>= 1: ループする
#LOOPCURSOR=0

# アーカイブファイルが解凍される一時ディレクトリ
#	デフォルト: /tmp
TMPDIR=$HOME

# 一時ディレクトリのファイル作成マスク
#	デフォルト: 022
TMPUMASK=077

# ISO-9660 Rock Ridge フォーマットの CD-ROM マウントポイント
#	デフォルト: なし
#RRPATH=""

# ファイル状態の取得より閲覧を優先するディレクトリ
#	デフォルト: なし
#PRECEDEPATH=""

# シェルのプロンプト文字列
#	デフォルト: "$ "
#PS1="$ "

# シェルの継続プロンプト文字列
#	デフォルト: "> "
#PS2="> "

# 内部シェルで制御シーケンスを使用しないかどうか
#	0: 使用する (デフォルト)
#	>= 1: 使用しない
#DUMBSHELL=0

# メモリ上に UNICODE 変換テーブルを保持するかどうか
#	0: 保持しない (デフォルト)
#	>= 1: 保持する
#UNICODEBUFFER=0

# 表示用の言語コード形式
#	デフォルト: 変換なし
#	euc, EUC: EUC-JP
#	sjis, SJIS: Shift JIS
#	jis, JIS: 7bits JIS
#	jis8, JIS8: 8bits JIS
#	junet, JUNET: ISO-2022-JP
#	ojis, OJIS: 旧 7bits JIS
#	ojis8, OJIS8: 旧 8bits JIS
#	ojunet, OJUNET: 旧 ISO-2022-JP
#	utf8, UTF8: UTF-8
#	utf8-mac, UTF8-MAC: Mac OS X 用 UTF-8
#	eng, ENG, C: 英語
LANGUAGE=$LANG

# 入力用の言語コード形式
#	デフォルト: 変換なし
#	euc, EUC: EUC-JP
#	sjis, SJIS: Shift JIS
#	utf8, UTF8: UTF-8
#	utf8-mac, UTF8-MAC: Mac OS X 用 UTF-8
INPUTKCODE=$LANG

# ファイル名内の言語コード形式
#	デフォルト: 変換なし
#	euc, EUC: EUC-JP
#	sjis, SJIS: Shift JIS
#	jis, JIS: 7bits JIS
#	jis8, JIS8: 8bits JIS
#	junet, JUNET: ISO-2022-JP
#	ojis, OJIS: 旧 7bits JIS
#	ojis8, OJIS8: 旧 8bits JIS
#	ojunet, OJUNET: 旧 ISO-2022-JP
#	hex, HEX: HEX
#	cap, CAP: CAP
#	utf8, UTF8: UTF-8
#	utf8-mac, UTF8-MAC: Mac OS X 用 UTF-8
FNAMEKCODE=$LANG

# ファイル名内の言語コード形式が SJIS であるディレクトリ
#	デフォルト: なし
#SJISPATH=""

# ファイル名内の言語コード形式が EUC-JP であるディレクトリ
#	デフォルト: なし
#EUCPATH=""

# ファイル名内の言語コード形式が 7bits JIS であるディレクトリ
#	デフォルト: なし
#JISPATH=""

# ファイル名内の言語コード形式が 8bits JIS であるディレクトリ
#	デフォルト: なし
#JIS8PATH=""

# ファイル名内の言語コード形式が ISO-2022-JP であるディレクトリ
#	デフォルト: なし
#JUNETPATH=""

# ファイル名内の言語コード形式が旧 7bits JIS であるディレクトリ
#	デフォルト: なし
#OJISPATH=""

# ファイル名内の言語コード形式が旧 8bits JIS であるディレクトリ
#	デフォルト: なし
#OJIS8PATH=""

# ファイル名内の言語コード形式が旧 ISO-2022-JP であるディレクトリ
#	デフォルト: なし
#OJUNETPATH=""

# ファイル名内の言語コード形式が HEX であるディレクトリ
#	デフォルト: なし
#HEXPATH=""

# ファイル名内の言語コード形式が CAP であるディレクトリ
#	デフォルト: なし
#CAPPATH=""

# ファイル名内の言語コード形式が UTF-8 であるディレクトリ
#	デフォルト: なし
#UTF8PATH=""

# ファイル名内の言語コード形式が Mac OS X 用 UTF-8 であるディレクトリ
#	デフォルト: なし
#UTF8MACPATH=""

# ファイル名内の言語コード形式を変換しないディレクトリ
#	デフォルト: なし
#NOCONVPATH=""

#PAGER=more%K
PAGER=/usr/bin/batcat%K
#EDITOR=vi
EDITOR=nano
#SHELL=/bin/sh
SHELL=/bin/bash

# 日本語OSの不具合対策用 (`man fd` を参照)
#export	LANG=C

# ランチャー定義
#(デフォルト)
#launch ".lzh"		"lha l" \
#		-f "%a %u/%g %s %x %m %d %{yt} %*f" \
#		-f "%9a %u/%g %s %x %m %d %{yt} %*f" \
#		-i " PERMSSN * UID*GID *" \
#		-i "----------*" \
#		-i " Total * file* ???.*%*" \
#launch ".tar"		"tar tvf" \
#		-f "%a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %s %y-%m-%d %t %*f" \
#		-f "%a %l %u %g %s %m %d %{yt} %*f" \
#		-f "%10a %u/%g %s %m %d %t %y %*f" \
#		-f "%9a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %m %d %t %y %*f"
#launch ".tar.Z"	"zcat %C|tar tvf -" \
#		-f "%a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %s %y-%m-%d %t %*f" \
#		-f "%a %l %u %g %s %m %d %{yt} %*f" \
#		-f "%10a %u/%g %s %m %d %t %y %*f" \
#		-f "%9a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %m %d %t %y %*f"
#launch ".tar.gz"	"gzip -cd %C|tar tvf -" \
#		-f "%a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %s %y-%m-%d %t %*f" \
#		-f "%a %l %u %g %s %m %d %{yt} %*f" \
#		-f "%10a %u/%g %s %m %d %t %y %*f" \
#		-f "%9a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %m %d %t %y %*f"
#launch ".tar.bz2"	"bzip2 -cd %C|tar tvf -" \
#		-f "%a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %s %y-%m-%d %t %*f" \
#		-f "%a %l %u %g %s %m %d %{yt} %*f" \
#		-f "%10a %u/%g %s %m %d %t %y %*f" \
#		-f "%9a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %m %d %t %y %*f"
#launch ".taZ"		"zcat %C|tar tvf -" \
#		-f "%a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %s %y-%m-%d %t %*f" \
#		-f "%a %l %u %g %s %m %d %{yt} %*f" \
#		-f "%10a %u/%g %s %m %d %t %y %*f" \
#		-f "%9a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %m %d %t %y %*f"
#launch ".taz"		"gzip -cd %C|tar tvf -" \
#		-f "%a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %s %y-%m-%d %t %*f" \
#		-f "%a %l %u %g %s %m %d %{yt} %*f" \
#		-f "%10a %u/%g %s %m %d %t %y %*f" \
#		-f "%9a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %m %d %t %y %*f"
#launch ".tgz"		"gzip -cd %C|tar tvf -" \
#		-f "%a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %s %y-%m-%d %t %*f" \
#		-f "%a %l %u %g %s %m %d %{yt} %*f" \
#		-f "%10a %u/%g %s %m %d %t %y %*f" \
#		-f "%9a %u/%g %s %m %d %t %y %*f" \
#		-f "%a %u/%g %m %d %t %y %*f"
#(例)
launch ".zip"	"unzip -lqq"		" %s %m-%d-%y %t %*f"
#launch ".zoo"	"zoo lq"		" %s %x %x %d %m %y %t %*f"
#launch ".rar"	"unrar v" \
#		-f " %*f\n%s %x %x %d-%m-%y %t %a" \
#		-i "UNRAR *" \
#		-i "RAR *" \
#		-i "Shareware version *" \
#		-i "Verifying authenticity *" \
#		-i "Solid archive *" \
#		-i "Archive *" \
#		-i "Pathname/Comment" \
#		-i "Size * Packed *" \
#		-i "----------*" \
#		-i "* * * ??%" \
#		-i "Old style *" \
#		-i "Archive *.rar" \
#		-i "created at ??:??:?? *" \
#		-i "by * *" \
#		-i ""
launch ".Z"	"zcat %C|$PAGER"
launch ".gz"	"gzip -cd %C|$PAGER"
launch ".bz2"	"bzip2 -cd %C|$PAGER"

# MS-DOS用の例
#launch ".lzh"		"lha v %S" %
#		-f "%*f\n%s %x %x %y-%m-%d %t %a" %
#		-f "%1x %12f %s %x %x %y-%m-%d %t %a" %
#		-i "Listing of archive : *" %
#		-i "  Name          Original *" %
#		-i "--------------*" %
#		-i "* files * ???.?%%%% ??-??-?? ??:??:??" %
#		-i ""
#launch ".tar.Z"	"gzip -cd %S|tar tvf -" %
#		-f "%a %u/%g %s %m %d %t %y %*f" %
#		-f "%a %u/%g %s %y-%m-%d %t %*f" %
#		-f "%a %u/%g %s %m %d %y %t %*f" %
#launch ".tar.gz"	"gzip -cd %S|tar tvf -" %
#		-f "%a %u/%g %s %m %d %t %y %*f" %
#		-f "%a %u/%g %s %y-%m-%d %t %*f" %
#		-f "%a %u/%g %s %m %d %y %t %*f" %
#launch ".tar.bz2"	"bzip2 -cd %S|tar tvf -" %
#		-f "%a %u/%g %s %m %d %t %y %*f" %
#		-f "%a %u/%g %s %y-%m-%d %t %*f" %
#		-f "%a %u/%g %s %m %d %y %t %*f" %
#launch ".taz"		"gzip -cd %S|tar tvf -" %
#		-f "%a %u/%g %s %m %d %t %y %*f" %
#		-f "%a %u/%g %s %y-%m-%d %t %*f" %
#		-f "%a %u/%g %s %m %d %y %t %*f" %
#launch ".tgz"		"gzip -cd %S|tar tvf -" %
#		-f "%a %u/%g %s %m %d %t %y %*f" %
#		-f "%a %u/%g %s %y-%m-%d %t %*f" %
#		-f "%a %u/%g %s %m %d %y %t %*f" %
#launch ".zip"	"unzip -lqq %S"		" %s %y-%m-%d %t %*f"
#launch ".zip"	"pkunzip -vb %S"	" %s %x %x %x %y-%m-%d %t %*f" 14 2

#
# Debian パッケージ設定
launch ".deb" "ar p %C data.tar.gz|gzip -dc|tar tvf - "\
                   "%a %u/%g %s %y-%m-%d %t %f"
launch ".rpm" "rpm2cpio %C|cpio -tv"  "%a %x %u %g %s %m %d %y %f"


# アーカイバ定義
#(デフォルト)
#arch ".lzh"	"lha aq %C %TA"			"lha xq %C %TA"
#arch ".tar"	"tar cf %C %T"			"tar xf %C %TA"
#arch ".tar.Z"	"tar cf - %T|compress -c > %C"	"zcat %C|tar xf - %TA"
#arch ".tar.gz"	"tar cf - %T|gzip -c > %C"	"gzip -cd %C|tar xf - %TA"
#arch ".tar.bz2" \
#		"tar cf - %T|bzip2 -c > %C"	"bzip2 -cd %C|tar xf - %TA"
#arch ".taZ"	"tar cf - %T|compress -c > %C"	"zcat %C|tar xf - %TA"
#arch ".taz"	"tar cf - %T|gzip -c > %C"	"gzip -cd %C|tar xf - %TA"
#arch ".tgz"	"tar cf - %T|gzip -c > %C"	"gzip -cd %C|tar xf - %TA"
#(例)
arch ".zip"	"zip -q %C %TA"			"unzip -q %C %TA"
#arch ".zoo"	"zoo aq %C %TA"			"zoo xq %C %TA"
#arch ".rar"	"rar a -inul %C %TA"		"unrar x -inul %C %TA"

# MS-DOS用の例
#arch ".lzh"	"lha a %S %TA"			"lha x %S %TA"
#arch ".tar.Z"	"tar cf - %T|compress -c > %C"	"gzip -cd %S|tar xf - %TA"
#arch ".tar.gz"	"tar cf - %T|gzip -c > %C"	"gzip -cd %S|tar xf - %TA"
#arch ".tar.bz2" %
#		"tar cf - %T|bzip2 -c > %C"	"bzip2 -cd %S|tar xf - %TA"
#arch ".taz"	"tar cf - %T|compress -c > %C"	"gzip -cd %S|tar xf - %TA"
#arch ".tgz"	"tar cf - %T|gzip -c > %C"	"gzip -cd %S|tar xf - %TA"
#arch ".zip"	"pkzip %S %TA"			"pkunzip %S %TA"

#
# Debian パッケージ設定
arch ".deb"    "clear; echo ERROR; false"\
       "ar p %C data.tar.gz|gzip -dc|tar -xf - %TA"
arch ".rpm"   "clear; echo ERROR; false"      "rpm2cpio %C|cpio -id %TA"

#
#arch xz "xz -T0 -k %T"    "unxz -T0 -kk %C"
arch xz "pxz -k %T"    "pxz -dk %C"
arch gz "gzip -k %T"    "gunzip -dk %C"
#arch gz "pigz -k %T"    "pigz -dk %C"

# キーバインド定義
#(例)
#bind 'I'	"dir -d %C"
#bind 'g'	"gzip %C%K"	WARNING_BELL
#bind 'G'	"gzip -d %C%K"	WARNING_BELL
#bind 'R'	"grep %R %C"
#bind '{'	ROLL_UP
#bind '}'	ROLL_DOWN
#bind '~'	"cd ~%N%K"
#bind 'F1'	"man fd%N%K"	:Manual

# 関数定義
#(例1)
#rename() {
#	MARK_ALL 0
#	MARK_FIND $1
##	RENAME_FILE $2
#	evalmacro mv %M $2
#}
#
#(例2: アーカイバ定義で使用)
#maketaz() {
#	evalmacro tar cf %X.tar %T
#	evalmacro $1 %X.tar
#	evalmacro mv %X.tar.$2 %X.$3
#}
#
#(例3: FTPブラウジング)
#getftp() {
#	FHOST=$1
#	FPATH=
#	browse -@ - <<'EOF0'
#	'ftp -n $FHOST <<-EOF
#	user ftp `whoami`@`hostname`
#	dir $FPATH
#	quit
#	EOF'
#	-f "%a %l %u %g %s %m %d %{yt} %*f"
#	-i "total *"
#	-e "Not connected."
#	-e "Login incorrect."
#	-e "Login failed."
#	-p 'FPATH=$1; while [ "$#" -gt 1 ]; do shift; FPATH=$1/$FPATH; done'
#	-d loop
#
#	'dir=`readline "Dir: "` && [ -d "$dir" ] \
#	&& yesno "copy \"$FPATH\" to \"$dir\" ?" \
#	&& ftp -n $FHOST <<-EOF \
#	&& echo "copy \"$FPATH\" to \"$dir\"." %K \
#	|| echo canceled.
#	user ftp `whoami`@`hostname`
#	get $FPATH $dir/${FPATH##*/}
#	quit
#	EOF'
#EOF0
#}

# MS-DOS ドライブ定義
#(例)
#setdrv B	"/dev/rfd00a"	2, 18, 80

# エイリアス定義
#(例)
#alias dir="ls -laF"

# キーマップ定義
#(例)
#keymap DEL	"\033[3~"

# xterm および kterm 向けの共通キーコード設定
 xtermkey()
  {
	keymap HOME	"\033OH"
	keymap END	"\033OF"
	#keymap INS	"\033[2~"
	#keymap DEL	"\033[3~"
	keymap BS	"\177"
	#keymap PPAGE	"\033[5~"
	#keymap NPAGE	"\033[6~"
	#keymap RET	"\033OM"
	keymap F5	"\033[15~"
	keymap F6	"\033[17~"
	keymap F7	"\033[18~"
	keymap F8	"\033[19~"
	keymap F9	"\033[20~"
	keymap F10	"\033[21~"
	keymap F11	"\033[23~"
	keymap F12	"\033[24~"
	keymap PLUS	"\033Ok"
	keymap MINUS	"\033Om"
	keymap ASTER	"\033Oj"
	keymap SLASH	"\033Oo"
  }

# 各種端末向けのキーコード設定
 case $TERM in
   linux)
	LANGUAGE=eng
	;;
   xterm)
	LANGUAGE=eng
	keymap F1	"\033OP"
	keymap F2	"\033OQ"
	keymap F3	"\033OR"
	keymap F4	"\033OS"
	xtermkey
	;;
   kterm)
	keymap F1	"\033[11~"
	keymap F2	"\033[12~"
	keymap F3	"\033[13~"
	keymap F4	"\033[14~"
	xtermkey
	;;
 esac

unset xtermkey

# サイト固有の設定用
source /etc/fdclone/fd2rc.siteconfig
EOF
chmod 644 /etc/fdclone/fd2rc

# /usr/local/bin/upg が存在しない場合のみファイルを作成する
if [ ! -f /usr/local/bin/upg ]; then
    echo "[*] /usr/local/bin/upg を作成しています..."
    
    cat <<'EOF' > /usr/local/bin/upg
#!/bin/bash
# Check if the user running the script is root
if [ "$(id -u)" -ne 0 ]; then
  if [[ $LANG =~ .*JP.* ]]; then
    echo -e "[\033[0;31m!\033[0;39m] エラー: root権限で実行してください。(sudo ${BASH_SOURCE[0]##*/})"
    exit 1
  else
    echo -e "[\033[0;31m!\033[0;39m] ERROR: You need to be root.(sudo ${BASH_SOURCE[0]##*/})"
    exit 1
  fi
fi
if type apt > /dev/null 2>&1; then
  echo -e "\033[01;34mapt update\033[0;39m"
  apt update
  if [ $? -ne 0 ]; then
    if [[ $LANG =~ .*JP.* ]]; then
      echo -e "[\033[0;31m!\033[0;39m] エラー: ディレクトリ /var/lib/apt/lists/ をロックできません。"
      exit 1
    else
      echo -e "[\033[0;31m!\033[0;39m] ERROR: Unable to lock directory /var/lib/apt/lists/"
      exit 1
    fi
  else
    echo -e "\n\033[01;34mapt -y upgrade\033[0;39m"
    apt -y full-upgrade
    echo -e "\n\033[01;34mapt -y autoremove --purge\033[0;39m"
    apt -y autoremove --purge
    echo -e "\n\033[01;34mCleaning up...\033[0;39m"
    apt clean  # キャッシュ削除を追加
  fi
fi
if type snap > /dev/null 2>&1; then
  echo -e "\n\033[01;34msnap refresh\033[0;39m"
  snap refresh
fi
if type flatpak > /dev/null 2>&1; then
  echo -e "\n\033[01;34mflatpak update\033[0;39m"
  flatpak update
  echo -e "\n\033[01;34mflatpak uninstall --unused\033[0;39m"
  flatpak uninstall --unused
fi
# 最後に一言添える
echo -e "\n\033[01;32m[✓] All updates completed successfully!\033[0;39m"
EOF

    # 作成したスクリプトに実行権限を付与
    chmod +x /usr/local/bin/upg
else
    # 既に存在する場合のスキップメッセージ（不要なら削除してOKです）
    echo "[*] /usr/local/bin/upg は既に存在するため、作成をスキップしました。"
fi

# 3. fzf を Git からルート（または指定ユーザー）環境へクリーンインストール
echo "[*] 3/4: fzf (Git版最新) を取得・ビルド中..."
TARGET_HOME="/root" # コンテナ内のrootを想定（一般ユーザーなら /home/ユーザー名 に変更可）
rm -rf "$TARGET_HOME/.fzf"

# Gitクローンしてインストーラーを非対話（全自動）で実行
git clone --depth 1 https://github.com/junegunn/fzf.git "$TARGET_HOME/.fzf"
"$TARGET_HOME/.fzf/install" --all


# 4. .bashrc への「とほほ式秘伝の環境変数」と衝突回避設定の追記
echo "[*] 4/4: .bashrc へ相棒ツールの連携設定を追記中..."
cat <<'EOF' >> "$TARGET_HOME/.bashrc"

# --- fzf & 相棒ツール連携設定 (とほほ入門MIX版) ---
alias bat='batcat'  # Ubuntuのbatコマンド名対策

# fdコマンドはFDcloneに譲るため、Rust製fdの環境変数にはフルパス（fdfind）を明示指定
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND='fdfind --type f --hidden --exclude .git'
export FZF_ALT_C_COMMAND='fdfind --type d --hidden --exclude .git'

# プレビューウィンドウにbatを連携させてシンタックスハイライト表示
export FZF_CTRL_T_OPTS='--preview="batcat -n --color=always --line-range :120 {}"'
export FZF_ALT_C_OPTS='--preview="tree -C {} | head -120"'

# fzfのデフォルト見た目カスタム（リバースレイアウト＋枠線）
export FZF_DEFAULT_OPTS="--border=rounded --layout=reverse --height=40%"

# --- とほほ式 実用シェルレシピ ---
rgvim() {
  rg --line-number --no-heading --color=always "$*" | fzf --ansi -d : \
    --preview='batcat -n --color=always {1}' --bind='enter:become(vim +{2} {1})'
}

fkill() {
  ps -ef | sed 1d | fzf -m --bind='enter:become(kill -HUP {2})'
}
EOF

echo "[+] すべての工程が完了しました！"
echo "[*] 'source ~/.bashrc' を叩くか、シェルを再起動して極上のCLI環境をお楽しみください！"
