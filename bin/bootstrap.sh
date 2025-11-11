#!/bin/bash

# ============================================================================
# bootstrap.sh - Clona e instala dotfiles
# ============================================================================
# Prerequisitos (ejecutar pre-bootstrap.sh primero):
# - Xcode Command Line Tools
# - Homebrew
# - GitHub CLI (gh) autenticado
#
# Este script:
# - Descubre dinámicamente el usuario de GitHub
# - Clona dotfiles usando HTTPS (no requiere SSH keys)
# - Inicializa submodules
# - Configura logging
# - Ejecuta instalación completa
# - Genera reporte post-mortem
#
# Uso: bash <(curl -fsSL https://raw.githubusercontent.com/alejakun/dotfiles-bootstrap/main/bin/bootstrap.sh)
# ============================================================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Directories
DOTFILES_DIR="$HOME/.dotfiles"
LOG_DIR="$HOME/.dotfiles-install-logs"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}▸${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# ============================================================================
# Prerequisite Checks
# ============================================================================

check_prerequisites() {
    print_header "🔍 Verificando Prerequisitos"

    local missing=0

    # Check Homebrew
    if ! command -v brew &>/dev/null; then
        print_error "Homebrew no instalado"
        ((missing++))
    else
        print_success "Homebrew: $(brew --version | head -n1)"
    fi

    # Check GitHub CLI
    if ! command -v gh &>/dev/null; then
        print_error "GitHub CLI no instalado"
        ((missing++))
    else
        print_success "GitHub CLI: $(gh --version | head -n1)"
    fi

    # Check GitHub authentication
    if ! gh auth status &>/dev/null; then
        print_error "No autenticado con GitHub"
        ((missing++))
    else
        print_success "Autenticado con GitHub"
    fi

    if [[ $missing -gt 0 ]]; then
        echo ""
        print_error "Faltan $missing prerequisito(s)"
        print_info "Ejecuta primero: bash <(curl -fsSL https://raw.githubusercontent.com/alejakun/dotfiles-bootstrap/main/bin/pre-bootstrap.sh)"
        exit 1
    fi

    print_success "Todos los prerequisitos están instalados"
}

# ============================================================================
# Main Script
# ============================================================================

print_header "🚀 Dotfiles Bootstrap"

# Setup logging
mkdir -p "$LOG_DIR"
log "=== Dotfiles Bootstrap Started ==="
log "Timestamp: $(date)"
log "User: $(whoami)"
log "macOS: $(sw_vers -productVersion)"

# Check prerequisites
check_prerequisites

# ============================================================================
# 1. Discover GitHub User
# ============================================================================

print_step "Descubriendo usuario de GitHub..."

GH_USER=$(gh api user --jq '.login' 2>/dev/null || echo "")

if [[ -z "$GH_USER" ]]; then
    print_error "No se pudo obtener usuario de GitHub"
    log "ERROR: Failed to get GitHub user"
    exit 1
fi

print_success "Usuario de GitHub: $GH_USER"
log "GitHub user: $GH_USER"

# ============================================================================
# 2. Clone Dotfiles
# ============================================================================

print_step "Clonando dotfiles..."

if [[ -d "$DOTFILES_DIR" ]]; then
    print_info "El directorio $DOTFILES_DIR ya existe"
    read -p "¿Eliminar y clonar de nuevo? (s/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[SsYy]$ ]]; then
        print_info "Eliminando $DOTFILES_DIR..."
        rm -rf "$DOTFILES_DIR"
        log "Removed existing $DOTFILES_DIR"
    else
        print_info "Usando dotfiles existentes"
        log "Using existing dotfiles"
    fi
fi

if [[ ! -d "$DOTFILES_DIR" ]]; then
    # Clone using HTTPS (no SSH key needed)
    REPO_URL="https://github.com/${GH_USER}/dotfiles.git"

    print_info "Clonando desde: $REPO_URL"
    log "Cloning from: $REPO_URL"

    # Configure gh as credential helper for HTTPS (before cloning)
    print_info "Configurando autenticación GitHub para HTTPS..."
    git config --global credential.helper ""
    git config --global --add credential.helper "!gh auth git-credential"
    log "Configured gh as git credential helper"

    if gh repo clone "${GH_USER}/dotfiles" "$DOTFILES_DIR" -- --recurse-submodules; then
        print_success "Dotfiles clonados correctamente"
        log "SUCCESS: Dotfiles cloned"
    else
        print_error "Error clonando dotfiles"
        log "ERROR: Failed to clone dotfiles"
        exit 1
    fi
else
    print_info "Actualizando submodules..."
    cd "$DOTFILES_DIR"
    if git submodule update --init --recursive; then
        print_success "Submodules actualizados"
        log "SUCCESS: Submodules updated"
    else
        print_error "Error actualizando submodules"
        log "ERROR: Failed to update submodules"
    fi
fi

# ============================================================================
# 3. Run Installation
# ============================================================================

print_step "Ejecutando instalación completa..."

cd "$DOTFILES_DIR"

if [[ ! -f "bin/install.sh" ]]; then
    print_error "No se encontró bin/install.sh"
    log "ERROR: bin/install.sh not found"
    exit 1
fi

log "Running: bin/install.sh --all"
print_info "Ejecutando: bin/install.sh --all"
print_info "Logs en: $LOG_FILE"
echo ""

# Run install.sh and capture output
if bash bin/install.sh --all 2>&1 | tee -a "$LOG_FILE"; then
    print_success "Instalación completada"
    log "SUCCESS: Installation completed"
else
    print_error "Instalación completada con errores (verifica el log)"
    log "WARNING: Installation completed with errors"
fi

# ============================================================================
# 4. Generate Post-Mortem Report
# ============================================================================

print_header "📊 Reporte de Instalación"

REPORT_FILE="$LOG_DIR/report-$(date +%Y%m%d-%H%M%S).md"

cat > "$REPORT_FILE" << EOF
# Reporte de Instalación - Dotfiles

**Fecha:** $(date)
**Usuario:** $(whoami)
**macOS:** $(sw_vers -productVersion)
**GitHub User:** $GH_USER

---

## Resumen

\`\`\`
$(tail -n 50 "$LOG_FILE")
\`\`\`

---

## Logs Completos

Ver: $LOG_FILE

---

## Verificaciones Post-Instalación

### Shell Configurado
\`\`\`bash
echo \$SHELL
# Debería ser: /bin/zsh o /opt/homebrew/bin/fish
\`\`\`

### Variables de Ambiente
\`\`\`bash
env | grep -E '(DOTFILES|XDG)'
\`\`\`

### Aplicaciones Homebrew
\`\`\`bash
brew list
brew list --cask
\`\`\`

### Symlinks Verificación
\`\`\`bash
ls -la ~/.config/
ls -la ~/.ssh/
\`\`\`

---

## Siguientes Pasos

1. **Reiniciar terminal** para aplicar configuraciones de shell
2. **Verificar symlinks** funcionan correctamente
3. **Configurar aplicaciones manuales** (si no fueron instaladas)
4. **Revisar logs** para cualquier error: \`$LOG_FILE\`

---

**Generado por:** dotfiles-bootstrap
EOF

print_success "Reporte generado: $REPORT_FILE"
log "Report generated: $REPORT_FILE"

# ============================================================================
# 5. Summary
# ============================================================================

print_header "✅ Bootstrap Completado"

echo -e "${GREEN}Instalación completada correctamente${NC}"
echo ""
echo -e "📁 Dotfiles: ${CYAN}$DOTFILES_DIR${NC}"
echo -e "📋 Logs: ${CYAN}$LOG_FILE${NC}"
echo -e "📊 Reporte: ${CYAN}$REPORT_FILE${NC}"
echo ""

print_info "Siguiente paso: Reinicia tu terminal"
echo ""

# Ask to open report
read -p "¿Abrir reporte ahora? (s/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[SsYy]$ ]]; then
    if command -v bat &>/dev/null; then
        bat "$REPORT_FILE"
    elif command -v less &>/dev/null; then
        less "$REPORT_FILE"
    else
        cat "$REPORT_FILE"
    fi
fi

log "=== Bootstrap Completed ==="

print_success "¡Todo listo!"
