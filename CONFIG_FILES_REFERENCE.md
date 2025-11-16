# 📁 Config Fájlok Referencia

## Áttekintés

Ez a dokumentum részletezi az összes létrehozott konfigurációs fájlt és azok használatát.

---

## 🗂️ Fájl Lista

### Standalone Konfigurációk

1. **`config_live_cryptofrog.json`** - CryptoFrog önálló
2. **`config_live_nfi.json`** - NFI önálló

### Hibrid Konfigurációk

3. **`config_hybrid_cryptofrog.json`** - CryptoFrog hibrid (70%)
4. **`config_hybrid_nfi.json`** - NFI hibrid (30%)

### Backtest Konfigurációk

5. **`config_backtest_cryptofrog.json`** - CryptoFrog backtest

---

## 📊 Konfiguráció Összehasonlítás

| Paraméter | Standalone CF | Standalone NFI | Hybrid CF (70%) | Hybrid NFI (30%) |
|-----------|--------------|----------------|-----------------|------------------|
| **Max Open Trades** | 5 | 6 | 4 | 3 |
| **Tradable Balance** | 0.99 (99%) | 0.99 (99%) | 0.70 (70%) | 0.30 (30%) |
| **Timeframe** | 5m | 15m | 5m | 15m |
| **API Port** | 8080 | 8081 | 8080 | 8081 |
| **Database** | default | default | hybrid_cf.sqlite | hybrid_nfi.sqlite |
| **Bot Name** | CryptoFrog_Live | NFI_Live | Hybrid_CryptoFrog_70 | Hybrid_NFI_30 |
| **Stoploss on Exchange** | ✅ Yes | ❌ No | ✅ Yes | ❌ No |

---

## 🔧 Részletes Beállítások

### CryptoFrog Specifikus Beállítások

#### Pair Whitelist (Mid-Cap Altcoins)
```json
"pair_whitelist": [
    "LINK/USDT",    // DeFi Oracle
    "MATIC/USDT",   // Layer 2
    "NEAR/USDT",    // Smart Contracts
    "ALGO/USDT",    // Fast Blockchain
    "XRP/USDT",     // Payments
    "LTC/USDT",     // OG Crypto
    "UNI/USDT",     // DEX
    "AAVE/USDT",    // Lending
    "DOT/USDT",     // Parachain
    "ADA/USDT"      // Smart Contracts
]
```

**Miért ezek a párok?**
- ✅ Mid-cap market cap (~$1B - $20B)
- ✅ Jó volatilitás (2-5% naponként)
- ✅ Magas likviditás
- ✅ 24/7 trading volumen
- ✅ Különböző szektorok (DeFi, L2, Smart Contracts)

#### Volatility Filter
```json
{
    "method": "VolatilityFilter",
    "lookback_days": 3,
    "min_volatility": 0.02,    // Min 2% volatilitás
    "max_volatility": 0.75,    // Max 75% (kiszűri a scam-eket)
    "refresh_period": 86400
}
```

#### Stoploss on Exchange
```json
"stoploss_on_exchange": true,  // FONTOS!
"stoploss_on_exchange_interval": 60,
"stoploss_on_exchange_limit_ratio": 0.99
```

**Miért on-exchange?**
- ✅ Véd API/hálózati hibák ellen
- ✅ Gyorsabb stop execution
- ✅ Flash crash protection

---

### NFI Specifikus Beállítások

#### Pair Whitelist (Large-Cap)
```json
"pair_whitelist": [
    "BTC/USDT",     // King (#1, $800B+)
    "ETH/USDT",     // Queen (#2, $200B+)
    "SOL/USDT",     // Fast L1 (#5, $30B+)
    "BNB/USDT",     // Exchange (#4, $40B+)
    "AVAX/USDT",    // DeFi Platform (~$10B)
    "ATOM/USDT"     // Cosmos Hub (~$3B)
]
```

**Miért ezek?**
- ✅ Top 10 market cap
- ✅ Alacsonyabb volatilitás
- ✅ Stabil trend-követés
- ✅ Intézményi backing
- ✅ DeFi blue chips

#### Stoploss Beállítás
```json
"stoploss": "limit",
"stoploss_on_exchange": false
```

**Miért NEM on-exchange?**
- NFI -50% wide stoploss-t használ
- Ritkán történik stop-out
- Limit order jobb fill price-ot ad

---

## 🎯 Hibrid Setup - Kulcs Különbségek

### 1. Tradable Balance Ratio

**CryptoFrog (70%):**
```json
"tradable_balance_ratio": 0.70
```
- 10,000 USDT wallet → 7,000 USDT használható
- 4 max trades → ~1,750 USDT/trade

**NFI (30%):**
```json
"tradable_balance_ratio": 0.30
```
- 10,000 USDT wallet → 3,000 USDT használható
- 3 max trades → ~1,000 USDT/trade

### 2. Külön Adatbázisok

**CryptoFrog:**
```json
"db_url": "sqlite:///tradesv3_hybrid_cryptofrog.sqlite"
```

**NFI:**
```json
"db_url": "sqlite:///tradesv3_hybrid_nfi.sqlite"
```

**Miért?**
- ✅ Nincs trade ID konfliktus
- ✅ Külön profit tracking
- ✅ Független helyreállítás
- ✅ Könnyebb analízis

### 3. Különböző API Portok

**CryptoFrog:**
```json
"listen_port": 8080
```

**NFI:**
```json
"listen_port": 8081
```

**URL-ek:**
- CryptoFrog FreqUI: http://localhost:8080
- NFI FreqUI: http://localhost:8081

### 4. Pair Blacklist Cross-Protection

**CryptoFrog blacklist-je (NFI pair-eket kizárja):**
```json
"pair_blacklist": [
    "BTC/USDT",
    "ETH/USDT",
    "SOL/USDT",
    "BNB/USDT",
    "AVAX/USDT",
    // ... leveraged tokens
]
```

**NFI blacklist-je (CryptoFrog pair-eket kizárja):**
```json
"pair_blacklist": [
    "LINK/USDT",
    "MATIC/USDT",
    "NEAR/USDT",
    "ALGO/USDT",
    // ... mid-caps
]
```

**Eredmény:**
- ❌ Nincs átfedő trade
- ✅ Diverzifikált pair exposure

---

## 🔐 Biztonsági Beállítások

### API Server Security

```json
"api_server": {
    "enabled": true,
    "listen_ip_address": "127.0.0.1",  // Csak localhost!
    "jwt_secret_key": "CHANGE_THIS",    // Generálj random-ot!
    "username": "freqtrader",
    "password": "CHANGE_THIS"           // Erős jelszó!
}
```

**Secret Key generálás:**
```bash
openssl rand -hex 32
```

### Exchange API Keys

```json
"exchange": {
    "key": "YOUR_API_KEY",
    "secret": "YOUR_API_SECRET"
}
```

**API Engedélyek (csak ezek kellenek!):**
- ✅ Read
- ✅ Trade (spot)
- ❌ Withdraw (NE add meg!)
- ❌ Transfer (NE add meg!)

**IP Whitelist (Bybit):**
- Állíts be IP whitelist-et a Bybit-en
- Csak a server IP-jét add hozzá

---

## 📱 Telegram Beállítások

### Bot Létrehozás

1. Keress rá: @BotFather
2. `/newbot`
3. Adj nevet: pl. "MyFreqtradeBot"
4. Kapj tokent: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`

### Chat ID megszerzése

```bash
# Küldj egy üzenetet a botnak, majd:
curl https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates

# Keresd meg a "chat":{"id": 123456789 részt
```

### Config Beállítás

```json
"telegram": {
    "enabled": true,
    "token": "123456789:ABCdefGHIjklMNOpqrsTUVwxyz",
    "chat_id": "123456789"
}
```

### Notification Customization

**CryptoFrog (agresszív, sok trade):**
```json
"notification_settings": {
    "entry": "silent",              // Ne spam-eljen minden entry-nél
    "entry_fill": "on",
    "exit": {
        "roi": "silent",
        "stop_loss": "on",          // Csak stoploss-oknál notify
        "custom_exit": "silent"
    }
}
```

**NFI (kevesebb trade):**
```json
"notification_settings": {
    "entry": "on",                  // Minden entry-nél értesít
    "exit": {
        "roi": "on",
        "stop_loss": "on",
        "custom_exit": "on"
    }
}
```

---

## 🎲 Pairlist Filterek Magyarázata

### 1. StaticPairList
```json
{
    "method": "StaticPairList"
}
```
- Használja a `pair_whitelist`-et
- Nem változik dinamikusan

### 2. AgeFilter
```json
{
    "method": "AgeFilter",
    "min_days_listed": 10
}
```
- Kiszűri az új listingeket
- Véd pump & dump ellen

### 3. PrecisionFilter
```json
{
    "method": "PrecisionFilter"
}
```
- Csak tradeable precíziójú párokat engedi
- Exchange-specifikus

### 4. PriceFilter
```json
{
    "method": "PriceFilter",
    "low_price_ratio": 0.01
}
```
- Kiszűri a túl olcsó shitcoin-okat
- Min. ár: 1% a BTC árának (opcionális)

### 5. SpreadFilter
```json
{
    "method": "SpreadFilter",
    "max_spread_ratio": 0.005
}
```
- Max 0.5% spread bid/ask között
- Véd illiquid párok ellen

### 6. VolatilityFilter (csak CryptoFrog)
```json
{
    "method": "VolatilityFilter",
    "lookback_days": 3,
    "min_volatility": 0.02,
    "max_volatility": 0.75
}
```
- Min 2% volatilitás (CryptoFrog szereti)
- Max 75% (scam protection)

---

## ⚙️ Edge Position Sizing (Opcionális)

```json
"edge": {
    "enabled": false,  // Alapból kikapcsolva
    "allowed_risk": 0.01,
    "stoploss_range_min": -0.01,
    "stoploss_range_max": -0.1
}
```

**Mi ez?**
- Dinamikus position sizing
- Risk alapú stake calculation
- Advanced feature

**Mikor használd?**
- Ha érted a kockázatkezelést
- Ha backtesteltél vele
- NFI-nél működhet jobban

---

## 🔄 Config Frissítés Élő Bottal

### 1. Módszer: Restart (Biztonságos)

```bash
# Állítsd le a botot
./stop_hybrid_bots.sh

# Módosítsd a config.json-t
nano ~/freqtrade_bots/cryptofrog_bot/config.json

# Indítsd újra
./start_hybrid_bots.sh dry-run screen
```

### 2. Módszer: Reload (Gyorsabb, de nem minden változik)

```bash
# Telegram-on
/reload_config

# Vagy API-n keresztül
curl -X POST http://localhost:8080/api/v1/reload_config
```

**Mit NEM frissít a reload?**
- ❌ Strategy változások
- ❌ Timeframe
- ❌ Exchange settings
- ❌ Database URL

**Mit frissít?**
- ✅ Stake amount
- ✅ Max open trades
- ✅ Pairlist
- ✅ Telegram settings

---

## 📊 Config Template Használata

### Új Bot Létrehozása Template-ből

```bash
# Másold a template-et
cp config_hybrid_cryptofrog.json config_my_new_bot.json

# Módosítsd:
nano config_my_new_bot.json
```

**Kötelező változtatások:**
1. `bot_name`: Egyedi név
2. `api_server.listen_port`: Egyedi port
3. `db_url`: Egyedi database fájl
4. `pair_whitelist`: Válassz más párokat
5. `api_server.jwt_secret_key`: Új secret
6. `api_server.password`: Új jelszó

---

## 🔍 Config Validálás

### Syntax Check

```bash
# JSON syntax ellenőrzés
python -m json.tool config.json

# Freqtrade validáció
freqtrade show-config --config config.json
```

### Dry-Run Test

```bash
# 1 perces test
freqtrade trade --config config.json --strategy CryptoFrog --dry-run &
sleep 60
pkill freqtrade

# Ellenőrizd a logokat
tail -50 user_data/logs/freqtrade.log
```

---

## 📝 Changelog Követés

**Ajánlott gyakorlat:**

```bash
# Készíts backup-ot config módosítás előtt
cp config.json config.json.backup.$(date +%Y%m%d)

# Git tracking
git add config.json
git commit -m "Update: increased max_open_trades to 6"
```

---

## 🎯 Gyors Referencia

| Mit akarsz? | Melyik config? |
|-------------|----------------|
| Csak CryptoFrog | `config_live_cryptofrog.json` |
| Csak NFI | `config_live_nfi.json` |
| **Hibrid (ajánlott)** | `config_hybrid_cryptofrog.json` + `config_hybrid_nfi.json` |
| Backtest CF | `config_backtest_cryptofrog.json` |
| Backtest NFI | Használd a strategies/NFI/ alatti config-ot |

---

**Készítette:** Claude Code AI
**Frissítve:** 2025-11-16
