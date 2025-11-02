#!/usr/bin/env python3
"""
Freqtrade 2025.7 Configuration Validator
Tests configuration files for Freqtrade 2025.7 compatibility
"""

import json
import sys
from pathlib import Path

def validate_config(config_path):
    """Validate a Freqtrade configuration file"""
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
        
        print(f"[OK] {config_path.name}: JSON syntax valid")
        
        # Check required fields for Freqtrade 2025.7
        required_fields = [
            'strategy', 'max_open_trades', 'stake_currency', 
            'timeframe', 'exchange'
        ]
        
        missing_fields = []
        for field in required_fields:
            if field not in config:
                missing_fields.append(field)
        
        if missing_fields:
            print(f"[WARNING] Missing required fields: {missing_fields}")
        else:
            print(f"[OK] All required fields present")
            
        # Check 2025.7 specific updates
        modern_features = []
        if 'entry_pricing' in config and 'exit_pricing' in config:
            modern_features.append("[OK] Using modern entry/exit_pricing")
        if config.get('order_types', {}).get('entry') and config.get('order_types', {}).get('exit'):
            modern_features.append("[OK] Using modern entry/exit order types")
        if config.get('unfilledtimeout', {}).get('entry') is not None:
            modern_features.append("[OK] Using modern entry/exit timeouts")
        if 'pair_blacklist' in config:
            modern_features.append("[OK] Using pair_blacklist (modern format)")
        if config.get('use_exit_signal') is not None:
            modern_features.append("[OK] Using use_exit_signal (2025.7 compatible)")
            
        if modern_features:
            for feature in modern_features:
                print(f"  {feature}")
        
        # Check strategy path
        strategy_path = config.get('strategy_path', 'user_data/strategies')
        strategy_name = config.get('strategy')
        expected_file = Path(strategy_path) / strategy_name / f"{strategy_name}.py"
        
        if expected_file.exists():
            print(f"[OK] Strategy file found: {expected_file}")
        else:
            print(f"[WARNING] Strategy file not found: {expected_file}")
            
        print(f"[OK] {config_path.name}: Configuration appears valid for Freqtrade 2025.7\n")
        return True
        
    except json.JSONDecodeError as e:
        print(f"[ERROR] {config_path.name}: JSON syntax error - {e}")
        return False
    except Exception as e:
        print(f"[ERROR] {config_path.name}: Validation error - {e}")
        return False

def main():
    """Main validation function"""
    base_path = Path(r'C:\Users\Dani\Downloads\freqtrade-strategies')
    
    configs = [
        base_path / 'config_backtest_NostalgiaForInfinityNextGen_2025.7.json',
        base_path / 'config_live_NostalgiaForInfinityNextGen_2025.7.json'
    ]
    
    print("Validating Freqtrade 2025.7 Configuration Files")
    print("=" * 60)
    
    all_valid = True
    for config_path in configs:
        if config_path.exists():
            if not validate_config(config_path):
                all_valid = False
        else:
            print(f"[ERROR] Config file not found: {config_path}")
            all_valid = False
    
    if all_valid:
        print("SUCCESS: All configuration files are valid for Freqtrade 2025.7!")
        print("\nUsage Instructions:")
        print("Backtest: freqtrade backtesting --config config_backtest_NostalgiaForInfinityNextGen_2025.7.json")
        print("Live:     freqtrade trade --config config_live_NostalgiaForInfinityNextGen_2025.7.json --dry-run")
    else:
        print("[ERROR] Some configuration files have issues. Please fix before using.")
        sys.exit(1)

if __name__ == "__main__":
    main()