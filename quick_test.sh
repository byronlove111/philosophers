#!/bin/bash

# ============================================================================
# QUICK TEST SCRIPT - Tests rapides sans valgrind
# ============================================================================
# Pour tester rapidement le comportement du programme
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

PHILO="./philo"

print_test() {
    echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}[TEST]${NC} $1"
    echo -e "${CYAN}Args:${NC} $PHILO $2"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ OK${NC}"
    else
        echo -e "${RED}✗ FAILED${NC}"
    fi
}

run_test() {
    local description="$1"
    local args="$2"
    local timeout_val="$3"
    
    print_test "$description" "$args"
    
    timeout "$timeout_val" $PHILO $args
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        echo -e "\n${YELLOW}[TIMEOUT]${NC} Programme arrêté après $timeout_val"
    fi
    
    print_result $exit_code
}

echo -e "${BOLD}${BLUE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         PHILOSOPHERS - QUICK TEST SUITE                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Vérifier que le binaire existe
if [ ! -f "$PHILO" ]; then
    echo -e "${RED}ERREUR: $PHILO n'existe pas!${NC}"
    echo "Compilation..."
    make re
    if [ ! -f "$PHILO" ]; then
        echo -e "${RED}ERREUR: Échec de compilation!${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Binaire trouvé${NC}\n"

# ============================================================================
# TESTS DE BASE
# ============================================================================

echo -e "${BOLD}${MAGENTA}[SECTION 1] Tests de base${NC}\n"

run_test "Test basique - 4 philosophes, ne doit pas mourir" "4 410 200 200" "5s"
run_test "Test basique - 5 philosophes" "5 800 200 200" "5s"
run_test "Test avec temps courts" "4 310 200 100" "3s"

# ============================================================================
# TESTS AVEC MUST_EAT
# ============================================================================

echo -e "\n${BOLD}${MAGENTA}[SECTION 2] Tests avec must_eat (doit se terminer)${NC}\n"

run_test "Must eat - 5 philos mangent 7 fois" "5 800 200 200 7" "20s"
run_test "Must eat - 4 philos mangent 5 fois" "4 410 200 200 5" "15s"
run_test "Must eat - 2 philos mangent 3 fois" "2 800 200 200 3" "10s"
run_test "Must eat - 10 philos mangent 2 fois" "10 800 200 200 2" "15s"

# ============================================================================
# TESTS CAS LIMITES
# ============================================================================

echo -e "\n${BOLD}${MAGENTA}[SECTION 3] Tests cas limites${NC}\n"

run_test "Un seul philosophe (doit mourir)" "1 800 200 200" "2s"
run_test "Deux philosophes" "2 800 200 200" "5s"
run_test "Beaucoup de philosophes - 50" "50 800 200 200" "5s"
run_test "Beaucoup de philosophes - 100" "100 800 200 200" "5s"
run_test "Beaucoup de philosophes - 200" "200 410 200 200" "5s"

# ============================================================================
# TESTS DE MORT
# ============================================================================

echo -e "\n${BOLD}${MAGENTA}[SECTION 4] Tests de détection de mort${NC}\n"

run_test "Mort rapide - temps très court" "4 310 200 100" "3s"
run_test "Mort rapide - 5 philos" "5 200 150 100" "3s"
run_test "Mort imminente" "4 400 200 200" "3s"

# ============================================================================
# TESTS D'ARGUMENTS INVALIDES (doivent échouer)
# ============================================================================

echo -e "\n${BOLD}${MAGENTA}[SECTION 5] Tests d'arguments invalides (doivent échouer)${NC}\n"

echo -e "\n${YELLOW}[TEST]${NC} Pas d'arguments"
echo -e "${CYAN}Args:${NC} $PHILO"
$PHILO 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓ Erreur détectée correctement${NC}"
else
    echo -e "${RED}✗ Devrait échouer${NC}"
fi

echo -e "\n${YELLOW}[TEST]${NC} Arguments insuffisants"
echo -e "${CYAN}Args:${NC} $PHILO 4 410 200"
$PHILO 4 410 200 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓ Erreur détectée correctement${NC}"
else
    echo -e "${RED}✗ Devrait échouer${NC}"
fi

echo -e "\n${YELLOW}[TEST]${NC} Nombre négatif"
echo -e "${CYAN}Args:${NC} $PHILO -5 800 200 200"
$PHILO -5 800 200 200 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓ Erreur détectée correctement${NC}"
else
    echo -e "${RED}✗ Devrait échouer${NC}"
fi

echo -e "\n${YELLOW}[TEST]${NC} Zéro philosophe"
echo -e "${CYAN}Args:${NC} $PHILO 0 800 200 200"
$PHILO 0 800 200 200 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓ Erreur détectée correctement${NC}"
else
    echo -e "${RED}✗ Devrait échouer${NC}"
fi

echo -e "\n${YELLOW}[TEST]${NC} Temps zéro"
echo -e "${CYAN}Args:${NC} $PHILO 4 0 200 200"
$PHILO 4 0 200 200 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓ Erreur détectée correctement${NC}"
else
    echo -e "${RED}✗ Devrait échouer${NC}"
fi

echo -e "\n${YELLOW}[TEST]${NC} Arguments non numériques"
echo -e "${CYAN}Args:${NC} $PHILO abc 800 200 200"
$PHILO abc 800 200 200 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓ Erreur détectée correctement${NC}"
else
    echo -e "${RED}✗ Devrait échouer${NC}"
fi

# ============================================================================
# TESTS DE STRESS COURTS
# ============================================================================

echo -e "\n${BOLD}${MAGENTA}[SECTION 6] Tests de stress (courts)${NC}\n"

run_test "Temps très courts" "10 410 10 10" "3s"
run_test "Beaucoup de philos + must_eat" "50 800 200 200 5" "30s"
run_test "Stress test complet" "100 800 200 200 3" "30s"

# ============================================================================
# TESTS SPÉCIAUX
# ============================================================================

echo -e "\n${BOLD}${MAGENTA}[SECTION 7] Tests spéciaux${NC}\n"

run_test "Nombre impair de philos (7)" "7 800 200 200" "5s"
run_test "Nombre pair de philos (8)" "8 800 200 200" "5s"
run_test "Eat > Sleep" "5 800 500 100" "5s"
run_test "Sleep > Eat" "5 800 100 500" "5s"
run_test "Must eat = 1 (rapide)" "10 800 200 200 1" "10s"

# ============================================================================
# RÉSUMÉ
# ============================================================================

echo -e "\n${BOLD}${BLUE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    TESTS TERMINÉS                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

echo -e "${CYAN}Pour des tests plus approfondis avec détection de leaks:${NC}"
echo -e "  ${YELLOW}./test_leaks.sh${NC}\n"

echo -e "${CYAN}Pour analyser les résultats des tests valgrind:${NC}"
echo -e "  ${YELLOW}./analyze_results.sh${NC}\n"

echo -e "${GREEN}✓ Tests rapides terminés${NC}\n"

