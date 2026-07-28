# debian-init-scripts

Debian / Ubuntu 環境（実機、VM、Proxmox LXCコンテナ等）の初期セットアップおよび、モダンCLI（`fzf`, `ripgrep`, `bat`, `fd-find`）と伝統のファイラー `FDclone` を最高に共存させる統合セットアップスクリプト群です。

> 🤖 **Note / 免責事項**
> 本リポジトリに含まれるシェルスクリプトおよび本READMEは、**AI (Google Gemini)** との対話・協働によって生成・最適化されたものです。

---

## 📦 収録スクリプト

### 1. `init-setup.sh` (初期環境構築スクリプト)
Debian / Ubuntu の初期構築で必要な処理をまとめた対話型インタラクティブスクリプトです。
- **パッケージ更新 & 基本ツール導入**: `apt update/upgrade` および `curl`, `git`, `sudo`, `nano` 等の導入
- **日本語化 & タイムゾーン設定**: `Asia/Tokyo` への変更と `ja_JP.UTF-8` ロケール生成（Debian/Ubuntuの差分を自動判別）
- **SSH Root ログイン許可**: `/etc/ssh/sshd_config` および `sshd_config.d/` を安全に書き換え
- **一般ユーザー追加**: `sudo` 権限を付与したユーザーの対話的作成

### 2. `fzf_fdclone.sh` (CLI環境構築 & パッケージ一括更新スクリプト)
`fzf` (Git最新版) と `FDclone` を導入し、Ubuntu/Debian特有の**コマンド名衝突（`fd` と `bat`）を安全に回避**しながら `.bashrc` へ最適なエイリアス・プレビュー設定を追記します。
- **FDclone設定の保護**: 既存の `/etc/fdclone/fd2rc.org` を自動退避してオリジナルの英語設定を安全に維持
- **名前衝突対策**:
  - Rust製 `fd` は `fdfind` として `fzf` の検索バックエンドに明示指定し、`FDclone` (`fd`) と共存
  - `bat` コマンドは `batcat` へ自動エイリアス設定
- **一括メンテナンスツール `upg` の自動作成**:
  - `/usr/local/bin/upg` を生成（既に存在する場合は安全にスキップ）
  - `apt`, `snap`, `flatpak` の更新から `autoremove`, `clean` までの後片付けを一括実行

---

## 🚀 使い方 (Usage)

### リポジトリの取得
```bash
git clone [https://github.com/TouryuTamane/debian-init-scripts.git](https://github.com/TouryuTamane/debian-init-scripts.git)
cd debian-init-scripts
chmod +x *.sh
