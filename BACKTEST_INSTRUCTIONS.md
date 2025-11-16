# Backtest Futtatási Útmutató - CryptoFrog vs NFI

## 📋 Előfeltételek

### 1. Freqtrade Telepítés
```bash
# Ha még nincs telepítve freqtrade
git clone https://github.com/freqtrade/freqtrade.git
cd freqtrade
./setup.sh -i

# VAGY Docker használat (ajánlott)
docker pull freqtradeorg/freqtrade:latest
```

### 2. Stratégiák Másolása
```bash
# Másold be a stratégiákat a freqtrade user_data könyvtárába
cp /home/user/freqtrade-strategies/strategies/CryptoFrog/CryptoFrog.py \
   /path/to/freqtrade/user_data/strategies/

cp /home/user/freqtrade-strategies/strategies/NostalgiaForInfinityNextGen/NostalgiaForInfinityNextGen.py \
   /path/to/freqtrade/user_data/strategies/
```

---

## 📥 Adat Letöltés (ELSŐ LÉPÉS!)

### Recommended Pairs (CryptoFrog)
```bash
cd /path/to/freqtrade

# CryptoFrog - 5 perces adat
freqtrade download-data \
  --exchange bybit \
  --pairs BTC/USDT ETH/USDT ADA/USDT DOT/USDT LINK/USDT \
          MATIC/USDT SOL/USDT AVAX/USDT ATOM/USDT NEAR/USDT \
          ALGO/USDT XRP/USDT LTC/USDT UNI/USDT AAVE/USDT \
  --timeframes 5m 1h \
  --timerange 20250901-20251116 \
  --datadir user_data/data/bybit
```

### Recommended Pairs (NFI)
```bash
# NostalgiaForInfinityNextGen - 15 perces + 1h + 1d adat
freqtrade download-data \
  --exchange bybit \
  --pairs BTC/USDT ETH/USDT ADA/USDT DOT/USDT LINK/USDT \
          MATIC/USDT SOL/USDT AVAX/USDT ATOM/USDT NEAR/USDT \
          ALGO/USDT XRP/USDT LTC/USDT UNI/USDT AAVE/USDT \
  --timeframes 15m 1h 1d \
  --timerange 20250901-20251116 \
  --datadir user_data/data/bybit
```

**Időtartam:**
- **20250901-20251116** = ~2.5 hónap friss adat
- Miért: September-November volatilis altcoin season

---

## 🚀 BACKTEST FUTTATÁS

### 1️⃣ CryptoFrog Backtest

#### Alap Backtest
```bash
freqtrade backtesting \
  --strategy CryptoFrog \
  --timeframe 5m \
  --timerange 20250901-20251116 \
  --max-open-trades 6 \
  --stake-amount 1000 \
  --datadir user_data/data/bybit \
  --export trades \
  --export-filename user_data/backtest_results/cryptofrog_basic.json
```

#### Részletes Backtest (ajánlott)
```bash
freqtrade backtesting \
  --strategy CryptoFrog \
  --timeframe 5m \
  --timerange 20250901-20251116 \
  --max-open-trades 6 \
  --stake-amount unlimited \
  --starting-balance 10000 \
  --fee 0.001 \
  --datadir user_data/data/bybit \
  --breakdown day month \
  --export trades signals \
  --export-filename user_data/backtest_results/cryptofrog_detailed.json \
  --cache none
```

### 2️⃣ NostalgiaForInfinityNextGen Backtest

#### Alap Backtest
```bash
freqtrade backtesting \
  --strategy NostalgiaForInfinityNextGen \
  --timeframe 15m \
  --timerange 20250901-20251116 \
  --max-open-trades 6 \
  --stake-amount 1000 \
  --datadir user_data/data/bybit \
  --export trades \
  --export-filename user_data/backtest_results/nfi_basic.json
```

#### Részletes Backtest (ajánlott)
```bash
freqtrade backtesting \
  --strategy NostalgiaForInfinityNextGen \
  --timeframe 15m \
  --timerange 20250901-20251116 \
  --max-open-trades 6 \
  --stake-amount unlimited \
  --starting-balance 10000 \
  --fee 0.001 \
  --datadir user_data/data/bybit \
  --breakdown day month \
  --export trades signals \
  --export-filename user_data/backtest_results/nfi_detailed.json \
  --cache none
```

---

## 📊 EREDMÉNYEK ÉRTELMEZÉSE

### Kulcs Metrikák

```
FIGYELJÜK:
✅ Total Profit % - Teljes profit százalék
✅ Sharpe Ratio - Kockázat-arányos hozam (>1.5 jó)
✅ Calmar Ratio - Hozam/Max Drawdown (>2.0 jó)
✅ Max Drawdown - Legnagyobb visszaesés (minél kisebb, annál jobb)
✅ Win Rate % - Nyerő tradek aránya (>55% elfogadható)
✅ Profit Factor - Nyereség/Veszteség arány (>1.5 jó)
✅ Avg Trade Duration - Átlagos trade hossz
✅ Total Trades - Összes trade szám

KERÜLJÜK:
❌ Max Drawdown > 25%
❌ Win Rate < 45%
❌ Sharpe Ratio < 0.8
❌ Profit Factor < 1.2
❌ Túl kevés trade (< 50 db 2.5 hónapra)
```

### Példa Kiértékelés
```bash
# Backtest eredmények megtekintése
freqtrade backtesting-show \
  --export-filename user_data/backtest_results/cryptofrog_detailed.json

freqtrade backtesting-show \
  --export-filename user_data/backtest_results/nfi_detailed.json
```

---

## 🔍 RÉSZLETES ANALÍZIS

### 1. Havi Bontás Összehasonlítás
```bash
# CryptoFrog havi breakdown
freqtrade backtesting-analysis \
  --export-filename user_data/backtest_results/cryptofrog_detailed.json \
  --analysis-groups 0 1 2

# NFI havi breakdown
freqtrade backtesting-analysis \
  --export-filename user_data/backtest_results/nfi_detailed.json \
  --analysis-groups 0 1 2
```

### 2. Trade Listák Export
```bash
# CSV export további elemzéshez
sqlite3 user_data/tradesv3.dryrun.sqlite \
  "SELECT * FROM trades WHERE strategy = 'CryptoFrog';" \
  -csv -header > cryptofrog_trades.csv

sqlite3 user_data/tradesv3.dryrun.sqlite \
  "SELECT * FROM trades WHERE strategy = 'NostalgiaForInfinityNextGen';" \
  -csv -header > nfi_trades.csv
```

### 3. Plottolás (Vizuális Elemzés)
```bash
# CryptoFrog chart
freqtrade plot-dataframe \
  --strategy CryptoFrog \
  --timeframe 5m \
  --timerange 20251101-20251107 \
  --indicators1 bb_lowerband bb_upperband Smooth_HA_L Smooth_HA_H \
  --indicators2 rsi mfi \
  --pairs BTC/USDT

# NFI chart
freqtrade plot-dataframe \
  --strategy NostalgiaForInfinityNextGen \
  --timeframe 15m \
  --timerange 20251101-20251107 \
  --indicators1 ema_12 ema_26 ema_200 \
  --indicators2 rsi mfi \
  --pairs BTC/USDT
```

---

## 🎯 OPTIMALIZÁLÁS (Hyperopt)

### CryptoFrog Hyperopt (Opcionális)
```bash
freqtrade hyperopt \
  --strategy CryptoFrog \
  --timeframe 5m \
  --timerange 20250901-20251015 \
  --hyperopt-loss SharpeHyperOptLoss \
  --spaces buy sell roi stoploss trailing \
  --epochs 500 \
  --max-open-trades 6 \
  --stake-amount 1000 \
  --datadir user_data/data/bybit \
  --random-state 42
```

### NFI Hyperopt (Haladó)
```bash
# NFI nagyon komplex, csak ROI/Stoploss optimalizálás ajánlott
freqtrade hyperopt \
  --strategy NostalgiaForInfinityNextGen \
  --timeframe 15m \
  --timerange 20250901-20251015 \
  --hyperopt-loss SharpeHyperOptLoss \
  --spaces roi stoploss \
  --epochs 200 \
  --max-open-trades 6 \
  --stake-amount 1000 \
  --datadir user_data/data/bybit
```

---

## 📈 ÖSSZEHASONLÍTÓ BACKTEST (Mindkettő egyszerre)

### Párhuzamos Futtatás
```bash
# Eredmények mappája
mkdir -p user_data/backtest_results/comparison_2025

# CryptoFrog
freqtrade backtesting \
  --strategy CryptoFrog \
  --timeframe 5m \
  --timerange 20250901-20251116 \
  --max-open-trades 6 \
  --stake-amount unlimited \
  --starting-balance 10000 \
  --breakdown month \
  --export trades \
  --export-filename user_data/backtest_results/comparison_2025/cryptofrog.json

# NFI (ugyanazokkal a paraméterekkel)
freqtrade backtesting \
  --strategy NostalgiaForInfinityNextGen \
  --timeframe 15m \
  --timerange 20250901-20251116 \
  --max-open-trades 6 \
  --stake-amount unlimited \
  --starting-balance 10000 \
  --breakdown month \
  --export trades \
  --export-filename user_data/backtest_results/comparison_2025/nfi.json
```

### Eredmények Összehasonlítása
```bash
# Terminal output összehasonlítás
echo "=== CryptoFrog Results ===" && \
freqtrade backtesting-show -c user_data/backtest_results/comparison_2025/cryptofrog.json && \
echo "" && \
echo "=== NFI Results ===" && \
freqtrade backtesting-show -c user_data/backtest_results/comparison_2025/nfi.json
```

---

## 🐳 DOCKER HASZNÁLAT (Ha telepítve van)

### Adat letöltés Dockerrel
```bash
docker run --rm \
  -v /home/user/freqtrade-strategies:/strategies:ro \
  -v freqtrade_user_data:/freqtrade/user_data \
  freqtradeorg/freqtrade:latest \
  download-data \
  --exchange bybit \
  --pairs BTC/USDT ETH/USDT SOL/USDT \
  --timeframes 5m 15m 1h 1d \
  --timerange 20250901-20251116
```

### Backtest Dockerrel
```bash
# CryptoFrog
docker run --rm \
  -v /home/user/freqtrade-strategies/strategies/CryptoFrog:/freqtrade/user_data/strategies:ro \
  -v freqtrade_user_data:/freqtrade/user_data \
  freqtradeorg/freqtrade:latest \
  backtesting \
  --strategy CryptoFrog \
  --timeframe 5m \
  --timerange 20250901-20251116 \
  --max-open-trades 6 \
  --stake-amount unlimited

# NFI
docker run --rm \
  -v /home/user/freqtrade-strategies/strategies/NostalgiaForInfinityNextGen:/freqtrade/user_data/strategies:ro \
  -v freqtrade_user_data:/freqtrade/user_data \
  freqtradeorg/freqtrade:latest \
  backtesting \
  --strategy NostalgiaForInfinityNextGen \
  --timeframe 15m \
  --timerange 20250901-20251116 \
  --max-open-trades 6 \
  --stake-amount unlimited
```

---

## ✅ DÖNTÉSI KRITÉRIUMOK

### CryptoFrog Jó, ha:
```
✅ Sharpe Ratio > 1.5
✅ Max Drawdown < 15%
✅ Win Rate > 55%
✅ Total Trades > 100 (2.5 hónapra)
✅ Profit Factor > 1.4
✅ Calmar Ratio > 2.0
```

### NFI Jó, ha:
```
✅ Sharpe Ratio > 1.8
✅ Max Drawdown < 12%
✅ Win Rate > 60%
✅ Total Trades > 60 (2.5 hónapra)
✅ Profit Factor > 1.6
✅ Calmar Ratio > 2.5
```

---

## 🚨 FONTOS MEGJEGYZÉSEK

1. **Backtest ≠ Jövő Teljesítmény**
   - Történelmi adatokon működik, de a jövő eltérhet
   - Mindig dry-run tesztelj élő piacra váltás előtt

2. **Overfitting Veszély**
   - Ne hyperopt-olj túl sokat ugyanazon az adaton
   - Használj train/test split-et (pl. 70/30)

3. **Spread & Slippage**
   - Backtest ideális feltételezésekkel számol
   - Valós piacok spread-et és slippage-et hoznak

4. **Párhuzamos Stratégiák**
   - Ha mindkettőt futtatod, oszd el a tőkét
   - Kerüld az overlapping trade-eket

---

## 📞 Hibaelhárítás

### Probléma: "Strategy not found"
```bash
# Ellenőrizd a stratégia fájlt
freqtrade list-strategies
```

### Probléma: "No data available"
```bash
# Ellenőrizd az adatokat
ls -la user_data/data/bybit/
freqtrade list-data --datadir user_data/data/bybit
```

### Probléma: "Insufficient data"
```bash
# Töltsd le újra a hiányzó timeframe-eket
freqtrade download-data --help
```

---

**Következő lépés:** Futtasd a backtesteket, majd hozz létre egy `BACKTEST_RESULTS.md` fájlt az eredményekkel!

**Készítette:** Claude Code AI
**Dátum:** 2025-11-16
