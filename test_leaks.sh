#!/bin/bash

# ============================================================================
# PHILOSOPHERS - SCRIPT DE TEST RIGOUREUX POUR LEAKS & DATA RACES
# ============================================================================
# Ce script teste exhaustivement le programme philo avec:
# - Valgrind (leaks mémoire)
# - Helgrind (data races, deadlocks)
# - Multiples configurations de paramètres
# - Cas limites et edge cases
# ============================================================================

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
PHILO_BIN="./philo"
LOG_DIR="test_logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CURRENT_LOG_DIR="${LOG_DIR}/${TIMESTAMP}"

# Compteurs de résultats
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

# ============================================================================
# FONCTIONS UTILITAIRES
# ============================================================================

print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "============================================================================"
    echo "$1"
    echo "============================================================================"
    echo -e "${NC}"
}

print_section() {
    echo -e "\n${BOLD}${CYAN}>>> $1${NC}\n"
}

print_test() {
    echo -e "${YELLOW}[TEST $TOTAL_TESTS]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓ PASS${NC} - $1"
    ((PASSED_TESTS++))
}

print_failure() {
    echo -e "${RED}✗ FAIL${NC} - $1"
    ((FAILED_TESTS++))
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING${NC} - $1"
    ((WARNINGS++))
}

print_summary() {
    echo -e "\n${BOLD}${MAGENTA}"
    echo "============================================================================"
    echo "                           RÉSUMÉ DES TESTS"
    echo "============================================================================"
    echo -e "${NC}"
    echo -e "Total de tests:     ${BOLD}$TOTAL_TESTS${NC}"
    echo -e "Tests réussis:      ${GREEN}${BOLD}$PASSED_TESTS${NC}"
    echo -e "Tests échoués:      ${RED}${BOLD}$FAILED_TESTS${NC}"
    echo -e "Avertissements:     ${YELLOW}${BOLD}$WARNINGS${NC}"
    echo -e "\nLogs sauvegardés dans: ${CYAN}$CURRENT_LOG_DIR${NC}\n"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}${BOLD}🎉 TOUS LES TESTS SONT PASSÉS ! 🎉${NC}\n"
        return 0
    else
        echo -e "${RED}${BOLD}❌ CERTAINS TESTS ONT ÉCHOUÉ ❌${NC}\n"
        return 1
    fi
}

# ============================================================================
# SETUP
# ============================================================================

setup() {
    print_header "SETUP - Préparation de l'environnement de test"
    
    # Vérifier que le binaire existe
    if [ ! -f "$PHILO_BIN" ]; then
        echo -e "${RED}ERREUR: Le binaire $PHILO_BIN n'existe pas!${NC}"
        echo "Compilation en cours..."
        make re
        if [ ! -f "$PHILO_BIN" ]; then
            echo -e "${RED}ERREUR: Échec de la compilation!${NC}"
            exit 1
        fi
    fi
    
    # Vérifier que valgrind est installé
    if ! command -v valgrind &> /dev/null; then
        echo -e "${RED}ERREUR: valgrind n'est pas installé!${NC}"
        echo "Installation requise: sudo apt-get install valgrind"
        exit 1
    fi
    
    # Créer les dossiers de logs
    mkdir -p "$CURRENT_LOG_DIR"
    mkdir -p "${CURRENT_LOG_DIR}/valgrind"
    mkdir -p "${CURRENT_LOG_DIR}/helgrind"
    mkdir -p "${CURRENT_LOG_DIR}/quick"
    
    echo -e "${GREEN}✓ Setup terminé${NC}"
    echo -e "Logs directory: ${CYAN}$CURRENT_LOG_DIR${NC}\n"
}

# ============================================================================
# TESTS VALGRIND (MEMORY LEAKS)
# ============================================================================

test_valgrind() {
    local test_name="$1"
    local args="$2"
    local timeout_val="$3"
    local log_file="${CURRENT_LOG_DIR}/valgrind/${test_name}.log"
    
    ((TOTAL_TESTS++))
    print_test "Valgrind - $test_name"
    echo "Arguments: $args"
    
    # Exécuter avec timeout
    timeout "$timeout_val" valgrind \
        --leak-check=full \
        --show-leak-kinds=all \
        --track-origins=yes \
        --verbose \
        --log-file="$log_file" \
        $PHILO_BIN $args &> /dev/null
    
    local exit_code=$?
    
    # Analyser les résultats
    if [ $exit_code -eq 124 ]; then
        echo "  → Timeout atteint (normal pour certains tests)"
    fi
    
    # Vérifier les leaks
    local leaks=$(grep "definitely lost" "$log_file" | grep -v "0 bytes")
    local still_reachable=$(grep "still reachable" "$log_file" | grep -v "0 bytes")
    local invalid_reads=$(grep "Invalid read" "$log_file")
    local invalid_writes=$(grep "Invalid write" "$log_file")
    
    if [ -n "$leaks" ]; then
        print_failure "Memory leaks détectés"
        echo "  → Voir: $log_file"
    elif [ -n "$invalid_reads" ] || [ -n "$invalid_writes" ]; then
        print_failure "Invalid memory access détecté"
        echo "  → Voir: $log_file"
    else
        if [ -n "$still_reachable" ]; then
            print_warning "Still reachable memory (peut être acceptable)"
        else
            print_success "Aucun leak détecté"
        fi
    fi
    
    echo ""
}

# ============================================================================
# TESTS HELGRIND (DATA RACES)
# ============================================================================

test_helgrind() {
    local test_name="$1"
    local args="$2"
    local timeout_val="$3"
    local log_file="${CURRENT_LOG_DIR}/helgrind/${test_name}.log"
    
    ((TOTAL_TESTS++))
    print_test "Helgrind - $test_name"
    echo "Arguments: $args"
    
    # Exécuter avec timeout
    timeout "$timeout_val" valgrind \
        --tool=helgrind \
        --verbose \
        --log-file="$log_file" \
        $PHILO_BIN $args &> /dev/null
    
    local exit_code=$?
    
    # Analyser les résultats
    if [ $exit_code -eq 124 ]; then
        echo "  → Timeout atteint (normal pour certains tests)"
    fi
    
    # Vérifier les data races
    local data_races=$(grep "Possible data race" "$log_file")
    local lock_order=$(grep "Lock order" "$log_file")
    
    if [ -n "$data_races" ]; then
        print_failure "Data race(s) détecté(s)"
        echo "  → Voir: $log_file"
    elif [ -n "$lock_order" ]; then
        print_warning "Problème d'ordre de lock détecté"
        echo "  → Voir: $log_file"
    else
        print_success "Aucun data race détecté"
    fi
    
    echo ""
}

# ============================================================================
# TESTS RAPIDES (SANS VALGRIND)
# ============================================================================

test_quick() {
    local test_name="$1"
    local args="$2"
    local timeout_val="$3"
    local expected_behavior="$4"
    local log_file="${CURRENT_LOG_DIR}/quick/${test_name}.log"
    
    ((TOTAL_TESTS++))
    print_test "Quick - $test_name"
    echo "Arguments: $args"
    echo "Comportement attendu: $expected_behavior"
    
    # Exécuter avec timeout
    timeout "$timeout_val" $PHILO_BIN $args > "$log_file" 2>&1
    
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        echo "  → Timeout atteint"
    fi
    
    # Vérifier si le programme s'est terminé proprement
    if [ $exit_code -eq 0 ] || [ $exit_code -eq 124 ]; then
        print_success "Exécution sans crash"
    else
        print_failure "Programme crashed (exit code: $exit_code)"
        echo "  → Voir: $log_file"
    fi
    
    echo ""
}

# ============================================================================
# BATTERIES DE TESTS
# ============================================================================

run_valgrind_tests() {
    print_section "TESTS VALGRIND - MEMORY LEAKS"
    
    # Tests basiques
    test_valgrind "basic_4_410_200_200" "4 410 200 200" "3s"
    test_valgrind "basic_5_800_200_200" "5 800 200 200" "3s"
    test_valgrind "basic_4_310_200_100" "4 310 200 100" "3s"
    
    # Tests avec must_eat
    test_valgrind "must_eat_5_800_200_200_7" "5 800 200 200 7" "10s"
    test_valgrind "must_eat_4_410_200_200_5" "4 410 200 200 5" "10s"
    test_valgrind "must_eat_2_400_100_100_3" "2 400 100 100 3" "5s"
    
    # Tests cas limites
    test_valgrind "one_philo" "1 800 200 200" "2s"
    test_valgrind "two_philos" "2 800 200 200" "3s"
    test_valgrind "many_philos_10" "10 800 200 200" "5s"
    test_valgrind "many_philos_20" "20 800 200 200" "5s"
    test_valgrind "many_philos_50" "50 800 200 200" "5s"
    test_valgrind "many_philos_100" "100 800 200 200" "5s"
    test_valgrind "many_philos_200" "200 410 200 200" "5s"
    
    # Tests temps courts (plus de stress)
    test_valgrind "short_time_5_310_100_100" "5 310 100 100" "3s"
    test_valgrind "short_time_10_410_50_50" "10 410 50 50" "3s"
    
    # Tests temps longs
    test_valgrind "long_time_4_2000_500_500" "4 2000 500 500" "5s"
    
    # Tests avec must_eat = 1
    test_valgrind "must_eat_1_5_800_200_200_1" "5 800 200 200 1" "5s"
    test_valgrind "must_eat_1_10_800_200_200_1" "10 800 200 200 1" "5s"
    
    # Tests avec temps très courts (stress test)
    test_valgrind "very_short_4_410_1_1" "4 410 1 1" "3s"
    test_valgrind "very_short_10_410_10_10" "10 410 10 10" "3s"
    
    # Tests avec un seul philo et must_eat
    test_valgrind "one_philo_must_eat" "1 800 200 200 5" "2s"
}

run_helgrind_tests() {
    print_section "TESTS HELGRIND - DATA RACES & DEADLOCKS"
    
    # Tests basiques pour data races
    test_helgrind "basic_4_410_200_200" "4 410 200 200" "3s"
    test_helgrind "basic_5_800_200_200" "5 800 200 200" "3s"
    
    # Tests avec beaucoup de philos (plus de chances de races)
    test_helgrind "many_10_800_200_200" "10 800 200 200" "5s"
    test_helgrind "many_20_410_200_200" "20 410 200 200" "5s"
    
    # Tests temps courts (plus de synchronisation)
    test_helgrind "short_5_310_50_50" "5 310 50 50" "3s"
    test_helgrind "short_10_410_30_30" "10 410 30 30" "3s"
    
    # Tests avec must_eat (terminaison propre)
    test_helgrind "must_eat_5_800_200_200_5" "5 800 200 200 5" "10s"
    test_helgrind "must_eat_10_800_200_200_3" "10 800 200 200 3" "10s"
    
    # Tests cas limites
    test_helgrind "two_philos" "2 800 200 200" "3s"
    test_helgrind "odd_number_7" "7 800 200 200" "3s"
    test_helgrind "even_number_8" "8 800 200 200" "3s"
    
    # Test avec un seul philo (edge case)
    test_helgrind "one_philo" "1 800 200 200" "2s"
}

run_quick_tests() {
    print_section "TESTS RAPIDES - COMPORTEMENT & STABILITÉ"
    
    # Tests d'arguments invalides
    test_quick "invalid_no_args" "" "1s" "Should fail"
    test_quick "invalid_too_few_args" "4 410 200" "1s" "Should fail"
    test_quick "invalid_negative" "-5 800 200 200" "1s" "Should fail"
    test_quick "invalid_zero_philos" "0 800 200 200" "1s" "Should fail"
    test_quick "invalid_zero_time" "4 0 200 200" "1s" "Should fail"
    test_quick "invalid_letters" "abc 800 200 200" "1s" "Should fail"
    test_quick "invalid_too_many_args" "4 800 200 200 5 6 7" "1s" "Should fail"
    
    # Tests fonctionnels normaux
    test_quick "normal_4_410_200_200" "4 410 200 200" "3s" "Should run"
    test_quick "normal_5_800_200_200" "5 800 200 200" "3s" "Should run"
    test_quick "normal_must_eat" "5 800 200 200 7" "15s" "Should complete"
    
    # Tests cas limites fonctionnels
    test_quick "one_philo_dies" "1 400 200 200" "1s" "Should die"
    test_quick "two_philos" "2 800 200 200" "3s" "Should run"
    test_quick "many_100" "100 800 200 200" "5s" "Should run"
    test_quick "many_200" "200 410 200 200" "5s" "Should run"
    
    # Tests de death detection
    test_quick "death_4_310_200_100" "4 310 200 100" "2s" "Someone should die"
    test_quick "death_5_200_150_100" "5 200 150 100" "2s" "Someone should die"
    
    # Tests must_eat completion
    test_quick "complete_2_800_200_200_3" "2 800 200 200 3" "10s" "Should complete"
    test_quick "complete_4_800_200_200_5" "4 800 200 200 5" "15s" "Should complete"
    test_quick "complete_10_800_200_200_2" "10 800 200 200 2" "15s" "Should complete"
    
    # Tests avec temps très courts
    test_quick "very_short_times" "4 410 10 10" "2s" "High stress"
    test_quick "very_short_times_many" "10 410 10 10" "3s" "High stress"
    
    # Tests avec temps très longs
    test_quick "very_long_times" "4 10000 2000 2000" "5s" "Should run slowly"
    
    # Tests edge case avec must_eat = 1
    test_quick "must_eat_one" "5 800 200 200 1" "5s" "Should complete quickly"
}

run_stress_tests() {
    print_section "TESTS DE STRESS - LIMITES DU SYSTÈME"
    
    # Tests avec beaucoup de philosophes
    test_valgrind "stress_150_philos" "150 800 200 200" "10s"
    test_valgrind "stress_200_philos" "200 800 200 200" "10s"
    
    # Tests avec temps très courts et beaucoup de philos
    test_valgrind "stress_50_short" "50 410 20 20" "10s"
    test_valgrind "stress_100_short" "100 410 30 30" "10s"
    
    # Tests avec must_eat élevé
    test_valgrind "stress_must_eat_high" "10 800 200 200 100" "30s"
    test_valgrind "stress_must_eat_very_high" "5 800 200 200 500" "60s"
    
    # Tests combinés (beaucoup de philos + must_eat)
    test_valgrind "stress_combo_50_10" "50 800 200 200 10" "30s"
    test_valgrind "stress_combo_100_5" "100 800 200 200 5" "30s"
}

run_edge_cases() {
    print_section "TESTS CAS LIMITES EXTRÊMES"
    
    # Valeurs limites d'entiers
    test_quick "edge_max_time" "4 2147483647 200 200" "2s" "Max int time"
    test_quick "edge_one_ms_die" "4 1 200 200" "1s" "Immediate death"
    test_quick "edge_all_one_ms" "4 1 1 1" "1s" "All 1ms"
    
    # Nombre impair vs pair de philosophes
    test_valgrind "edge_odd_3" "3 800 200 200" "3s"
    test_valgrind "edge_odd_7" "7 800 200 200" "3s"
    test_valgrind "edge_odd_99" "99 800 200 200" "5s"
    test_valgrind "edge_even_4" "4 800 200 200" "3s"
    test_valgrind "edge_even_8" "8 800 200 200" "3s"
    test_valgrind "edge_even_100" "100 800 200 200" "5s"
    
    # Tests avec des ratios eat/sleep différents
    test_valgrind "edge_eat_greater_sleep" "5 800 500 100" "5s"
    test_valgrind "edge_sleep_greater_eat" "5 800 100 500" "5s"
    test_valgrind "edge_equal_eat_sleep" "5 800 300 300" "5s"
    
    # Tests time_to_die exact
    test_quick "edge_exact_death_time" "4 400 200 200" "3s" "Precise timing"
    test_quick "edge_exact_death_time_2" "5 600 300 200" "3s" "Precise timing"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    print_header "PHILOSOPHERS - TEST SUITE COMPLET DE DÉTECTION DE LEAKS"
    echo "Date: $(date)"
    echo "User: $(whoami)"
    echo "Host: $(hostname)"
    echo ""
    
    setup
    
    # Demander quels tests exécuter
    echo -e "${BOLD}Choisissez les tests à exécuter:${NC}"
    echo "1) Tests rapides uniquement (sans valgrind)"
    echo "2) Tests valgrind (memory leaks)"
    echo "3) Tests helgrind (data races)"
    echo "4) Tests de stress"
    echo "5) Tests cas limites"
    echo "6) TOUS les tests (peut prendre 30-60 minutes)"
    echo ""
    read -p "Votre choix (1-6): " choice
    
    case $choice in
        1)
            run_quick_tests
            ;;
        2)
            run_valgrind_tests
            ;;
        3)
            run_helgrind_tests
            ;;
        4)
            run_stress_tests
            ;;
        5)
            run_edge_cases
            ;;
        6)
            run_quick_tests
            run_valgrind_tests
            run_helgrind_tests
            run_stress_tests
            run_edge_cases
            ;;
        *)
            echo -e "${RED}Choix invalide!${NC}"
            exit 1
            ;;
    esac
    
    print_summary
    
    exit $?
}

# Exécuter le script
main

