#!/bin/bash

# ============================================================================
# pre-bootstrap.sh - Prerequisitos para instalación de dotfiles
# ============================================================================
# Instala herramientas mínimas necesarias antes de clonar dotfiles:
# - Xcode Command Line Tools
# - Homebrew
# - GitHub CLI (gh)
# - Autenticación con GitHub
#
# Uso: bash <(curl -fsSL https://raw.githubusercontent.com/alejakun/dotfiles-bootstrap/main/bin/pre-bootstrap.sh)
# ============================================================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

# ============================================================================
# Main Script
# ============================================================================

print_header "🚀 Dotfiles Pre-Bootstrap"

print_info "Este script instalará los prerequisitos mínimos para clonar y configurar dotfiles"
echo ""

# ============================================================================
# 1. Check macOS version
# ============================================================================

print_step "Verificando macOS..."

if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "Este script solo funciona en macOS"
    exit 1
fi

macos_version=$(sw_vers -productVersion)
print_success "macOS ${macos_version} detectado"

# ============================================================================
# 2. Install Xcode Command Line Tools
# ============================================================================

print_step "Verificando Xcode Command Line Tools..."

if xcode-select -p &>/dev/null; then
    print_success "Xcode CLI Tools ya instalado"
else
    print_info "Instalando Xcode Command Line Tools (esto puede tardar varios minutos)..."
    xcode-select --install

    print_info "Presiona Enter después de completar la instalación en la ventana emergente..."
    read -r

    if xcode-select -p &>/dev/null; then
        print_success "Xcode CLI Tools instalado correctamente"
    else
        print_error "Error instalando Xcode CLI Tools"
        exit 1
    fi
fi

# ============================================================================
# 3. Install Homebrew
# ============================================================================

print_step "Verificando Homebrew..."

if command -v brew &>/dev/null; then
    print_success "Homebrew ya instalado ($(brew --version | head -n1))"
else
    print_info "Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    if command -v brew &>/dev/null; then
        print_success "Homebrew instalado correctamente"
    else
        print_error "Error instalando Homebrew"
        exit 1
    fi
fi

# ============================================================================
# 4. Install GitHub CLI
# ============================================================================

print_step "Verificando GitHub CLI..."

if command -v gh &>/dev/null; then
    print_success "GitHub CLI ya instalado ($(gh --version | head -n1))"
else
    print_info "Instalando GitHub CLI..."
    brew install gh

    if command -v gh &>/dev/null; then
        print_success "GitHub CLI instalado correctamente"
    else
        print_error "Error instalando GitHub CLI"
        exit 1
    fi
fi

# ============================================================================
# 5. Authenticate with GitHub
# ============================================================================

print_step "Verificando autenticación con GitHub..."

if gh auth status &>/dev/null; then
    print_success "Ya autenticado con GitHub"
    gh auth status
else
    print_info "Iniciando autenticación con GitHub..."
    print_info "Se abrirá tu navegador para autenticar"
    echo ""

    gh auth login -h github.com -p https -w

    if gh auth status &>/dev/null; then
        print_success "Autenticado con GitHub correctamente"
    else
        print_error "Error autenticando con GitHub"
        exit 1
    fi
fi

# ============================================================================
# 6. Configure Git User (Dynamic Discovery)
# ============================================================================

print_step "Configurando usuario de Git..."

# Get GitHub username
gh_user=$(gh api user --jq '.login' 2>/dev/null || echo "")
gh_name=$(gh api user --jq '.name' 2>/dev/null || echo "")
gh_email=$(gh api user --jq '.email' 2>/dev/null || echo "")

if [[ -z "$gh_email" ]] || [[ "$gh_email" == "null" ]]; then
    # Try to get private email from GitHub settings
    gh_id=$(gh api user --jq '.id' 2>/dev/null || echo "")
    if [[ -n "$gh_id" ]] && [[ "$gh_id" != "null" ]]; then
        gh_email="${gh_id}+${gh_user}@users.noreply.github.com"
        print_info "Usando GitHub private email: ${gh_email}"
    fi
fi

# Configure git if we have name and email
if [[ -n "$gh_name" ]] && [[ "$gh_name" != "null" ]] && [[ -n "$gh_email" ]] && [[ "$gh_email" != "null" ]]; then
    git config --global user.name "$gh_name"
    git config --global user.email "$gh_email"
    print_success "Git configurado: ${gh_name} <${gh_email}>"
else
    print_info "No se pudo obtener información de usuario de GitHub"
    print_info "Configura manualmente después: git config --global user.name / user.email"
fi

# ============================================================================
# 7. Summary and Next Steps
# ============================================================================

print_header "✅ Pre-Bootstrap Completado"

echo -e "Prerequisitos instalados correctamente:"
echo -e "  ${GREEN}✓${NC} Xcode Command Line Tools"
echo -e "  ${GREEN}✓${NC} Homebrew $(brew --version | head -n1)"
echo -e "  ${GREEN}✓${NC} GitHub CLI $(gh --version | head -n1)"
echo -e "  ${GREEN}✓${NC} Autenticación con GitHub"
if [[ -n "$gh_email" ]] && [[ "$gh_email" != "null" ]]; then
    echo -e "  ${GREEN}✓${NC} Git configurado: ${gh_name} <${gh_email}>"
fi
echo ""

print_info "Siguiente paso: Ejecutar bootstrap para clonar e instalar dotfiles"
echo ""
echo -e "${CYAN}Opciones:${NC}"
echo ""
echo -e "  ${YELLOW}A)${NC} Ejecutar bootstrap automáticamente ahora"
echo -e "  ${YELLOW}B)${NC} Ejecutar bootstrap manualmente después"
echo ""
read -p "Elige una opción (A/B): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Aa]$ ]]; then
    print_info "Descargando y ejecutando bootstrap..."
    bash <(curl -fsSL https://raw.githubusercontent.com/alejakun/dotfiles-bootstrap/main/bin/bootstrap.sh)
else
    print_info "Para ejecutar bootstrap manualmente:"
    echo ""
    echo -e "  ${CYAN}bash <(curl -fsSL https://raw.githubusercontent.com/alejakun/dotfiles-bootstrap/main/bin/bootstrap.sh)${NC}"
    echo ""
fi

print_success "¡Listo!"
