#!/bin/bash

# ============================================================================
# SCRIPT DE VÉRIFICATION DE L'ENVIRONNEMENT DE TEST
# ============================================================================
# Vérifie que tout est correctement installé et configuré
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║       VÉRIFICATION DE L'ENVIRONNEMENT DE TEST                   ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

check_item() {
    local name="$1"
    local status="$2"
    local message="$3"
    
    if [ "$status" = "ok" ]; then
        echo -e "${GREEN}✓${NC} $name"
        if [ -n "$message" ]; then
            echo -e "  ${CYAN}→ $message${NC}"
        fi
        return 0
    elif [ "$status" = "warning" ]; then
        echo -e "${YELLOW}⚠${NC} $name"
        if [ -n "$message" ]; then
            echo -e "  ${YELLOW}→ $message${NC}"
        fi
        return 1
    else
        echo -e "${RED}✗${NC} $name"
        if [ -n "$message" ]; then
            echo -e "  ${RED}→ $message${NC}"
        fi
        return 1
    fi
}

check_command() {
    local cmd="$1"
    local name="$2"
    local install_hint="$3"
    
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -1)
        check_item "$name" "ok" "$version"
        return 0
    else
        check_item "$name" "error" "Non installé. $install_hint"
        return 1
    fi
}

print_header

errors=0
warnings=0

echo -e "${BOLD}${CYAN}[1] Outils de compilation${NC}\n"

check_command "gcc" "GCC (Compilateur C)" "sudo apt-get install build-essential"
((errors+=$?))

check_command "make" "Make" "sudo apt-get install make"
((errors+=$?))

check_command "cc" "CC (Compilateur par défaut)" ""
((errors+=$?))

echo ""
echo -e "${BOLD}${CYAN}[2] Outils de débogage${NC}\n"

check_command "valgrind" "Valgrind" "sudo apt-get install valgrind"
valgrind_status=$?
((errors+=$valgrind_status))

if [ $valgrind_status -eq 0 ]; then
    # Vérifier les outils valgrind
    if valgrind --tool=helgrind --version &> /dev/null; then
        check_item "Helgrind (outil valgrind)" "ok" "Disponible"
    else
        check_item "Helgrind (outil valgrind)" "error" "Non disponible"
        ((errors++))
    fi
fi

check_command "gdb" "GDB (Debugger)" "sudo apt-get install gdb"
gdb_status=$?
if [ $gdb_status -ne 0 ]; then
    ((warnings++))
fi

echo ""
echo -e "${BOLD}${CYAN}[3] Scripts de test${NC}\n"

scripts=("test_leaks.sh" "quick_test.sh" "analyze_results.sh" "run_custom_tests.sh" "check_setup.sh")
for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            check_item "$script" "ok" "Présent et exécutable"
        else
            check_item "$script" "warning" "Présent mais non exécutable (chmod +x $script)"
            ((warnings++))
        fi
    else
        check_item "$script" "error" "Fichier manquant"
        ((errors++))
    fi
done

echo ""
echo -e "${BOLD}${CYAN}[4] Fichiers de configuration${NC}\n"

config_files=("test_config.txt" "TEST_README.md" "SCRIPTS_OVERVIEW.md")
for config in "${config_files[@]}"; do
    if [ -f "$config" ]; then
        check_item "$config" "ok" "Présent"
    else
        check_item "$config" "warning" "Fichier manquant (non critique)"
        ((warnings++))
    fi
done

echo ""
echo -e "${BOLD}${CYAN}[5] Projet philosophers${NC}\n"

if [ -f "Makefile" ]; then
    check_item "Makefile" "ok" "Présent"
else
    check_item "Makefile" "error" "Makefile manquant"
    ((errors++))
fi

if [ -f "philo" ]; then
    check_item "Binaire philo" "ok" "Déjà compilé"
else
    check_item "Binaire philo" "warning" "Non compilé (lancer 'make')"
    ((warnings++))
fi

if [ -d "src" ]; then
    src_count=$(find src -name "*.c" 2>/dev/null | wc -l)
    check_item "Fichiers sources" "ok" "$src_count fichiers .c trouvés"
else
    check_item "Fichiers sources" "error" "Dossier src/ manquant"
    ((errors++))
fi

if [ -d "include" ]; then
    header_count=$(find include -name "*.h" 2>/dev/null | wc -l)
    check_item "Headers" "ok" "$header_count fichiers .h trouvés"
else
    check_item "Headers" "warning" "Dossier include/ manquant"
    ((warnings++))
fi

echo ""
echo -e "${BOLD}${CYAN}[6] Dossiers de logs${NC}\n"

if [ -d "test_logs" ]; then
    log_count=$(ls -1 test_logs 2>/dev/null | wc -l)
    if [ $log_count -gt 0 ]; then
        check_item "test_logs/" "ok" "$log_count sessions de test trouvées"
    else
        check_item "test_logs/" "ok" "Dossier présent (vide)"
    fi
else
    check_item "test_logs/" "ok" "Sera créé au premier test"
fi

if [ -d "custom_test_logs" ]; then
    custom_log_count=$(ls -1 custom_test_logs 2>/dev/null | wc -l)
    if [ $custom_log_count -gt 0 ]; then
        check_item "custom_test_logs/" "ok" "$custom_log_count sessions trouvées"
    else
        check_item "custom_test_logs/" "ok" "Dossier présent (vide)"
    fi
else
    check_item "custom_test_logs/" "ok" "Sera créé au premier test custom"
fi

echo ""
echo -e "${BOLD}${CYAN}[7] Informations système${NC}\n"

if [ -f "/etc/os-release" ]; then
    os_name=$(grep "^NAME=" /etc/os-release | cut -d'"' -f2)
    os_version=$(grep "^VERSION=" /etc/os-release | cut -d'"' -f2)
    check_item "Système d'exploitation" "ok" "$os_name $os_version"
else
    check_item "Système d'exploitation" "ok" "$(uname -s)"
fi

kernel=$(uname -r)
check_item "Kernel" "ok" "$kernel"

if [ -f "/proc/cpuinfo" ]; then
    cpu_count=$(grep -c "^processor" /proc/cpuinfo)
    check_item "Processeurs" "ok" "$cpu_count cores"
else
    check_item "Processeurs" "ok" "Information non disponible"
fi

if [ -f "/proc/meminfo" ]; then
    mem_total=$(grep "MemTotal" /proc/meminfo | awk '{printf "%.1f GB", $2/1024/1024}')
    check_item "Mémoire RAM" "ok" "$mem_total"
else
    check_item "Mémoire RAM" "ok" "Information non disponible"
fi

echo ""
echo -e "${BOLD}${BLUE}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                           RÉSUMÉ                                 ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✓ Environnement parfaitement configuré !${NC}\n"
    echo -e "Vous pouvez lancer les tests:"
    echo -e "  ${CYAN}./quick_test.sh${NC}        - Tests rapides"
    echo -e "  ${CYAN}./test_leaks.sh${NC}        - Tests complets\n"
    exit 0
elif [ $errors -eq 0 ]; then
    echo -e "${YELLOW}${BOLD}⚠ Environnement fonctionnel avec $warnings avertissement(s)${NC}\n"
    echo -e "Les tests peuvent être lancés mais certaines fonctionnalités"
    echo -e "peuvent être limitées.\n"
    exit 0
else
    echo -e "${RED}${BOLD}✗ Environnement incomplet - $errors erreur(s), $warnings avertissement(s)${NC}\n"
    echo -e "Veuillez corriger les erreurs ci-dessus avant de lancer les tests.\n"
    
    if command -v apt-get &> /dev/null; then
        echo -e "${CYAN}Installation rapide sur Ubuntu/Debian:${NC}"
        echo -e "  ${YELLOW}sudo apt-get update${NC}"
        echo -e "  ${YELLOW}sudo apt-get install -y build-essential valgrind gdb${NC}\n"
    elif command -v dnf &> /dev/null; then
        echo -e "${CYAN}Installation rapide sur Fedora/RHEL:${NC}"
        echo -e "  ${YELLOW}sudo dnf install -y gcc make valgrind gdb${NC}\n"
    elif command -v pacman &> /dev/null; then
        echo -e "${CYAN}Installation rapide sur Arch:${NC}"
        echo -e "  ${YELLOW}sudo pacman -S gcc make valgrind gdb${NC}\n"
    fi
    
    exit 1
fi

