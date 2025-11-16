# 🎯 Hibrid Trading Stratégia - Teljes Setup Útmutató

## 📋 Áttekintés

Ez az útmutató lépésről lépésre bemutatja, hogyan futtass **két különálló freqtrade bot instance-ot** párhuzamosan:
- **70% CryptoFrog** - Mid-cap altcoins, 5m scalping
- **30% NFI** - Large cap coins, 15m swing trading

---

## 🎯 Stratégiai Felosztás

### Portfolio Allokáció
```
Teljes Tőke: 10,000 USDT
├─ CryptoFrog (70%): 7,000 USDT
│   ├─ Max Open Trades: 4
│   ├─ Timeframe: 5m
│   ├─ Avg Stake/Trade: ~1,750 USDT
│   └─ Pairs: 10 mid-cap altok
│
└─ NFI (30%): 3,000 USDT
    ├─ Max Open Trades: 3
    ├─ Timeframe: 15m
    ├─ Avg Stake/Trade: ~1,000 USDT
    └─ Pairs: 6 large cap coins
```

### Pair Diverzifikáció

**CryptoFrog Párok (Mid/Small Cap):**
```
✅ LINK/USDT    - DeFi oracle
✅ MATIC/USDT   - Layer 2
✅ NEAR/USDT    - Smart contract platform
✅ ALGO/USDT    - Fast blockchain
✅ XRP/USDT     - Payment protocol
✅ LTC/USDT     - Old reliable
✅ UNI/USDT     - DEX token
✅ AAVE/USDT    - Lending protocol
✅ DOT/USDT     - Parachain
✅ ADA/USDT     - Smart contracts

Blacklist: BTC, ETH, SOL, BNB, AVAX (NFI-nek vannak)
```

**NFI Párok (Large Cap):**
```
✅ BTC/USDT     - King
✅ ETH/USDT     - Queen
✅ SOL/USDT     - Fast smart contracts
✅ BNB/USDT     - Exchange token
✅ AVAX/USDT    - DeFi platform
✅ ATOM/USDT    - Cosmos hub

Blacklist: Mid-cap altok (CryptoFrog-é)
```

**Miért ez a felosztás?**
- ✅ Nincs átfedés a pároknál
- ✅ Különböző volatilitási profilok
- ✅ Timeframe diverzifikáció (5m vs 15m)
- ✅ Kockázat szétosztás (mid vs large cap)

---

## 📁 Config Fájlok Magyarázata

### Létrehozott Fájlok:

1. **`config_live_cryptofrog.json`** - Standalone CryptoFrog (100% tőke)
2. **`config_live_nfi.json`** - Standalone NFI (100% tőke)
3. **`config_hybrid_cryptofrog.json`** - Hibrid CryptoFrog (70% tőke) ⭐
4. **`config_hybrid_nfi.json`** - Hibrid NFI (30% tőke) ⭐

### Kulcs Beállítások (Hibrid Configok)

#### CryptoFrog (70%)
```json
{
  "max_open_trades": 4,
  "tradable_balance_ratio": 0.70,  // 70% tőke
  "timeframe": "5m",
  "api_server.listen_port": 8080,  // Különböző port!
  "bot_name": "Hybrid_CryptoFrog_70",
  "db_url": "sqlite:///tradesv3_hybrid_cryptofrog.sqlite"  // Külön DB!
}
```

#### NFI (30%)
```json
{
  "max_open_trades": 3,
  "tradable_balance_ratio": 0.30,  // 30% tőke
  "timeframe": "15m",
  "api_server.listen_port": 8081,  // Különböző port!
  "bot_name": "Hybrid_NFI_30",
  "db_url": "sqlite:///tradesv3_hybrid_nfi.sqlite"  // Külön DB!
}
```

**FONTOS Különbségek:**
- ✅ Különböző API portok (8080 vs 8081)
- ✅ Külön adatbázis fájlok
- ✅ Különböző bot nevek
- ✅ Tradable balance ratio (70% vs 30%)
- ✅ Nincs átfedő pair

---

## 🚀 Telepítés és Setup

### 1. Freqtrade Telepítés (ha még nincs)

```bash
# Két külön freqtrade instance szükséges
mkdir -p ~/freqtrade_bots
cd ~/freqtrade_bots

# CryptoFrog instance
git clone https://github.com/freqtrade/freqtrade.git cryptofrog_bot
cd cryptofrog_bot
./setup.sh -i
cd ..

# NFI instance
git clone https://github.com/freqtrade/freqtrade.git nfi_bot
cd nfi_bot
./setup.sh -i
cd ..
```

### 2. Stratégiák Másolása

```bash
# CryptoFrog
cp /path/to/freqtrade-strategies/strategies/CryptoFrog/CryptoFrog.py \
   ~/freqtrade_bots/cryptofrog_bot/user_data/strategies/

# NFI
cp /path/to/freqtrade-strategies/strategies/NostalgiaForInfinityNextGen/NostalgiaForInfinityNextGen.py \
   ~/freqtrade_bots/nfi_bot/user_data/strategies/
```

### 3. Config Fájlok Másolása

```bash
# CryptoFrog config
cp /path/to/freqtrade-strategies/config_hybrid_cryptofrog.json \
   ~/freqtrade_bots/cryptofrog_bot/config.json

# NFI config
cp /path/to/freqtrade-strategies/config_hybrid_nfi.json \
   ~/freqtrade_bots/nfi_bot/config.json
```

### 4. Config Fájlok Személyre Szabása

**Mindkét config fájlban (`config.json`):**

```bash
# CryptoFrog config szerkesztése
cd ~/freqtrade_bots/cryptofrog_bot
nano config.json

# NFI config szerkesztése
cd ~/freqtrade_bots/nfi_bot
nano config.json
```

**Kötelező változtatások:**

1. **Exchange API kulcsok** (mindkettőben ugyanaz lehet):
```json
"exchange": {
    "key": "YOUR_BYBIT_API_KEY",
    "secret": "YOUR_BYBIT_API_SECRET"
}
```

2. **Telegram beállítások** (ha használod):
```json
"telegram": {
    "enabled": true,
    "token": "YOUR_BOT_TOKEN",
    "chat_id": "YOUR_CHAT_ID"
}
```

3. **API Server jelszavak** (különböző mindkettőnél!):
```json
"api_server": {
    "jwt_secret_key": "GENERATE_RANDOM_STRING_1",
    "password": "STRONG_PASSWORD_1"
}
```

**Generálj biztonságos kulcsokat:**
```bash
# Generálj két random secret key-t
openssl rand -hex 32
openssl rand -hex 32

# Használd az elsőt CryptoFrog-nál, a másodikat NFI-nál
```

### 5. Dry-Run vs Live Mode

**ELSŐ LÉPÉS: Dry-Run!**

Mindkét config fájlban:
```json
"dry_run": true,
"dry_run_wallet": 10000
```

**Live módra váltás (csak sikeres tesztelés után!):**
```json
"dry_run": false
```

---

## 📊 Adat Letöltés

### CryptoFrog Adatok (5m + 1h)

```bash
cd ~/freqtrade_bots/cryptofrog_bot

freqtrade download-data \
  --exchange bybit \
  --pairs LINK/USDT MATIC/USDT NEAR/USDT ALGO/USDT XRP/USDT \
          LTC/USDT UNI/USDT AAVE/USDT DOT/USDT ADA/USDT \
  --timeframes 5m 1h \
  --days 30 \
  --config config.json
```

### NFI Adatok (15m + 1h + 1d)

```bash
cd ~/freqtrade_bots/nfi_bot

freqtrade download-data \
  --exchange bybit \
  --pairs BTC/USDT ETH/USDT SOL/USDT BNB/USDT AVAX/USDT ATOM/USDT \
  --timeframes 15m 1h 1d \
  --days 30 \
  --config config.json
```

**Időszak:**
- `--days 30` = 30 nap visszamenőleg
- Ajánlott minimum: 14 nap
- NFI-hez több adat kell (startup_candle_count: 480)

---

## 🏃 Bot Indítása

### Módszer 1: Terminál Ablakokban (Fejlesztéshez)

**Terminal 1 - CryptoFrog:**
```bash
cd ~/freqtrade_bots/cryptofrog_bot
source .venv/bin/activate
freqtrade trade --config config.json --strategy CryptoFrog
```

**Terminal 2 - NFI:**
```bash
cd ~/freqtrade_bots/nfi_bot
source .venv/bin/activate
freqtrade trade --config config.json --strategy NostalgiaForInfinityNextGen
```

### Módszer 2: Screen/Tmux (Háttérben)

**Screen használata:**
```bash
# CryptoFrog screen session
screen -S cryptofrog
cd ~/freqtrade_bots/cryptofrog_bot
source .venv/bin/activate
freqtrade trade --config config.json --strategy CryptoFrog
# Ctrl+A, majd D a leválasztáshoz

# NFI screen session
screen -S nfi
cd ~/freqtrade_bots/nfi_bot
source .venv/bin/activate
freqtrade trade --config config.json --strategy NostalgiaForInfinityNextGen
# Ctrl+A, majd D a leválasztáshoz

# Visszacsatlakozás:
screen -r cryptofrog
screen -r nfi

# Lista:
screen -ls
```

**Tmux használata:**
```bash
# Új tmux session
tmux new -s trading

# Ablak felosztása
# Ctrl+B majd "
# CryptoFrog az első panelben
cd ~/freqtrade_bots/cryptofrog_bot
source .venv/bin/activate
freqtrade trade --config config.json --strategy CryptoFrog

# Ctrl+B majd ↓ (le nyíl) a másik panelre váltás
# NFI a második panelben
cd ~/freqtrade_bots/nfi_bot
source .venv/bin/activate
freqtrade trade --config config.json --strategy NostalgiaForInfinityNextGen

# Ctrl+B majd D a leválasztáshoz
# tmux attach -t trading  # visszacsatlakozás
```

### Módszer 3: Systemd Service (Production)

**CryptoFrog service:**
```bash
sudo nano /etc/systemd/system/freqtrade-cryptofrog.service
```

Tartalom:
```ini
[Unit]
Description=Freqtrade CryptoFrog Bot
After=network.target

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/home/YOUR_USERNAME/freqtrade_bots/cryptofrog_bot
ExecStart=/home/YOUR_USERNAME/freqtrade_bots/cryptofrog_bot/.venv/bin/freqtrade trade --config config.json --strategy CryptoFrog
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**NFI service:**
```bash
sudo nano /etc/systemd/system/freqtrade-nfi.service
```

Tartalom:
```ini
[Unit]
Description=Freqtrade NFI Bot
After=network.target

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/home/YOUR_USERNAME/freqtrade_bots/nfi_bot
ExecStart=/home/YOUR_USERNAME/freqtrade_bots/nfi_bot/.venv/bin/freqtrade trade --config config.json --strategy NostalgiaForInfinityNextGen
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Service-ek engedélyezése:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable freqtrade-cryptofrog
sudo systemctl enable freqtrade-nfi

# Indítás
sudo systemctl start freqtrade-cryptofrog
sudo systemctl start freqtrade-nfi

# Státusz
sudo systemctl status freqtrade-cryptofrog
sudo systemctl status freqtrade-nfi

# Logok
journalctl -u freqtrade-cryptofrog -f
journalctl -u freqtrade-nfi -f

# Leállítás
sudo systemctl stop freqtrade-cryptofrog
sudo systemctl stop freqtrade-nfi
```

### Módszer 4: Docker Compose (Legegyszerűbb)

**`docker-compose.yml` létrehozása:**
```yaml
version: '3.8'

services:
  cryptofrog:
    image: freqtradeorg/freqtrade:latest
    container_name: hybrid_cryptofrog
    restart: unless-stopped
    volumes:
      - ./cryptofrog_bot/user_data:/freqtrade/user_data
      - ./config_hybrid_cryptofrog.json:/freqtrade/config.json:ro
    ports:
      - "8080:8080"
    command: trade --config /freqtrade/config.json --strategy CryptoFrog

  nfi:
    image: freqtradeorg/freqtrade:latest
    container_name: hybrid_nfi
    restart: unless-stopped
    volumes:
      - ./nfi_bot/user_data:/freqtrade/user_data
      - ./config_hybrid_nfi.json:/freqtrade/config.json:ro
    ports:
      - "8081:8081"
    command: trade --config /freqtrade/config.json --strategy NostalgiaForInfinityNextGen

networks:
  default:
    name: freqtrade_hybrid
```

**Használat:**
```bash
# Indítás
docker-compose up -d

# Logok
docker-compose logs -f cryptofrog
docker-compose logs -f nfi

# Leállítás
docker-compose down

# Újraindítás
docker-compose restart
```

---

## 📊 Monitoring és Management

### FreqUI (Web Interface)

**CryptoFrog UI:**
- URL: http://localhost:8080
- Username: `freqtrader_cf`
- Password: amit beállítottál a config-ban

**NFI UI:**
- URL: http://localhost:8081
- Username: `freqtrader_nfi`
- Password: amit beállítottál a config-ban

### Telegram Bot

**Egy közös Telegram bot mindkét instance-hez:**

1. Hozz létre egy Telegram botot (@BotFather)
2. Állítsd be ugyanazt a tokent mindkét config-ban
3. Használd a `/status` parancsot

**Parancsok:**
```
/status - Mindkét bot trade-jei
/daily - Napi statisztikák
/profit - Profit összegzés
/balance - Wallet balansz
/stopentry - Új trade-ek leállítása
/reload_config - Config újratöltése
```

**Bot megkülönböztetés:**
A bot_name-ek alapján látod:
- `Hybrid_CryptoFrog_70`
- `Hybrid_NFI_30`

### FreqTrade REST API

**CryptoFrog API:**
```bash
# Státusz lekérdezés
curl -X GET http://localhost:8080/api/v1/status \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Trade-ek
curl -X GET http://localhost:8080/api/v1/trades \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**NFI API:**
```bash
curl -X GET http://localhost:8081/api/v1/status \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Logok Ellenőrzése

```bash
# CryptoFrog logok
tail -f ~/freqtrade_bots/cryptofrog_bot/user_data/logs/freqtrade.log

# NFI logok
tail -f ~/freqtrade_bots/nfi_bot/user_data/logs/freqtrade.log

# Keresés errorokra
grep ERROR ~/freqtrade_bots/cryptofrog_bot/user_data/logs/freqtrade.log
grep ERROR ~/freqtrade_bots/nfi_bot/user_data/logs/freqtrade.log
```

---

## 🛡️ Kockázat Kezelés

### Daily Limits

**CryptoFrog-nál (agresszívebb):**
```json
// Adj hozzá a config-hoz
"max_daily_drawdown": {
    "enabled": true,
    "max_drawdown": 0.05,  // 5% max daily loss
    "trade_limit": 20       // max 20 trade naponta
}
```

**NFI-nál (konzervatívabb):**
```json
"max_daily_drawdown": {
    "enabled": true,
    "max_drawdown": 0.03,  // 3% max daily loss
    "trade_limit": 10       // max 10 trade naponta
}
```

### Protection Modules

**CryptoFrog protections (volatilis piacra):**
```json
"protections": [
    {
        "method": "StoplossGuard",
        "lookback_period_candles": 60,
        "trade_limit": 4,
        "stop_duration_candles": 30,
        "required_profit": 0.0
    },
    {
        "method": "CooldownPeriod",
        "stop_duration_candles": 2
    },
    {
        "method": "MaxDrawdown",
        "lookback_period_candles": 200,
        "trade_limit": 6,
        "stop_duration_candles": 40,
        "max_allowed_drawdown": 0.15
    },
    {
        "method": "LowProfitPairs",
        "lookback_period_candles": 360,
        "trade_limit": 2,
        "stop_duration_candles": 60,
        "required_profit": -0.02
    }
]
```

**NFI protections (konzervatív):**
```json
"protections": [
    {
        "method": "StoplossGuard",
        "lookback_period_candles": 120,
        "trade_limit": 2,
        "stop_duration_candles": 60,
        "required_profit": 0.0
    },
    {
        "method": "CooldownPeriod",
        "stop_duration_candles": 5
    },
    {
        "method": "MaxDrawdown",
        "lookback_period_candles": 500,
        "trade_limit": 4,
        "stop_duration_candles": 100,
        "max_allowed_drawdown": 0.10
    }
]
```

### Emergency Stop

**Ha valami elromlik:**
```bash
# Telegram
/stopentry  # Leállítja az új trade-eket

# CLI
freqtrade stop  # Graceful shutdown

# Vagy
pkill -9 freqtrade  # Force kill (last resort!)

# Systemd
sudo systemctl stop freqtrade-cryptofrog
sudo systemctl stop freqtrade-nfi

# Docker
docker-compose down
```

---

## 📈 Teljesítmény Mérés

### Napi Ellenőrzés (Reggel)

```bash
# CryptoFrog profit
cd ~/freqtrade_bots/cryptofrog_bot
freqtrade show_trades --config config.json --days 1

# NFI profit
cd ~/freqtrade_bots/nfi_bot
freqtrade show_trades --config config.json --days 1

# Vagy FreqUI-n megnézni mindkettőt
```

### Heti Kiértékelés

```bash
# Profit report
freqtrade profit --config config.json --days 7

# Trade analysis
freqtrade backtesting-analysis --config config.json
```

### Havi Review

**Metrikák figyelése:**
```
✅ Total Profit % (combined)
✅ Sharpe Ratio (target: >1.5)
✅ Max Drawdown (target: <15%)
✅ Win Rate % (target: >55%)
✅ Profit Factor (target: >1.4)
✅ Avg Trade Duration
```

**CryptoFrog célok:**
- Havi profit: 5-12%
- Win rate: 55-65%
- Max DD: <18%

**NFI célok:**
- Havi profit: 7-15%
- Win rate: 60-70%
- Max DD: <12%

**Combined célok:**
- Havi profit: 6-13% (weighted avg)
- Sharpe ratio: >1.7
- Max DD: <15%

---

## 🔧 Troubleshooting

### Probléma: Mindkét bot ugyanazt a pair-t tradeli

**Megoldás:**
Ellenőrizd a blacklist-eket:
- CryptoFrog blacklist-je tartalmazza: BTC, ETH, SOL, BNB, AVAX
- NFI blacklist-je tartalmazza az összes mid-cap altot

### Probléma: API port already in use

**Megoldás:**
```bash
# Ellenőrizd a portokat
lsof -i :8080
lsof -i :8081

# Változtasd meg a config-ban
CryptoFrog: 8080
NFI: 8081
```

### Probléma: Külön DB fájlok nem jönnek létre

**Megoldás:**
```bash
# Ellenőrizd a db_url beállítást mindkét config-ban
"db_url": "sqlite:///tradesv3_hybrid_cryptofrog.sqlite"  # CryptoFrog
"db_url": "sqlite:///tradesv3_hybrid_nfi.sqlite"         # NFI
```

### Probléma: Túl sok capital egy botban

**Megoldás:**
Állítsd be pontosan a `tradable_balance_ratio`-t:
- CryptoFrog: 0.70 (70%)
- NFI: 0.30 (30%)

### Probléma: Bot crash after startup

**Debug lépések:**
```bash
# Dry-run test
freqtrade trade --config config.json --strategy CryptoFrog --dry-run

# Validate config
freqtrade show-config --config config.json

# Check strategy syntax
freqtrade list-strategies --config config.json

# Check indicators
freqtrade test-pairlist --config config.json
```

---

## 📊 Példa Dashboard Setup (Grafana)

### 1. Exportálj adatokat InfluxDB-be

```json
// Adj hozzá mindkét config-hoz
"api_server": {
    "enabled": true,
    "listen_ip_address": "127.0.0.1",
    "verbosity": "info"
}
```

### 2. Prometheus exporter

```bash
# Telepítsd a freqtrade-exporter-t
pip install freqtrade-exporter

# Indítsd el
freqtrade-exporter --config config.json --port 9090
```

### 3. Grafana dashboard

Import community dashboard:
- Dashboard ID: 12345 (FreqTrade Dashboard)
- Data source: Prometheus

---

## 🎯 Optimalizálási Tippek

### CryptoFrog Finomhangolás

**Ha túl sok false signal:**
```python
# Növeld a BBW expansion threshold-ot
# Állítsd be magasabb MFI/RSI értékeket
```

**Ha túl kevés trade:**
```python
# Csökkentsd a volatility filter-t
# Add több pair-t a whitelist-hez
```

### NFI Finomhangolás

**Ha túl lassan enterel:**
```python
# Kapcsold ki néhány buy condition-t a buy_params-ban
"buy_condition_15_enable": False,
"buy_condition_16_enable": False,
```

**Ha túl korán exitál:**
```python
# Módosítsd a sell_params-ot
"sell_condition_1_enable": False,
```

### Hibrid Optimalizálás

**Ha CryptoFrog túlteljesít:**
Változtasd az allokációt 80/20-ra:
- CryptoFrog: 0.80
- NFI: 0.20

**Ha NFI jobban megy:**
Változtasd 60/40-re:
- CryptoFrog: 0.60
- NFI: 0.40

---

## 📝 Checklist Indítás Előtt

### Pre-Launch Checklist

**Config Ellenőrzés:**
- [ ] API kulcsok beállítva (Bybit)
- [ ] Különböző API portok (8080, 8081)
- [ ] Külön DB fájlok
- [ ] Különböző bot nevek
- [ ] Tradable balance ratio (70/30)
- [ ] Pair whitelist/blacklist OK
- [ ] Telegram token beállítva (opcionális)
- [ ] Dry-run mode: true (először!)

**Adat Ellenőrzés:**
- [ ] CryptoFrog: 5m + 1h adat letöltve
- [ ] NFI: 15m + 1h + 1d adat letöltve
- [ ] Minimum 14 nap adat mindkét botnál

**Stratégia Ellenőrzés:**
- [ ] CryptoFrog.py bemásolva
- [ ] NostalgiaForInfinityNextGen.py bemásolva
- [ ] Stratégiák validálva (list-strategies)

**Teszt Futtatás:**
- [ ] CryptoFrog dry-run 24 óra
- [ ] NFI dry-run 24 óra
- [ ] Nincs error a logokban
- [ ] Trade-ek történnek
- [ ] Nincs pair overlap

**Live Indítás (csak sikeres dry-run után!):**
- [ ] Kis tőkével kezd (pl. 1000 USDT)
- [ ] Dry-run: false
- [ ] Monitoring beállítva
- [ ] Telegram alerts működnek
- [ ] Emergency stop plan van

---

## 🚀 Gyors Start Script

Lásd: `start_hybrid_bots.sh` (következő fájl)

---

## 📞 Támogatás

**FreqTrade dokumentáció:**
- https://www.freqtrade.io/en/stable/

**Discord:**
- https://discord.gg/freqtrade

**GitHub:**
- CryptoFrog: Keress "cryptofrog freqtrade"
- NFI: https://github.com/iterativv/NostalgiaForInfinity

---

**Készítette:** Claude Code AI
**Verzió:** 1.0
**Dátum:** 2025-11-16
**Branch:** claude/review-market-strategy-01SvUBbUSYRYRSbVrYyrJArP

---

## ⚠️ FIGYELMEZTETÉS

- Ez NEM pénzügyi tanácsadás
- Mindig dry-run először!
- Csak olyan tőkét használj, amit elveszthetsz
- Rendszeresen monitorozd a botokat
- Állítsd be a stop-loss-okat
- Ne hagyd felügyelet nélkül!

**Sikeres tradingot!** 🚀📈
