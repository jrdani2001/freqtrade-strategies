#!/bin/bash

###############################################################################
# Hibrid Freqtrade Bot Monitoring Script
#
# Megjeleníti mindkét bot statisztikáit valós időben
#
# Használat:
#   ./monitor_hybrid_bots.sh
###############################################################################

# Színek
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

CRYPTOFROG_API="http://localhost:8080/api/v1"
NFI_API="http://localhost:8081/api/v1"

get_status() {
    local api_url=$1
    curl -s "$api_url/status" 2>/dev/null || echo "[]"
}

get_profit() {
    local api_url=$1
    curl -s "$api_url/profit" 2>/dev/null || echo "{}"
}

get_balance() {
    local api_url=$1
    curl -s "$api_url/balance" 2>/dev/null || echo "{}"
}

display_dashboard() {
    clear

    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          🚀 HIBRID TRADING DASHBOARD 🚀                          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Frissítve: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo ""

    # CryptoFrog Status
    echo -e "${GREEN}━━━ CRYPTOFROG (70%) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    local cf_status=$(get_status "$CRYPTOFROG_API")
    local cf_profit=$(get_profit "$CRYPTOFROG_API")

    if [ "$cf_status" != "[]" ]; then
        echo -e "${CYAN}Timeframe:${NC} 5m"
        echo -e "${CYAN}API:${NC} http://localhost:8080"

        # Parse JSON egyszerűen (jq nélkül)
        local trade_count=$(echo "$cf_status" | grep -o '"trade_id"' | wc -l)
        echo -e "${CYAN}Nyitott trade-ek:${NC} $trade_count"

        # Profit info
        if [ "$cf_profit" != "{}" ]; then
            echo -e "${CYAN}Profit:${NC} $(echo $cf_profit | grep -oP '"profit_all_coin":\K[^,}]+')"
        fi
    else
        echo -e "${RED}⚠ API nem elérhető${NC}"
    fi

    echo ""

    # NFI Status
    echo -e "${MAGENTA}━━━ NFI (30%) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    local nfi_status=$(get_status "$NFI_API")
    local nfi_profit=$(get_profit "$NFI_API")

    if [ "$nfi_status" != "[]" ]; then
        echo -e "${CYAN}Timeframe:${NC} 15m"
        echo -e "${CYAN}API:${NC} http://localhost:8081"

        local trade_count=$(echo "$nfi_status" | grep -o '"trade_id"' | wc -l)
        echo -e "${CYAN}Nyitott trade-ek:${NC} $trade_count"

        if [ "$nfi_profit" != "{}" ]; then
            echo -e "${CYAN}Profit:${NC} $(echo $nfi_profit | grep -oP '"profit_all_coin":\K[^,}]+')"
        fi
    else
        echo -e "${RED}⚠ API nem elérhető${NC}"
    fi

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Gyors parancsok
    echo ""
    echo -e "${YELLOW}Parancsok:${NC}"
    echo "  q - Kilépés"
    echo "  r - Frissítés (auto 5mp)"
    echo "  c - CryptoFrog FreqUI megnyitása"
    echo "  n - NFI FreqUI megnyitása"
    echo ""
}

# Main loop
main() {
    while true; do
        display_dashboard

        # Read input with timeout
        read -t 5 -n 1 key

        case $key in
            q|Q)
                echo "Kilépés..."
                exit 0
                ;;
            r|R)
                continue
                ;;
            c|C)
                xdg-open "http://localhost:8080" 2>/dev/null || \
                open "http://localhost:8080" 2>/dev/null || \
                echo "Nyisd meg: http://localhost:8080"
                ;;
            n|N)
                xdg-open "http://localhost:8081" 2>/dev/null || \
                open "http://localhost:8081" 2>/dev/null || \
                echo "Nyisd meg: http://localhost:8081"
                ;;
        esac
    done
}

# Check dependencies
if ! command -v curl &> /dev/null; then
    echo "curl nem található! Telepítsd: apt-get install curl"
    exit 1
fi

# Start monitoring
main
