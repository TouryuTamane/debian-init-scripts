#!/bin/bash
# ==============================================================================
#  Debian / Ubuntu 初期セットアップ統合スクリプト
# ==============================================================================

# 1. root権限チェック
if [ "$(id -u)" -ne 0 ]; then
  echo "[!] ERROR: root権限で実行してください。"
  exit 1
fi

# OSの判別 (debian or ubuntu)
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "[!] OSの判別ができませんでした。"
    exit 1
fi

echo "[*] 対象OS: $OS ($VERSION_CODENAME)"

# ------------------------------------------------------------------------------
# 関数定義
# ------------------------------------------------------------------------------

# --- 1. システム更新 & 基本ツールの導入 ---
setup_base() {
    echo "[*] パッケージ情報の更新と基本ツールの導入中..."
    apt update && apt upgrade -y
    apt install -y curl wget git sudo bash-completion nano less net-tools
}

# --- 2. 日本語化 & タイムゾーン設定 (Asia/Tokyo) ---
setup_japanese() {
    echo "[*] 日本語ロケールおよびタイムゾーン (Asia/Tokyo) の設定中..."
    
    # タイムゾーン変更
    timedatectl set-timezone Asia/Tokyo 2>/dev/null || ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

    # ロケール生成と設定
    apt install -y locales
    if [ "$OS" = "ubuntu" ]; then
        apt install -y language-pack-ja-base language-pack-ja
    elif [ "$OS" = "debian" ]; then
        apt install -y task-japanese
    fi

    # ja_JP.UTF-8 の生成
    sed -i '/^# *ja_JP.UTF-8 UTF-8/s/^# //' /etc/locale.gen
    locale-gen ja_JP.UTF-8

    # デフォルトロケールの適用
    update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
    export LANG=ja_JP.UTF-8
    
    echo "[+] 日本語化が完了しました。"
}

# --- 3. SSH の Root ログイン許可 ---
setup_ssh_root() {
    echo "[*] SSH の Root パスワードログインを許可設定中..."
    if [ -f /etc/ssh/sshd_config ]; then
        # 既存の PermitRootLogin 設定を強制書き換え
        if grep -q "^#\?PermitRootLogin" /etc/ssh/sshd_config; then
            sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
        else
            echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
        fi
        
        # sshd_config.d 以下の設定で上書きされないよう対策
        [ -d /etc/ssh/sshd_config.d ] && echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/00-root-login.conf

        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        echo "[+] SSH Root ログインを許可しました。"
    else
        echo "[!] /etc/ssh/sshd_config が見つかりませんでした (openssh-server 未導入の可能性)。"
    fi
}

# --- 4. 一般ユーザーの追加 & sudo 権限付与 ---
setup_user() {
    local USERNAME=$1
    if [ -z "$USERNAME" ]; then
        read -p "追加するユーザー名を入力してください: " USERNAME
    fi

    if [ -z "$USERNAME" ]; then
        echo "[!] ユーザー名が空です。スキップします。"
        return
    fi

    if id "$USERNAME" &>/dev/null; then
        echo "[*] ユーザー '$USERNAME' は既に存在します。sudo グループの追加のみ行います。"
    else
        echo "[*] ユーザー '$USERNAME' を作成中..."
        adduser --disabled-password --gecos "" "$USERNAME"
        echo "[*] パスワードを設定してください:"
        passwd "$USERNAME"
    fi

    # sudoグループへ追加 (Ubuntu: sudo, Debian: sudo)
    usermod -aG sudo "$USERNAME" 2>/dev/null || gpasswd -a "$USERNAME" sudo
    echo "[+] ユーザー '$USERNAME' に sudo 権限を付与しました。"
}

# ------------------------------------------------------------------------------
# メイン処理 (インタラクティブ / 対話形式)
# ------------------------------------------------------------------------------

echo "=========================================="
echo " Debian / Ubuntu 初期構築スクリプト"
echo "=========================================="
echo "1) 全自動フルセットアップ (更新 + 日本語化 + SSH Root許可 + ユーザー追加)"
echo "2) 日本語化 & タイムゾーン設定のみ"
echo "3) SSH Root ログイン許可のみ"
echo "4) 一般ユーザー追加 (sudo権限) のみ"
echo "0) 終了"
echo "=========================================="
read -p "選択してください [1-4]: " CHOICE

case "$CHOICE" in
    1)
        setup_base
        setup_japanese
        setup_ssh_root
        read -p "追加したい一般ユーザー名 (不要ならEnter): " NEW_USER
        [ -n "$NEW_USER" ] && setup_user "$NEW_USER"
        ;;
    2)
        setup_japanese
        ;;
    3)
        setup_ssh_root
        ;;
    4)
        setup_user
        ;;
    0)
        echo "終了します。"
        exit 0
        ;;
    *)
        echo "無効な選択肢です。"
        exit 1
        ;;
esac

echo "=========================================="
echo "[✓] 処理が完了しました！"
echo "=========================================="