#!/bin/bash

###############################################################################
# Hibrid Freqtrade Bot Leállító Script
#
# Használat:
#   ./stop_hybrid_bots.sh [screen|tmux|systemd|all]
#
# Példák:
#   ./stop_hybrid_bots.sh screen    # Csak screen session-ök
#   ./stop_hybrid_bots.sh all       # Minden bot
###############################################################################

set -e

# Színek
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

RUNNER="${1:-all}"

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

stop_screen() {
    print_header "Screen Session-ök Leállítása"

    if screen -list | grep -q "cryptofrog"; then
        print_info "CryptoFrog screen leállítása..."
        screen -S cryptofrog -X quit
        print_success "CryptoFrog screen leállítva"
    else
        print_info "CryptoFrog screen nem fut"
    fi

    if screen -list | grep -q "nfi"; then
        print_info "NFI screen leállítása..."
        screen -S nfi -X quit
        print_success "NFI screen leállítva"
    else
        print_info "NFI screen nem fut"
    fi

    echo ""
}

stop_tmux() {
    print_header "Tmux Session-ök Leállítása"

    if tmux has-session -t cryptofrog 2>/dev/null; then
        print_info "CryptoFrog tmux leállítása..."
        tmux kill-session -t cryptofrog
        print_success "CryptoFrog tmux leállítva"
    else
        print_info "CryptoFrog tmux nem fut"
    fi

    if tmux has-session -t nfi 2>/dev/null; then
        print_info "NFI tmux leállítása..."
        tmux kill-session -t nfi
        print_success "NFI tmux leállítva"
    else
        print_info "NFI tmux nem fut"
    fi

    if tmux has-session -t hybrid_trading 2>/dev/null; then
        print_info "Hybrid trading tmux leállítása..."
        tmux kill-session -t hybrid_trading
        print_success "Hybrid trading tmux leállítva"
    else
        print_info "Hybrid trading tmux nem fut"
    fi

    echo ""
}

stop_systemd() {
    print_header "Systemd Service-ek Leállítása"

    if systemctl is-active --quiet freqtrade-cryptofrog 2>/dev/null; then
        print_info "CryptoFrog service leállítása..."
        sudo systemctl stop freqtrade-cryptofrog
        print_success "CryptoFrog service leállítva"
    else
        print_info "CryptoFrog service nem fut"
    fi

    if systemctl is-active --quiet freqtrade-nfi 2>/dev/null; then
        print_info "NFI service leállítása..."
        sudo systemctl stop freqtrade-nfi
        print_success "NFI service leállítva"
    else
        print_info "NFI service nem fut"
    fi

    echo ""
}

stop_all() {
    print_header "Minden Bot Leállítása"

    stop_screen
    stop_tmux
    stop_systemd

    # Végső ellenőrzés - kill minden freqtrade folyamatot
    if pgrep -f "freqtrade trade" > /dev/null; then
        print_warning "Még futnak freqtrade folyamatok, force kill..."
        pkill -f "freqtrade trade" || true
        sleep 2
        print_success "Freqtrade folyamatok leállítva"
    fi
}

main() {
    print_header "🛑 Hibrid Bot Leállító"
    echo ""

    case $RUNNER in
        screen)
            stop_screen
            ;;
        tmux)
            stop_tmux
            ;;
        systemd)
            stop_systemd
            ;;
        all)
            stop_all
            ;;
        *)
            echo "Használat: $0 [screen|tmux|systemd|all]"
            exit 1
            ;;
    esac

    print_success "Leállítás kész!"

    # Ellenőrzés
    echo ""
    print_info "Futó freqtrade folyamatok:"
    pgrep -af freqtrade || echo "  Nincs"

    echo ""
    print_info "API portok:"
    lsof -i :8080 2>/dev/null || echo "  Port 8080 szabad"
    lsof -i :8081 2>/dev/null || echo "  Port 8081 szabad"
}

main
