#!/bin/bash

# ============================================================================
# SCRIPT D'EXÉCUTION DE TESTS PERSONNALISÉS
# ============================================================================
# Lit test_config.txt et exécute les tests définis
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

PHILO_BIN="./philo"
CONFIG_FILE="test_config.txt"
LOG_DIR="custom_test_logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CURRENT_LOG_DIR="${LOG_DIR}/${TIMESTAMP}"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "============================================================================"
    echo "$1"
    echo "============================================================================"
    echo -e "${NC}"
}

print_test() {
    echo -e "\n${YELLOW}[TEST $((TOTAL_TESTS+1))]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASSED_TESTS++))
}

print_failure() {
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED_TESTS++))
}

setup() {
    print_header "SETUP - Tests personnalisés depuis $CONFIG_FILE"
    
    if [ ! -f "$PHILO_BIN" ]; then
        echo -e "${RED}ERREUR: Le binaire $PHILO_BIN n'existe pas!${NC}"
        echo "Compilation en cours..."
        make re
        if [ ! -f "$PHILO_BIN" ]; then
            echo -e "${RED}ERREUR: Échec de la compilation!${NC}"
            exit 1
        fi
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}ERREUR: Le fichier de configuration $CONFIG_FILE n'existe pas!${NC}"
        exit 1
    fi
    
    if ! command -v valgrind &> /dev/null; then
        echo -e "${YELLOW}WARNING: valgrind n'est pas installé!${NC}"
        echo "Seuls les tests 'quick' seront exécutés."
        VALGRIND_AVAILABLE=false
    else
        VALGRIND_AVAILABLE=true
    fi
    
    mkdir -p "$CURRENT_LOG_DIR"
    mkdir -p "${CURRENT_LOG_DIR}/valgrind"
    mkdir -p "${CURRENT_LOG_DIR}/helgrind"
    mkdir -p "${CURRENT_LOG_DIR}/quick"
    
    echo -e "${GREEN}✓ Setup terminé${NC}"
    echo -e "Logs directory: ${CYAN}$CURRENT_LOG_DIR${NC}\n"
}

run_valgrind_test() {
    local test_name="$1"
    local args="$2"
    local timeout_val="$3"
    local log_file="${CURRENT_LOG_DIR}/valgrind/${test_name}.log"
    
    ((TOTAL_TESTS++))
    print_test "Valgrind - $test_name"
    echo "  Arguments: $args"
    echo "  Timeout: $timeout_val"
    
    if [ "$VALGRIND_AVAILABLE" = false ]; then
        echo -e "  ${YELLOW}SKIPPED (valgrind non disponible)${NC}"
        return
    fi
    
    timeout "$timeout_val" valgrind \
        --leak-check=full \
        --show-leak-kinds=all \
        --track-origins=yes \
        --verbose \
        --log-file="$log_file" \
        $PHILO_BIN $args &> /dev/null
    
    local leaks=$(grep "definitely lost" "$log_file" | grep -v "0 bytes")
    local invalid=$(grep -E "Invalid read|Invalid write" "$log_file")
    
    if [ -n "$leaks" ] || [ -n "$invalid" ]; then
        print_failure
        echo "  Voir: $log_file"
    else
        print_success
    fi
}

run_helgrind_test() {
    local test_name="$1"
    local args="$2"
    local timeout_val="$3"
    local log_file="${CURRENT_LOG_DIR}/helgrind/${test_name}.log"
    
    ((TOTAL_TESTS++))
    print_test "Helgrind - $test_name"
    echo "  Arguments: $args"
    echo "  Timeout: $timeout_val"
    
    if [ "$VALGRIND_AVAILABLE" = false ]; then
        echo -e "  ${YELLOW}SKIPPED (valgrind non disponible)${NC}"
        return
    fi
    
    timeout "$timeout_val" valgrind \
        --tool=helgrind \
        --verbose \
        --log-file="$log_file" \
        $PHILO_BIN $args &> /dev/null
    
    local data_races=$(grep "Possible data race" "$log_file")
    
    if [ -n "$data_races" ]; then
        print_failure
        echo "  Voir: $log_file"
    else
        print_success
    fi
}

run_quick_test() {
    local test_name="$1"
    local args="$2"
    local timeout_val="$3"
    local log_file="${CURRENT_LOG_DIR}/quick/${test_name}.log"
    
    ((TOTAL_TESTS++))
    print_test "Quick - $test_name"
    echo "  Arguments: $args"
    echo "  Timeout: $timeout_val"
    
    timeout "$timeout_val" $PHILO_BIN $args > "$log_file" 2>&1
    local exit_code=$?
    
    if [ $exit_code -eq 0 ] || [ $exit_code -eq 124 ]; then
        print_success
    else
        print_failure
        echo "  Exit code: $exit_code"
        echo "  Voir: $log_file"
    fi
}

parse_and_run_tests() {
    print_header "EXÉCUTION DES TESTS"
    
    echo -e "${CYAN}Lecture de $CONFIG_FILE...${NC}\n"
    
    local line_num=0
    while IFS='|' read -r name args timeout type; do
        ((line_num++))
        
        # Ignorer les commentaires et lignes vides
        [[ "$name" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$name" ]] && continue
        
        # Trim whitespace
        name=$(echo "$name" | xargs)
        args=$(echo "$args" | xargs)
        timeout=$(echo "$timeout" | xargs)
        type=$(echo "$type" | xargs)
        
        # Valider le type
        case "$type" in
            valgrind)
                run_valgrind_test "$name" "$args" "$timeout"
                ;;
            helgrind)
                run_helgrind_test "$name" "$args" "$timeout"
                ;;
            quick)
                run_quick_test "$name" "$args" "$timeout"
                ;;
            *)
                echo -e "${RED}Ligne $line_num: Type invalide '$type' (valgrind/helgrind/quick attendu)${NC}"
                ;;
        esac
        
    done < "$CONFIG_FILE"
}

print_summary() {
    print_header "RÉSUMÉ DES TESTS"
    
    echo -e "Total de tests:  ${BOLD}$TOTAL_TESTS${NC}"
    echo -e "Tests réussis:   ${GREEN}${BOLD}$PASSED_TESTS${NC}"
    echo -e "Tests échoués:   ${RED}${BOLD}$FAILED_TESTS${NC}"
    echo -e "\nLogs: ${CYAN}$CURRENT_LOG_DIR${NC}\n"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}${BOLD}🎉 TOUS LES TESTS SONT PASSÉS ! 🎉${NC}\n"
        return 0
    else
        echo -e "${RED}${BOLD}❌ CERTAINS TESTS ONT ÉCHOUÉ ❌${NC}\n"
        return 1
    fi
}

main() {
    setup
    parse_and_run_tests
    print_summary
    
    echo -e "${CYAN}Pour analyser les résultats en détail:${NC}"
    echo -e "  ${YELLOW}./analyze_results.sh $CURRENT_LOG_DIR${NC}\n"
    
    exit $?
}

main

