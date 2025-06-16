#!/bin/bash

# Ref Finance Internal Arbitrage Scanner
# Finds arbitrage opportunities between different pool types on Ref Finance

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_banner() {
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║              REF FINANCE INTERNAL ARBITRAGE SCANNER                      ║
    ║               🔄 Find Price Differences Within One DEX                    ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo "  $0 <token1> <token2>     # Find arbitrage between token pair"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 wrap.near usdc.fakes.testnet"
    echo "  $0 wrap.near dai.fakes.testnet"
    echo "  $0 token.skyward.near wrap.near"
    echo ""
    echo -e "${BLUE}Common NEAR tokens:${NC}"
    echo "  • wrap.near (Wrapped NEAR)"
    echo "  • usdc.fakes.testnet (USDC)"
    echo "  • dai.fakes.testnet (DAI)"
    echo "  • token.skyward.near (SKYWARD)"
}

check_dependencies() {
    local missing=()
    for cmd in jq curl bc; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing: ${missing[*]}${NC}"
        echo "Install: brew install jq bc"
        exit 1
    fi
}

# Get pool count from Ref Finance
get_pool_count() {
    echo -e "${BLUE}📊 Getting total pool count...${NC}" >&2
    
    local response=$(curl -s -X POST https://rpc.mainnet.near.org \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","id":"1","method":"query","params":{"request_type":"call_function","finality":"final","account_id":"v2.ref-finance.near","method_name":"get_number_of_pools","args_base64":"e30="}}')
    
    local result=$(echo "$response" | jq -r '.result.result // empty' 2>/dev/null)
    if [ -n "$result" ]; then
        local count=$(echo "$result" | jq -r 'map(. as $num | [$num] | implode) | join("")' 2>/dev/null)
        if [[ "$count" =~ ^[0-9]+$ ]]; then
            echo -e "${GREEN}✅ Total pools: $count${NC}" >&2
            echo "$count"
            return 0
        fi
    fi
    
    echo -e "${RED}❌ Could not get pool count${NC}" >&2
    return 1
}

# Get specific pool details
get_pool_details() {
    local pool_id="$1"
    
    local pool_args="{\"pool_id\": $pool_id}"
    local args_base64=$(echo "$pool_args" | base64)
    
    local response=$(curl -s -X POST https://rpc.mainnet.near.org \
        -H "Content-Type: application/json" \
        -d "{\"jsonrpc\":\"2.0\",\"id\":\"1\",\"method\":\"query\",\"params\":{\"request_type\":\"call_function\",\"finality\":\"final\",\"account_id\":\"v2.ref-finance.near\",\"method_name\":\"get_pool\",\"args_base64\":\"$args_base64\"}}")
    
    local result=$(echo "$response" | jq -r '.result.result // empty' 2>/dev/null)
    if [ -n "$result" ] && [ "$result" != "null" ]; then
        local decoded=$(echo "$result" | jq -r 'map(. as $num | [$num] | implode) | join("")' 2>/dev/null)
        echo "$decoded"
        return 0
    fi
    
    return 1
}

# Calculate AMM price from reserves
calculate_price() {
    local reserve1="$1"
    local reserve2="$2"
    local decimals1="${3:-24}"
    local decimals2="${4:-6}"
    
    # Convert reserves to human readable (remove decimals)
    local human_reserve1=$(echo "scale=6; $reserve1 / 10^$decimals1" | bc -l)
    local human_reserve2=$(echo "scale=6; $reserve2 / 10^$decimals2" | bc -l)
    
    # Calculate price (token2 per token1)
    if [ "$(echo "$human_reserve1 > 0" | bc)" -eq 1 ]; then
        local price=$(echo "scale=6; $human_reserve2 / $human_reserve1" | bc -l)
        echo "$price"
        return 0
    fi
    
    echo "0"
    return 1
}

# Find pools with specific token pair
find_token_pair_pools() {
    local token1="$1"
    local token2="$2"
    
    echo -e "${PURPLE}🔍 SCANNING FOR $token1/$token2 POOLS${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    
    local pool_count=$(get_pool_count)
    if [ -z "$pool_count" ]; then
        return 1
    fi
    
    local matching_pools=()
    local pool_prices=()
    local pool_types=()
    local pool_reserves=()
    
    # Limit search to first 100 pools for demo (can be increased)
    local search_limit=$((pool_count > 100 ? 100 : pool_count))
    echo -e "${BLUE}📊 Searching first $search_limit pools...${NC}"
    
    for ((i=0; i<search_limit; i++)); do
        if [ $((i % 20)) -eq 0 ]; then
            echo -e "${CYAN}  Progress: $i/$search_limit pools checked...${NC}"
        fi
        
        local pool_data=$(get_pool_details "$i")
        if [ -n "$pool_data" ]; then
            # Check if pool contains our target tokens
            if echo "$pool_data" | grep -q "\"$token1\"" && echo "$pool_data" | grep -q "\"$token2\""; then
                echo -e "${GREEN}✅ Found matching pool $i${NC}"
                
                # Extract pool type
                local pool_type=$(echo "$pool_data" | grep -o '"pool_kind":"[^"]*"' | cut -d'"' -f4)
                
                # Extract token order and reserves
                local token_list=$(echo "$pool_data" | grep -o '"token_account_ids":\[[^]]*\]')
                local amounts_list=$(echo "$pool_data" | grep -o '"amounts":\[[^]]*\]')
                
                if [ -n "$amounts_list" ]; then
                    # Parse reserves (simplified - assumes 2-token pool)
                    local reserves=$(echo "$amounts_list" | grep -o '[0-9]\+' | head -2)
                    local reserve1=$(echo "$reserves" | sed -n '1p')
                    local reserve2=$(echo "$reserves" | sed -n '2p')
                    
                    if [ -n "$reserve1" ] && [ -n "$reserve2" ] && [ "$reserve1" != "0" ] && [ "$reserve2" != "0" ]; then
                        # Determine token order
                        local first_token=$(echo "$token_list" | grep -o '"[^"]*\.near"' | head -1 | tr -d '"')
                        local price
                        
                        if [ "$first_token" = "$token1" ]; then
                            price=$(calculate_price "$reserve1" "$reserve2")
                        else
                            price=$(calculate_price "$reserve2" "$reserve1")
                        fi
                        
                        if [ "$price" != "0" ]; then
                            matching_pools+=("$i")
                            pool_prices+=("$price")
                            pool_types+=("$pool_type")
                            pool_reserves+=("$reserve1:$reserve2")
                            
                            echo -e "${BLUE}    Pool Type: $pool_type${NC}"
                            echo -e "${BLUE}    Price: 1 $token1 = $price $token2${NC}"
                            echo -e "${BLUE}    Reserves: $reserve1 : $reserve2${NC}"
                        fi
                    fi
                fi
            fi
        fi
    done
    
    echo ""
    echo -e "${CYAN}📊 FOUND ${#matching_pools[@]} POOLS WITH $token1/$token2${NC}"
    
    if [ ${#matching_pools[@]} -lt 2 ]; then
        echo -e "${YELLOW}⚠️  Need at least 2 pools for arbitrage analysis${NC}"
        return 1
    fi
    
    # Analyze arbitrage opportunities
    analyze_arbitrage_opportunities "$token1" "$token2" "${matching_pools[@]}"
    
    return 0
}

# Analyze arbitrage opportunities between pools
analyze_arbitrage_opportunities() {
    local token1="$1"
    local token2="$2"
    shift 2
    local pools=("$@")
    
    echo ""
    echo -e "${PURPLE}⚡ ARBITRAGE ANALYSIS${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    
    # Find min and max prices
    local min_price=""
    local max_price=""
    local min_pool=""
    local max_pool=""
    local min_type=""
    local max_type=""
    
    for i in "${!pools[@]}"; do
        local pool_id="${pools[$i]}"
        local price="${pool_prices[$i]}"
        local pool_type="${pool_types[$i]}"
        
        if [ -z "$min_price" ] || [ "$(echo "$price < $min_price" | bc)" -eq 1 ]; then
            min_price="$price"
            min_pool="$pool_id"
            min_type="$pool_type"
        fi
        
        if [ -z "$max_price" ] || [ "$(echo "$price > $max_price" | bc)" -eq 1 ]; then
            max_price="$price"
            max_pool="$pool_id"
            max_type="$pool_type"
        fi
    done
    
    # Calculate arbitrage opportunity
    if [ -n "$min_price" ] && [ -n "$max_price" ] && [ "$min_price" != "$max_price" ]; then
        local price_diff=$(echo "scale=6; $max_price - $min_price" | bc -l)
        local profit_percent=$(echo "scale=2; ($price_diff / $min_price) * 100" | bc -l)
        
        echo -e "${GREEN}🎯 ARBITRAGE OPPORTUNITY FOUND!${NC}"
        echo "┌─────────────────────────────────────────────────────────────────────┐"
        printf "│ ${CYAN}%-15s${NC} │ ${BLUE}%-20s${NC} │ ${YELLOW}%-25s${NC} │\n" "Action" "Pool" "Price"
        echo "├─────────────────────────────────────────────────────────────────────┤"
        printf "│ ${GREEN}%-15s${NC} │ ${BLUE}%-20s${NC} │ ${YELLOW}%-25s${NC} │\n" "BUY $token1" "Pool $min_pool ($min_type)" "1 $token1 = $min_price $token2"
        printf "│ ${RED}%-15s${NC} │ ${BLUE}%-20s${NC} │ ${YELLOW}%-25s${NC} │\n" "SELL $token1" "Pool $max_pool ($max_type)" "1 $token1 = $max_price $token2"
        echo "└─────────────────────────────────────────────────────────────────────┘"
        
        echo ""
        echo -e "${YELLOW}💰 PROFIT ANALYSIS:${NC}"
        echo "  • Price difference: $price_diff $token2 per $token1"
        echo "  • Profit percentage: $profit_percent%"
        echo "  • Strategy: Buy in Pool $min_pool, Sell in Pool $max_pool"
        
        # Calculate example profit
        local example_amount="1000"
        local profit_amount=$(echo "scale=2; $example_amount * $price_diff" | bc -l)
        echo "  • Example: Trade $example_amount $token1 → Profit: $profit_amount $token2"
        
        if [ "$(echo "$profit_percent > 1" | bc)" -eq 1 ]; then
            echo -e "${GREEN}🚨 HIGH PROFIT OPPORTUNITY (>1%)${NC}"
        elif [ "$(echo "$profit_percent > 0.1" | bc)" -eq 1 ]; then
            echo -e "${YELLOW}💡 Moderate opportunity (>0.1%)${NC}"
        else
            echo -e "${BLUE}📊 Small spread (<0.1%)${NC}"
        fi
        
    else
        echo -e "${BLUE}📊 No significant price differences found${NC}"
        echo "All pools are efficiently priced!"
    fi
    
    # Show all pool prices for comparison
    echo ""
    echo -e "${CYAN}📊 ALL POOL PRICES:${NC}"
    for i in "${!pools[@]}"; do
        local pool_id="${pools[$i]}"
        local price="${pool_prices[$i]}"
        local pool_type="${pool_types[$i]}"
        printf "  Pool %-3s (%-12s): 1 $token1 = %-8s $token2\n" "$pool_id" "$pool_type" "$price"
    done
}

# Main function
main() {
    print_banner
    
    if [ $# -ne 2 ]; then
        show_usage
        exit 1
    fi
    
    check_dependencies
    
    local token1="$1"
    local token2="$2"
    
    echo -e "${BLUE}🎯 Analyzing arbitrage opportunities for $token1/$token2${NC}"
    echo -e "${BLUE}📅 Analysis time: $(date)${NC}"
    echo ""
    
    if find_token_pair_pools "$token1" "$token2"; then
        echo ""
        echo -e "${GREEN}✅ Arbitrage analysis complete!${NC}"
    else
        echo ""
        echo -e "${RED}❌ Could not find sufficient pools for analysis${NC}"
        echo -e "${BLUE}💡 Try common pairs like:${NC}"
        echo "  • wrap.near usdc.fakes.testnet"
        echo "  • wrap.near dai.fakes.testnet"
        echo "  • token.skyward.near wrap.near"
    fi
    
    echo ""
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}${BOLD}       Ref Finance Internal Arbitrage Scanner - Analysis Complete         ${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════════════${NC}"
}

# Execute main function
main "$@"