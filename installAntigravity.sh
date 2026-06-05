#!/bin/bash
# Instalador Unificado Ultra-Robusto - Antigravity 2.0 e Antigravity IDE
# Deteta automaticamente os ficheiros tar.gz, lê a estrutura interna e instala.
# Inclui correção automática de permissões XDG.

set -e

if [ "$EUID" -ne 0 ]; then
  echo "ERRO: Este script deve ser executado como root (utilize sudo)."
  exit 1
fi

REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
DOWNLOAD_DIR="$USER_HOME/Downloads"
LOCAL_SHARE="$USER_HOME/.local/share"
APPS_DIR="$LOCAL_SHARE/applications"
ICONS_DIR="$LOCAL_SHARE/icons/hicolor/512x512/apps"

fix_sandbox() {
    local sandbox_path="$1"
    if [ -f "$sandbox_path" ]; then
        chown root:root "$sandbox_path"
        chmod 4755 "$sandbox_path"
        echo "[OK] Sandbox SUID configurada em: $sandbox_path"
    else
        echo "[AVISO] Helper da sandbox não encontrado em: $sandbox_path"
    fi
}

echo "=== Iniciando o Instalador Antigravity ==="
echo "Diretório de busca: $DOWNLOAD_DIR"

# Procurar os arquivos tar.gz com suporte a espaços
TAR_20=$(find "$DOWNLOAD_DIR" -maxdepth 1 -type f -iname "*antigravity*.tar.gz" -not -iname "*ide*" | head -n 1)
TAR_IDE=$(find "$DOWNLOAD_DIR" -maxdepth 1 -type f -iname "*antigravity*ide*.tar.gz" -o -iname "*ide*antigravity*.tar.gz" | head -n 1)

# ---- INSTALAÇÃO DO ANTIGRAVITY 2.0 ----
echo ""
echo "--- A configurar o Antigravity 2.0 ---"
if [ -n "$TAR_20" ]; then
    echo "[INFO] Ficheiro do Antigravity 2.0 detetado: $(basename "$TAR_20")"
    
    # Descobrir o nome da pasta raiz dentro do tar.gz
    ROOT_DIR_20=$(tar -tf "$TAR_20" | head -n 1 | cut -d/ -f1)
    echo "[INFO] Pasta interna detetada: $ROOT_DIR_20"
    
    SRC_DIR_20="$DOWNLOAD_DIR/$ROOT_DIR_20"
    
    # Extrair se a pasta ainda não existir
    if [ ! -d "$SRC_DIR_20" ]; then
        echo "A extrair $(basename "$TAR_20")..."
        su - "$REAL_USER" -c "cd \"$DOWNLOAD_DIR\" && tar -xzf \"$TAR_20\""
    fi
    
    TARGET_DIR_20="/opt/antigravity"
    echo "A mover para $TARGET_DIR_20..."
    rm -rf "$TARGET_DIR_20"
    mv "$SRC_DIR_20" "$TARGET_DIR_20"
    
    fix_sandbox "$TARGET_DIR_20/chrome-sandbox"
    
    echo "A extrair o ícone do app.asar via npx..."
    su - "$REAL_USER" -c "cd /tmp && npx --yes asar extract-file $TARGET_DIR_20/resources/app.asar icon.png"
    
    mkdir -p "$ICONS_DIR"
    mv /tmp/icon.png "$ICONS_DIR/antigravity.png"
    chown "$REAL_USER":"$REAL_USER" "$ICONS_DIR/antigravity.png"
    
    echo "A criar a entrada .desktop..."
    mkdir -p "$APPS_DIR"
    cat > "$APPS_DIR/antigravity.desktop" <<EOF
[Desktop Entry]
Name=Antigravity 2.0
Comment=Google Antigravity
Exec=$TARGET_DIR_20/antigravity %U
Terminal=false
Type=Application
Icon=antigravity
Categories=Development;
StartupNotify=true
StartupWMClass=Antigravity
MimeType=x-scheme-handler/antigravity;
EOF
    chown "$REAL_USER":"$REAL_USER" "$APPS_DIR/antigravity.desktop"
    chmod +x "$APPS_DIR/antigravity.desktop"
    echo "[OK] Antigravity 2.0 instalado com sucesso!"
else
    echo "[AVISO] Ficheiro tar.gz do Antigravity 2.0 não encontrado em $DOWNLOAD_DIR."
fi

# ---- INSTALAÇÃO DO ANTIGRAVITY IDE ----
echo ""
echo "--- A configurar o Antigravity IDE ---"
if [ -n "$TAR_IDE" ]; then
    echo "[INFO] Ficheiro do Antigravity IDE detetado: $(basename "$TAR_IDE")"
    
    ROOT_DIR_IDE=$(tar -tf "$TAR_IDE" | head -n 1 | cut -d/ -f1)
    echo "[INFO] Pasta interna detetada: $ROOT_DIR_IDE"
    
    SRC_DIR_IDE="$DOWNLOAD_DIR/$ROOT_DIR_IDE"
    
    if [ ! -d "$SRC_DIR_IDE" ]; then
        echo "A extrair $(basename "$TAR_IDE")..."
        su - "$REAL_USER" -c "cd \"$DOWNLOAD_DIR\" && tar -xzf \"$TAR_IDE\""
    fi
    
    TARGET_DIR_IDE="/opt/antigravity-ide"
    echo "A mover para $TARGET_DIR_IDE..."
    rm -rf "$TARGET_DIR_IDE"
    mv "$SRC_DIR_IDE" "$TARGET_DIR_IDE"
    
    fix_sandbox "$TARGET_DIR_IDE/chrome-sandbox"
    
    echo "A configurar o ícone do IDE..."
    mkdir -p "$ICONS_DIR"
    
    ICON_PATH=""
    if [ -f "$TARGET_DIR_IDE/resources/app/resources/linux/code.png" ]; then
        ICON_PATH="$TARGET_DIR_IDE/resources/app/resources/linux/code.png"
    elif [ -f "$TARGET_DIR_IDE/antigravity-ide/resources/app/resources/linux/code.png" ]; then
        ICON_PATH="$TARGET_DIR_IDE/antigravity-ide/resources/app/resources/linux/code.png"
    fi
    
    if [ -n "$ICON_PATH" ] && [ -f "$ICON_PATH" ]; then
        cp "$ICON_PATH" "$ICONS_DIR/antigravity-ide.png"
        chown "$REAL_USER":"$REAL_USER" "$ICONS_DIR/antigravity-ide.png"
        echo "[OK] Ícone do IDE configurado."
    else
        echo "[AVISO] Não foi possível encontrar o ícone code.png."
    fi
    
    echo "A criar a entrada .desktop..."
    mkdir -p "$APPS_DIR"
    cat > "$APPS_DIR/antigravity-ide.desktop" <<EOF
[Desktop Entry]
Name=Antigravity IDE
Comment=Google Antigravity IDE
Exec=$TARGET_DIR_IDE/antigravity-ide %U
Terminal=false
Type=Application
Icon=antigravity-ide
Categories=Development;IDE;
StartupNotify=true
StartupWMClass=Antigravity-IDE
EOF
    chown "$REAL_USER":"$REAL_USER" "$APPS_DIR/antigravity-ide.desktop"
    chmod +x "$APPS_DIR/antigravity-ide.desktop"
    echo "[OK] Antigravity IDE instalado com sucesso!"
else
    echo "[AVISO] Ficheiro tar.gz do Antigravity IDE não encontrado em $DOWNLOAD_DIR."
fi

echo ""
echo "--- A atualizar a cache do ambiente de trabalho ---"

# Garante que as pastas de ícones locais pertencem ao usuário real,
# evitando o erro de "Permissão negada" ao atualizar o cache do GTK
if [ -d "$LOCAL_SHARE/icons" ]; then
    chown -R "$REAL_USER":"$REAL_USER" "$LOCAL_SHARE/icons"
fi

su - "$REAL_USER" -c "update-desktop-database $APPS_DIR"
su - "$REAL_USER" -c "mkdir -p $LOCAL_SHARE/icons/hicolor && gtk-update-icon-cache -t $LOCAL_SHARE/icons/hicolor || true"

echo ""
echo "=== Processo Concluído! ==="
