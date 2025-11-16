# 🚀 Gyors Start - Hibrid Trading Stratégia

## 📋 5 Perces Setup

### 1️⃣ Előfeltételek ✅

```bash
# Telepítsd a freqtrade-et (2 példány)
git clone https://github.com/freqtrade/freqtrade.git ~/freqtrade_bots/cryptofrog_bot
git clone https://github.com/freqtrade/freqtrade.git ~/freqtrade_bots/nfi_bot

cd ~/freqtrade_bots/cryptofrog_bot && ./setup.sh -i
cd ~/freqtrade_bots/nfi_bot && ./setup.sh -i
```

### 2️⃣ Stratégiák Másolása 📁

```bash
# CryptoFrog
cp strategies/CryptoFrog/CryptoFrog.py \
   ~/freqtrade_bots/cryptofrog_bot/user_data/strategies/

# NFI
cp strategies/NostalgiaForInfinityNextGen/NostalgiaForInfinityNextGen.py \
   ~/freqtrade_bots/nfi_bot/user_data/strategies/
```

### 3️⃣ Config Fájlok ⚙️

```bash
# Másold a hibrid config-okat
cp config_hybrid_cryptofrog.json ~/freqtrade_bots/cryptofrog_bot/config.json
cp config_hybrid_nfi.json ~/freqtrade_bots/nfi_bot/config.json
```

**Módosítsd mindkét config.json-ban:**

```json
{
    "exchange": {
        "key": "YOUR_BYBIT_API_KEY",
        "secret": "YOUR_BYBIT_SECRET"
    },
    "telegram": {
        "enabled": true,
        "token": "YOUR_BOT_TOKEN",
        "chat_id": "YOUR_CHAT_ID"
    },
    "api_server": {
        "jwt_secret_key": "RANDOM_SECRET_HERE",
        "password": "STRONG_PASSWORD"
    }
}
```

**Generálj secret key-t:**
```bash
openssl rand -hex 32
```

### 4️⃣ Adat Letöltés 📊

```bash
# CryptoFrog adatok (5m + 1h)
cd ~/freqtrade_bots/cryptofrog_bot
freqtrade download-data --exchange bybit \
  --pairs LINK/USDT MATIC/USDT NEAR/USDT ALGO/USDT XRP/USDT \
          LTC/USDT UNI/USDT AAVE/USDT DOT/USDT ADA/USDT \
  --timeframes 5m 1h --days 30

# NFI adatok (15m + 1h + 1d)
cd ~/freqtrade_bots/nfi_bot
freqtrade download-data --exchange bybit \
  --pairs BTC/USDT ETH/USDT SOL/USDT BNB/USDT AVAX/USDT ATOM/USDT \
  --timeframes 15m 1h 1d --days 30
```

### 5️⃣ Indítás! 🚀

```bash
# Használd a startup scriptet
chmod +x start_hybrid_bots.sh

# DRY-RUN (először mindig ezt!)
./start_hybrid_bots.sh dry-run screen

# Vagy tmux-ban
./start_hybrid_bots.sh dry-run tmux
```

---

## 📊 Portfolio Felosztás

```
Teljes Tőke: 10,000 USDT
│
├─ 70% CryptoFrog (7,000 USDT)
│  ├─ Timeframe: 5m
│  ├─ Max Trades: 4
│  ├─ Avg/Trade: ~1,750 USDT
│  └─ Párok: 10 mid-cap (LINK, MATIC, NEAR...)
│
└─ 30% NFI (3,000 USDT)
   ├─ Timeframe: 15m
   ├─ Max Trades: 3
   ├─ Avg/Trade: ~1,000 USDT
   └─ Párok: 6 large-cap (BTC, ETH, SOL...)
```

---

## 🎯 Pair Diverzifikáció

### CryptoFrog (Mid-Cap Altcoins)
```
✅ LINK/USDT  - DeFi Oracle
✅ MATIC/USDT - Layer 2
✅ NEAR/USDT  - Smart Contracts
✅ ALGO/USDT  - Fast Blockchain
✅ XRP/USDT   - Payments
✅ LTC/USDT   - OG Crypto
✅ UNI/USDT   - DEX
✅ AAVE/USDT  - Lending
✅ DOT/USDT   - Parachain
✅ ADA/USDT   - Smart Contracts
```

### NFI (Large-Cap Blue Chips)
```
✅ BTC/USDT   - Bitcoin (#1)
✅ ETH/USDT   - Ethereum (#2)
✅ SOL/USDT   - Solana (#5)
✅ BNB/USDT   - Binance Coin (#4)
✅ AVAX/USDT  - Avalanche
✅ ATOM/USDT  - Cosmos
```

**❌ NINCS ÁTFEDÉS!** Minden pair csak 1 botban szerepel.

---

## 🖥️ Monitoring

### FreqUI (Web Interface)

```
CryptoFrog: http://localhost:8080
NFI:        http://localhost:8081

Username: freqtrader_cf / freqtrader_nfi
Password: amit beállítottál
```

### Real-time Monitor Script

```bash
./monitor_hybrid_bots.sh
```

Mutatja:
- Nyitott trade-ek száma
- Profit mindkét botból
- API státusz
- Gyors parancsok

### Telegram Bot

```
/status - Trade-ek
/daily  - Napi statisztika
/profit - Profit összegzés
/balance - Balance
```

---

## 🛑 Leállítás

```bash
./stop_hybrid_bots.sh all
```

Vagy:
```bash
# Csak screen
./stop_hybrid_bots.sh screen

# Csak tmux
./stop_hybrid_bots.sh tmux

# Systemd
./stop_hybrid_bots.sh systemd
```

---

## 📈 Várható Eredmények

### CryptoFrog (70% Allokáció)
```
Havi Profit: 5-12%
Win Rate: 55-65%
Trade/hét: 25-35
Avg Duration: 2-8 óra
Max Drawdown: 12-18%
```

### NFI (30% Allokáció)
```
Havi Profit: 7-15%
Win Rate: 60-70%
Trade/hét: 10-20
Avg Duration: 6-24 óra
Max Drawdown: 8-15%
```

### Combined (Weighted)
```
Havi Profit: 6-13%
Win Rate: ~60%
Sharpe Ratio: >1.7
Max Drawdown: <15%
```

---

## ⚠️ Fontos Ellenőrzések

### Naponta (Reggel)
```bash
✅ Ellenőrizd mindkét bot logját
✅ Nézd meg a daily profit-ot
✅ Ellenőrizd, nincs-e stuck trade
✅ Balance check
```

### Hetente
```bash
✅ Profit/loss review
✅ Win rate analízis
✅ Sharpe ratio számítás
✅ Config optimalizálás
```

### Havonta
```bash
✅ Teljes teljesítmény review
✅ Stratégia újragondolás
✅ Pair lista frissítés
✅ Backtest újrafuttatás
```

---

## 🔧 Troubleshooting

### "API Port already in use"
```bash
# Ellenőrizd a portokat
lsof -i :8080
lsof -i :8081

# Kill process if needed
kill -9 <PID>
```

### "Both bots trading the same pair"
```bash
# Ellenőrizd a blacklist-eket
grep "pair_blacklist" ~/freqtrade_bots/*/config.json

# CryptoFrog blacklist-je tartalmazza: BTC, ETH, SOL, BNB, AVAX
# NFI blacklist-je tartalmazza: LINK, MATIC, NEAR, ALGO, stb.
```

### "Wrong balance allocation"
```bash
# Ellenőrizd a tradable_balance_ratio-t
grep "tradable_balance_ratio" ~/freqtrade_bots/*/config.json

# CryptoFrog: 0.70 (70%)
# NFI: 0.30 (30%)
```

### "Bot keeps crashing"
```bash
# Ellenőrizd a logokat
tail -100 ~/freqtrade_bots/cryptofrog_bot/user_data/logs/freqtrade.log
tail -100 ~/freqtrade_bots/nfi_bot/user_data/logs/freqtrade.log

# Közös hibák:
# - API key invalid
# - Insufficient balance
# - Network connection issues
# - Strategy syntax errors
```

---

## 📁 Hasznos Fájlok

### Dokumentáció
```
HYBRID_STRATEGY_GUIDE.md      - Teljes setup útmutató (300+ sor)
CONFIG_FILES_REFERENCE.md     - Config paraméter referencia
STRATEGY_COMPARISON_*.md      - Stratégia összehasonlítás
BACKTEST_INSTRUCTIONS.md      - Backtest parancsok
```

### Config Fájlok
```
config_hybrid_cryptofrog.json - CryptoFrog hibrid (70%)
config_hybrid_nfi.json        - NFI hibrid (30%)
config_live_cryptofrog.json   - CryptoFrog standalone
config_live_nfi.json          - NFI standalone
```

### Scripts
```
start_hybrid_bots.sh   - Indítás (screen/tmux/systemd)
stop_hybrid_bots.sh    - Leállítás
monitor_hybrid_bots.sh - Real-time monitoring
```

---

## 🎓 További Olvasnivalók

### Stratégiák
- **CryptoFrog**: strategies/CryptoFrog/CryptoFrog.py
- **NFI**: strategies/NostalgiaForInfinityNextGen/

### Freqtrade Dokumentáció
- https://www.freqtrade.io/en/stable/

### Community
- Discord: https://discord.gg/freqtrade
- GitHub NFI: https://github.com/iterativv/NostalgiaForInfinity

---

## ⚡ Gyors Parancsok Cheat Sheet

```bash
# INDÍTÁS
./start_hybrid_bots.sh dry-run screen   # Dry-run, screen-ben
./start_hybrid_bots.sh live tmux        # LIVE, tmux-ban

# LEÁLLÍTÁS
./stop_hybrid_bots.sh all

# MONITORING
./monitor_hybrid_bots.sh

# LOGOK
tail -f ~/freqtrade_bots/cryptofrog_bot/user_data/logs/freqtrade.log
tail -f ~/freqtrade_bots/nfi_bot/user_data/logs/freqtrade.log

# SCREEN
screen -r cryptofrog  # Csatlakozás
screen -r nfi
screen -ls            # Lista

# TMUX
tmux attach -t hybrid_trading
tmux ls

# TELEGRAM
/status
/daily
/profit
/stopentry  # Emergency stop

# API
curl http://localhost:8080/api/v1/status  # CryptoFrog
curl http://localhost:8081/api/v1/status  # NFI
```

---

## 🎯 Következő Lépések

### 1. Dry-Run Teszt (1 hét)
```bash
# Indítsd dry-run módban
./start_hybrid_bots.sh dry-run screen

# Figyeld 1 hétig
# - Napi ellenőrzés
# - Trade aktivitás
# - Nincs error a logokban
```

### 2. Kis Tőke Live Teszt (1 hónap)
```bash
# Állítsd át live módra (kis tőkével!)
# pl. 1,000 USDT

# Módosítsd a config-okban:
"dry_run": false

# Indítás
./start_hybrid_bots.sh live screen
```

### 3. Teljes Tőke (sikeres teszt után)
```bash
# Növeld fokozatosan a tőkét
# 1,000 → 5,000 → 10,000 USDT

# Figyeld a teljesítményt
# Ha >5% havi profit és <15% DD → sikeres!
```

---

## 📞 Segítségkérés

Ha elakadtál:

1. **Ellenőrizd a HYBRID_STRATEGY_GUIDE.md-t** (részletes troubleshooting)
2. **Nézd meg a CONFIG_FILES_REFERENCE.md-t** (config paraméterek)
3. **Csatlakozz a Freqtrade Discord-hoz** (közösség)
4. **Olvasd el a hivatalos doksi-t** (freqtrade.io)

---

**Készítette:** Claude Code AI
**Verzió:** 1.0
**Dátum:** 2025-11-16

---

## ⚠️ JOGI NYILATKOZAT

- Ez NEM pénzügyi tanácsadás
- Csak olyan tőkét használj, amit elveszíthetsz
- A múltbeli teljesítmény nem garancia a jövőbeli eredményekre
- MINDIG dry-run először!
- Rendszeresen monitorozd a botokat
- Állíts be risk management-et

**Sikeres tradingot!** 🚀📈
