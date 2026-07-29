# debian-init-scripts

Automated initialization & modern CLI environment (`fzf`, `ripgrep`, `bat`, `fd-find`, `FDclone`) setup scripts for Debian / Ubuntu environments (Bare-metal, VMs, Proxmox LXC containers).

[English](#english) | [日本語](#日本語)

---

## English

### 📦 Included Scripts

#### 1. `init-setup.sh` (OS Initialization)
An interactive script to streamline the initial setup of Debian / Ubuntu:
- **Package Update & Base Tools**: Runs `apt update/upgrade` and installs `curl`, `git`, `sudo`, `nano`, etc.
- **Locale & Timezone**: Configures `Asia/Tokyo` timezone and generates `ja_JP.UTF-8` (Auto-detects Debian vs Ubuntu package differences).
- **SSH Root Login**: Safely enables SSH root password login (`/etc/ssh/sshd_config` and `sshd_config.d/`).
- **User Creation**: Interactively creates a new user with `sudo` privileges.

#### 2. `fzf_fdclone.sh` (CLI Environment & System Update Script)
Installs `fzf` (latest Git build) and `FDclone`, automatically resolving command name conflicts on Ubuntu/Debian (`fd` vs `fdfind`, `bat` vs `batcat`).
- **Protects FDclone Config**: Preserves original `/etc/fdclone/fd2rc.org` safely.
- **Conflict Avoidance**:
  - Sets Rust `fd` as `fdfind` in `fzf` backend to co-exist with `FDclone` (`fd`).
  - Sets `alias bat='batcat'`.
- **System Maintenance Script (`upg`)**:
  - Automatically creates `/usr/local/bin/upg` (skips safely if already exists).
  - One-shot system update and cleanup for `apt`, `snap`, and `flatpak`.

### 🚀 Usage

```bash
# Clone repository
git clone [https://github.com/TouryuTamane/debian-init-scripts.git](https://github.com/TouryuTamane/debian-init-scripts.git)
cd debian-init-scripts
chmod +x *.sh
```

# 1. Run OS initial setup
```bash
sudo ./init-setup.sh
```

# 2. Setup fzf & FDclone environment
```bash
sudo ./fzf_fdclone.sh
source ~/.bashrc
```

# 3. System-wide upgrade & cleanup anytime
```bash
upg
```
## 日本語

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

```

### 1. OS初期セットアップの実行

```bash
sudo ./init-setup.sh

```

画面のメニューに従って処理を選択してください（1番でフルセットアップが実行されます）。

### 2. fzf & FDclone 環境構築の実行

```bash
sudo ./fzf_fdclone.sh
source ~/.bashrc

```

### 3. システムの一括アップデート (`upg`)

セットアップ完了後、いつでも以下のコマンドでシステム全体の更新と掃除を行えます。

```bash
upg

```

---

## 💡 特徴・こだわり

* **高い冪等性 (Idempotency)**: 何度実行しても既存の設定を無駄に破壊しません。
* **環境に配慮した設計**: Proxmox LXC や Minimal インストール直後の環境でもストレスなく極上のCLI環境へ移行できます。

## 📜 ライセンス

[MIT License](https://www.google.com/search?q=LICENSE) (またはお好みのライセンス)

