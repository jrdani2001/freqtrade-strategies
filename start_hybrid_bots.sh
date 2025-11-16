#!/bin/bash

###############################################################################
# Hibrid Freqtrade Bot Indító Script
#
# Ez a script elindítja a hibrid trading setup-ot:
# - 70% CryptoFrog (mid-cap altcoins, 5m timeframe)
# - 30% NFI (large-cap coins, 15m timeframe)
#
# Használat:
#   ./start_hybrid_bots.sh [dry-run|live] [screen|tmux|systemd]
#
# Példák:
#   ./start_hybrid_bots.sh dry-run screen    # Dry-run mode, screen-ben
#   ./start_hybrid_bots.sh live tmux         # Live mode, tmux-ban
#   ./start_hybrid_bots.sh dry-run systemd   # Systemd service-ként
###############################################################################

set -e  # Exit on error

# Színek a kimenetre
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Konfiguráció
FREQTRADE_ROOT="${FREQTRADE_ROOT:-$HOME/freqtrade_bots}"
CRYPTOFROG_DIR="$FREQTRADE_ROOT/cryptofrog_bot"
NFI_DIR="$FREQTRADE_ROOT/nfi_bot"

# Parancsok
MODE="${1:-dry-run}"  # dry-run vagy live
RUNNER="${2:-screen}" # screen, tmux, vagy systemd

###############################################################################
# Segéd funkciók
###############################################################################

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check_directory() {
    if [ ! -d "$1" ]; then
        print_error "Könyvtár nem található: $1"
        exit 1
    fi
    print_success "Könyvtár OK: $1"
}

check_file() {
    if [ ! -f "$1" ]; then
        print_error "Fájl nem található: $1"
        exit 1
    fi
    print_success "Fájl OK: $(basename $1)"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 nem található! Telepítsd: apt-get install $1"
        exit 1
    fi
}

###############################################################################
# Előfeltételek ellenőrzése
###############################################################################

check_prerequisites() {
    print_header "Előfeltételek Ellenőrzése"

    # Könyvtárak
    check_directory "$CRYPTOFROG_DIR"
    check_directory "$NFI_DIR"

    # Config fájlok
    check_file "$CRYPTOFROG_DIR/config.json"
    check_file "$NFI_DIR/config.json"

    # Stratégiák
    check_file "$CRYPTOFROG_DIR/user_data/strategies/CryptoFrog.py"
    check_file "$NFI_DIR/user_data/strategies/NostalgiaForInfinityNextGen.py"

    # Python virtual env
    check_file "$CRYPTOFROG_DIR/.venv/bin/activate"
    check_file "$NFI_DIR/.venv/bin/activate"

    # Runner dependencies
    if [ "$RUNNER" == "screen" ]; then
        check_command screen
    elif [ "$RUNNER" == "tmux" ]; then
        check_command tmux
    fi

    print_success "Minden előfeltétel teljesült!"
    echo ""
}

###############################################################################
# Mode ellenőrzés (dry-run vs live)
###############################################################################

verify_mode() {
    print_header "Trading Mode: $MODE"

    if [ "$MODE" == "live" ]; then
        print_warning "FIGYELEM: LIVE MODE!"
        echo ""
        echo -e "${RED}Ez valódi pénzzel fog tradingolni!${NC}"
        echo -e "${YELLOW}Biztos vagy benne, hogy folytatod?${NC}"
        echo ""
        read -p "Írd be 'LIVE' a folytatáshoz: " confirmation

        if [ "$confirmation" != "LIVE" ]; then
            print_error "Indítás megszakítva."
            exit 1
        fi

        # Ellenőrizd, hogy a config fájlokban dry_run: false van-e
        if grep -q '"dry_run": true' "$CRYPTOFROG_DIR/config.json"; then
            print_warning "CryptoFrog config még dry_run módban van!"
            print_info "Módosítsd a config.json-t: dry_run: false"
            exit 1
        fi

        if grep -q '"dry_run": true' "$NFI_DIR/config.json"; then
            print_warning "NFI config még dry_run módban van!"
            print_info "Módosítsd a config.json-t: dry_run: false"
            exit 1
        fi

        print_success "Live mode konfiguráció OK"
    else
        print_info "Dry-run mode - Nem történik valódi trading"

        # Ellenőrizd, hogy dry_run: true van-e
        if grep -q '"dry_run": false' "$CRYPTOFROG_DIR/config.json"; then
            print_warning "CryptoFrog config live módban van, de dry-run-t kértél!"
        fi

        if grep -q '"dry_run": false' "$NFI_DIR/config.json"; then
            print_warning "NFI config live módban van, de dry-run-t kértél!"
        fi
    fi

    echo ""
}

###############################################################################
# Stop már futó botokat
###############################################################################

stop_existing_bots() {
    print_header "Meglévő Botok Leállítása"

    if [ "$RUNNER" == "screen" ]; then
        # Állítsd le a screen session-öket
        if screen -list | grep -q "cryptofrog"; then
            print_info "CryptoFrog screen leállítása..."
            screen -S cryptofrog -X quit || true
        fi

        if screen -list | grep -q "nfi"; then
            print_info "NFI screen leállítása..."
            screen -S nfi -X quit || true
        fi

    elif [ "$RUNNER" == "tmux" ]; then
        # Állítsd le a tmux session-öket
        if tmux has-session -t cryptofrog 2>/dev/null; then
            print_info "CryptoFrog tmux leállítása..."
            tmux kill-session -t cryptofrog || true
        fi

        if tmux has-session -t nfi 2>/dev/null; then
            print_info "NFI tmux leállítása..."
            tmux kill-session -t nfi || true
        fi

    elif [ "$RUNNER" == "systemd" ]; then
        # Állítsd le a systemd service-eket
        if systemctl is-active --quiet freqtrade-cryptofrog; then
            print_info "CryptoFrog systemd service leállítása..."
            sudo systemctl stop freqtrade-cryptofrog
        fi

        if systemctl is-active --quiet freqtrade-nfi; then
            print_info "NFI systemd service leállítása..."
            sudo systemctl stop freqtrade-nfi
        fi
    fi

    # Várj egy kicsit
    sleep 2

    print_success "Meglévő botok leállítva (ha voltak)"
    echo ""
}

###############################################################################
# Bot indítás - Screen
###############################################################################

start_with_screen() {
    print_header "Botok Indítása Screen-ben"

    # CryptoFrog
    print_info "CryptoFrog indítása screen session-ben..."
    screen -dmS cryptofrog bash -c "
        cd $CRYPTOFROG_DIR && \
        source .venv/bin/activate && \
        freqtrade trade --config config.json --strategy CryptoFrog
    "
    print_success "CryptoFrog elindult (screen session: cryptofrog)"

    # NFI
    print_info "NFI indítása screen session-ben..."
    screen -dmS nfi bash -c "
        cd $NFI_DIR && \
        source .venv/bin/activate && \
        freqtrade trade --config config.json --strategy NostalgiaForInfinityNextGen
    "
    print_success "NFI elindult (screen session: nfi)"

    echo ""
    print_info "Screen session-ök:"
    screen -ls

    echo ""
    print_info "Csatlakozás:"
    echo "  screen -r cryptofrog   # CryptoFrog"
    echo "  screen -r nfi          # NFI"

    echo ""
    print_info "Leválasztás: Ctrl+A majd D"
}

###############################################################################
# Bot indítás - Tmux
###############################################################################

start_with_tmux() {
    print_header "Botok Indítása Tmux-ban"

    # Hozz létre egy tmux session-t 2 panellel
    print_info "Tmux session létrehozása..."

    tmux new-session -d -s hybrid_trading

    # Első panel: CryptoFrog
    tmux send-keys -t hybrid_trading "cd $CRYPTOFROG_DIR" C-m
    tmux send-keys -t hybrid_trading "source .venv/bin/activate" C-m
    tmux send-keys -t hybrid_trading "freqtrade trade --config config.json --strategy CryptoFrog" C-m
    print_success "CryptoFrog elindult (tmux session: hybrid_trading, panel 0)"

    # Szétválasztás vízszintesen
    tmux split-window -h -t hybrid_trading

    # Második panel: NFI
    tmux send-keys -t hybrid_trading "cd $NFI_DIR" C-m
    tmux send-keys -t hybrid_trading "source .venv/bin/activate" C-m
    tmux send-keys -t hybrid_trading "freqtrade trade --config config.json --strategy NostalgiaForInfinityNextGen" C-m
    print_success "NFI elindult (tmux session: hybrid_trading, panel 1)"

    echo ""
    print_info "Csatlakozás a tmux session-höz:"
    echo "  tmux attach -t hybrid_trading"

    echo ""
    print_info "Panel váltás: Ctrl+B majd →/←"
    print_info "Leválasztás: Ctrl+B majd D"
}

###############################################################################
# Bot indítás - Systemd
###############################################################################

start_with_systemd() {
    print_header "Botok Indítása Systemd-vel"

    print_warning "Systemd service fájlok létrehozása szükséges!"
    print_info "Lásd: HYBRID_STRATEGY_GUIDE.md - Systemd Service rész"

    # Ellenőrizd, hogy léteznek-e a service fájlok
    if [ ! -f "/etc/systemd/system/freqtrade-cryptofrog.service" ]; then
        print_error "freqtrade-cryptofrog.service nem található!"
        print_info "Hozd létre a service fájlt az útmutató szerint."
        exit 1
    fi

    if [ ! -f "/etc/systemd/system/freqtrade-nfi.service" ]; then
        print_error "freqtrade-nfi.service nem található!"
        print_info "Hozd létre a service fájlt az útmutató szerint."
        exit 1
    fi

    # Daemon reload
    print_info "Systemd daemon reload..."
    sudo systemctl daemon-reload

    # Enable & start services
    print_info "CryptoFrog service indítása..."
    sudo systemctl enable freqtrade-cryptofrog
    sudo systemctl start freqtrade-cryptofrog
    print_success "CryptoFrog service elindult"

    print_info "NFI service indítása..."
    sudo systemctl enable freqtrade-nfi
    sudo systemctl start freqtrade-nfi
    print_success "NFI service elindult"

    echo ""
    print_info "Service státuszok:"
    sudo systemctl status freqtrade-cryptofrog --no-pager -l
    echo ""
    sudo systemctl status freqtrade-nfi --no-pager -l

    echo ""
    print_info "Logok:"
    echo "  journalctl -u freqtrade-cryptofrog -f"
    echo "  journalctl -u freqtrade-nfi -f"
}

###############################################################################
# Bot állapot ellenőrzés
###############################################################################

check_bot_status() {
    print_header "Bot Státusz Ellenőrzés"

    sleep 5  # Várj egy kicsit, hogy a botok elinduljanak

    # CryptoFrog
    print_info "CryptoFrog státusz:"
    if curl -s http://localhost:8080/api/v1/ping &>/dev/null; then
        print_success "CryptoFrog API válaszol (port 8080)"
    else
        print_warning "CryptoFrog API nem elérhető (port 8080)"
    fi

    # NFI
    print_info "NFI státusz:"
    if curl -s http://localhost:8081/api/v1/ping &>/dev/null; then
        print_success "NFI API válaszol (port 8081)"
    else
        print_warning "NFI API nem elérhető (port 8081)"
    fi

    echo ""
    print_info "FreqUI linkek:"
    echo "  CryptoFrog: http://localhost:8080"
    echo "  NFI:        http://localhost:8081"
}

###############################################################################
# Összefoglaló
###############################################################################

print_summary() {
    print_header "Hibrid Bot Rendszer Elindítva!"

    echo -e "${GREEN}✓ CryptoFrog Bot${NC}"
    echo "  ├─ Timeframe: 5m"
    echo "  ├─ Pairs: 10 mid-cap altcoins"
    echo "  ├─ Allocation: 70%"
    echo "  ├─ Max Trades: 4"
    echo "  ├─ API: http://localhost:8080"
    echo "  └─ DB: tradesv3_hybrid_cryptofrog.sqlite"

    echo ""
    echo -e "${GREEN}✓ NFI Bot${NC}"
    echo "  ├─ Timeframe: 15m"
    echo "  ├─ Pairs: 6 large-cap coins"
    echo "  ├─ Allocation: 30%"
    echo "  ├─ Max Trades: 3"
    echo "  ├─ API: http://localhost:8081"
    echo "  └─ DB: tradesv3_hybrid_nfi.sqlite"

    echo ""
    print_info "Trading Mode: $MODE"
    print_info "Runner: $RUNNER"

    echo ""
    print_warning "NE FELEDD:"
    echo "  • Rendszeresen ellenőrizd a botokat"
    echo "  • Napi profit/loss review"
    echo "  • Állítsd be a Telegram értesítéseket"
    echo "  • Készíts mentést a DB fájlokról"

    if [ "$MODE" == "live" ]; then
        echo ""
        print_warning "LIVE MODE AKTÍV - Figyeld a valódi trade-eket!"
    fi
}

###############################################################################
# Fő program
###############################################################################

main() {
    clear

    print_header "🚀 Hibrid Freqtrade Bot Indító"
    echo ""

    # Előfeltételek
    check_prerequisites

    # Mode ellenőrzés
    verify_mode

    # Stop meglévő botok
    stop_existing_bots

    # Indítás a választott runner-rel
    case $RUNNER in
        screen)
            start_with_screen
            ;;
        tmux)
            start_with_tmux
            ;;
        systemd)
            start_with_systemd
            ;;
        *)
            print_error "Ismeretlen runner: $RUNNER"
            echo "Használat: $0 [dry-run|live] [screen|tmux|systemd]"
            exit 1
            ;;
    esac

    # Státusz ellenőrzés
    check_bot_status

    # Összefoglaló
    echo ""
    print_summary

    echo ""
    print_success "Sikeres indítás! Boldog tradingot! 🚀📈"
}

# Futtatás
main
