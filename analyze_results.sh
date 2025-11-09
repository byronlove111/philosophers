#!/bin/bash

# ============================================================================
# SCRIPT D'ANALYSE DES RÉSULTATS DE TESTS
# ============================================================================
# Analyse les logs générés par test_leaks.sh et produit un rapport détaillé
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

LOG_DIR="test_logs"

print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "============================================================================"
    echo "$1"
    echo "============================================================================"
    echo -e "${NC}"
}

print_section() {
    echo -e "\n${BOLD}${CYAN}$1${NC}\n"
}

# Trouver le dernier dossier de logs
get_latest_log_dir() {
    if [ ! -d "$LOG_DIR" ]; then
        echo -e "${RED}ERREUR: Aucun dossier de logs trouvé!${NC}"
        exit 1
    fi
    
    local latest=$(ls -t "$LOG_DIR" | head -1)
    if [ -z "$latest" ]; then
        echo -e "${RED}ERREUR: Aucun test n'a été exécuté!${NC}"
        exit 1
    fi
    
    echo "$LOG_DIR/$latest"
}

# Analyser les logs valgrind
analyze_valgrind() {
    local log_dir="$1/valgrind"
    
    if [ ! -d "$log_dir" ]; then
        echo "Pas de logs valgrind trouvés"
        return
    fi
    
    print_section "ANALYSE VALGRIND - MEMORY LEAKS"
    
    local total=0
    local clean=0
    local leaks=0
    local invalid=0
    
    for log_file in "$log_dir"/*.log; do
        if [ ! -f "$log_file" ]; then
            continue
        fi
        
        ((total++))
        local test_name=$(basename "$log_file" .log)
        
        # Vérifier les leaks
        local definitely_lost=$(grep "definitely lost:" "$log_file" | tail -1 | awk '{print $4}')
        local invalid_reads=$(grep -c "Invalid read" "$log_file")
        local invalid_writes=$(grep -c "Invalid write" "$log_file")
        
        if [ "$definitely_lost" = "0" ] && [ "$invalid_reads" = "0" ] && [ "$invalid_writes" = "0" ]; then
            ((clean++))
            echo -e "${GREEN}✓${NC} $test_name: CLEAN"
        else
            if [ "$definitely_lost" != "0" ] && [ -n "$definitely_lost" ]; then
                ((leaks++))
                echo -e "${RED}✗${NC} $test_name: ${RED}LEAK${NC} ($definitely_lost bytes)"
                echo "    → $log_file"
            fi
            if [ "$invalid_reads" != "0" ] || [ "$invalid_writes" != "0" ]; then
                ((invalid++))
                echo -e "${RED}✗${NC} $test_name: ${RED}INVALID ACCESS${NC} (R:$invalid_reads W:$invalid_writes)"
                echo "    → $log_file"
            fi
        fi
    done
    
    echo ""
    echo -e "${BOLD}Résumé Valgrind:${NC}"
    echo -e "  Total:          $total"
    echo -e "  Clean:          ${GREEN}$clean${NC}"
    echo -e "  Leaks:          ${RED}$leaks${NC}"
    echo -e "  Invalid access: ${RED}$invalid${NC}"
    
    if [ $leaks -eq 0 ] && [ $invalid -eq 0 ]; then
        echo -e "\n${GREEN}${BOLD}✓ Aucun problème mémoire détecté!${NC}\n"
    else
        echo -e "\n${RED}${BOLD}✗ Problèmes mémoire détectés!${NC}\n"
    fi
}

# Analyser les logs helgrind
analyze_helgrind() {
    local log_dir="$1/helgrind"
    
    if [ ! -d "$log_dir" ]; then
        echo "Pas de logs helgrind trouvés"
        return
    fi
    
    print_section "ANALYSE HELGRIND - DATA RACES"
    
    local total=0
    local clean=0
    local races=0
    
    for log_file in "$log_dir"/*.log; do
        if [ ! -f "$log_file" ]; then
            continue
        fi
        
        ((total++))
        local test_name=$(basename "$log_file" .log)
        
        # Vérifier les data races
        local race_count=$(grep -c "Possible data race" "$log_file")
        
        if [ "$race_count" = "0" ]; then
            ((clean++))
            echo -e "${GREEN}✓${NC} $test_name: CLEAN"
        else
            ((races++))
            echo -e "${RED}✗${NC} $test_name: ${RED}$race_count DATA RACE(S)${NC}"
            echo "    → $log_file"
            
            # Afficher les premières races détectées
            echo "    Détails:"
            grep -A 3 "Possible data race" "$log_file" | head -20 | sed 's/^/      /'
        fi
    done
    
    echo ""
    echo -e "${BOLD}Résumé Helgrind:${NC}"
    echo -e "  Total:      $total"
    echo -e "  Clean:      ${GREEN}$clean${NC}"
    echo -e "  Data races: ${RED}$races${NC}"
    
    if [ $races -eq 0 ]; then
        echo -e "\n${GREEN}${BOLD}✓ Aucun data race détecté!${NC}\n"
    else
        echo -e "\n${RED}${BOLD}✗ Data races détectés!${NC}\n"
    fi
}

# Analyser les tests rapides
analyze_quick() {
    local log_dir="$1/quick"
    
    if [ ! -d "$log_dir" ]; then
        echo "Pas de logs quick trouvés"
        return
    fi
    
    print_section "ANALYSE TESTS RAPIDES"
    
    local total=0
    local passed=0
    local failed=0
    
    for log_file in "$log_dir"/*.log; do
        if [ ! -f "$log_file" ]; then
            continue
        fi
        
        ((total++))
        local test_name=$(basename "$log_file" .log)
        
        # Vérifier si le programme a crash
        if grep -q "Segmentation fault" "$log_file" || grep -q "core dumped" "$log_file"; then
            ((failed++))
            echo -e "${RED}✗${NC} $test_name: ${RED}CRASH${NC}"
            echo "    → $log_file"
        else
            ((passed++))
            echo -e "${GREEN}✓${NC} $test_name: OK"
        fi
    done
    
    echo ""
    echo -e "${BOLD}Résumé Tests Rapides:${NC}"
    echo -e "  Total:  $total"
    echo -e "  Passés: ${GREEN}$passed${NC}"
    echo -e "  Échoués: ${RED}$failed${NC}"
    
    if [ $failed -eq 0 ]; then
        echo -e "\n${GREEN}${BOLD}✓ Tous les tests rapides sont passés!${NC}\n"
    else
        echo -e "\n${RED}${BOLD}✗ Certains tests rapides ont échoué!${NC}\n"
    fi
}

# Générer un rapport détaillé
generate_report() {
    local log_dir="$1"
    local report_file="$log_dir/REPORT.txt"
    
    print_section "GÉNÉRATION DU RAPPORT DÉTAILLÉ"
    
    {
        echo "============================================================================"
        echo "RAPPORT D'ANALYSE DES TESTS - PHILOSOPHERS"
        echo "============================================================================"
        echo "Date: $(date)"
        echo "Logs directory: $log_dir"
        echo ""
        
        # Statistiques Valgrind
        echo "--- VALGRIND (Memory Leaks) ---"
        if [ -d "$log_dir/valgrind" ]; then
            for log in "$log_dir/valgrind"/*.log; do
                if [ -f "$log" ]; then
                    echo ""
                    echo "Test: $(basename "$log" .log)"
                    echo "---"
                    grep "LEAK SUMMARY" -A 5 "$log" || echo "No summary found"
                    grep "ERROR SUMMARY" "$log" || echo "No error summary"
                fi
            done
        fi
        
        echo ""
        echo ""
        
        # Statistiques Helgrind
        echo "--- HELGRIND (Data Races) ---"
        if [ -d "$log_dir/helgrind" ]; then
            for log in "$log_dir/helgrind"/*.log; do
                if [ -f "$log" ]; then
                    local race_count=$(grep -c "Possible data race" "$log")
                    if [ "$race_count" != "0" ]; then
                        echo ""
                        echo "Test: $(basename "$log" .log)"
                        echo "Data races: $race_count"
                        echo "---"
                        grep -A 5 "Possible data race" "$log" | head -50
                    fi
                fi
            done
        fi
        
        echo ""
        echo "============================================================================"
        echo "FIN DU RAPPORT"
        echo "============================================================================"
        
    } > "$report_file"
    
    echo -e "${GREEN}✓ Rapport généré: $report_file${NC}"
}

# Fonction principale
main() {
    print_header "ANALYSE DES RÉSULTATS DE TESTS"
    
    local log_dir
    
    # Si un argument est fourni, l'utiliser comme dossier de logs
    if [ -n "$1" ]; then
        log_dir="$1"
    else
        log_dir=$(get_latest_log_dir)
    fi
    
    echo -e "Analyse du dossier: ${CYAN}$log_dir${NC}\n"
    
    if [ ! -d "$log_dir" ]; then
        echo -e "${RED}ERREUR: Le dossier $log_dir n'existe pas!${NC}"
        exit 1
    fi
    
    # Analyser les différents types de logs
    analyze_valgrind "$log_dir"
    analyze_helgrind "$log_dir"
    analyze_quick "$log_dir"
    
    # Générer le rapport
    generate_report "$log_dir"
    
    print_header "ANALYSE TERMINÉE"
    
    echo -e "Pour voir le rapport complet:"
    echo -e "  ${CYAN}cat $log_dir/REPORT.txt${NC}"
    echo ""
    echo -e "Pour voir un log spécifique:"
    echo -e "  ${CYAN}cat $log_dir/valgrind/<test_name>.log${NC}"
    echo -e "  ${CYAN}cat $log_dir/helgrind/<test_name>.log${NC}"
    echo ""
}

# Exécuter
main "$@"

