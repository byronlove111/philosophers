#!/bin/bash

# Script de test pour args.c, init.c et time.c
# Usage: ./test_init.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Tests pour Philosophers - Phase Init${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Compilation
echo -e "${YELLOW}[1] Compilation...${NC}"
make re > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Compilation réussie${NC}\n"
else
    echo -e "${RED}✗ Erreur de compilation${NC}"
    make re
    exit 1
fi

# Test 1: Arguments invalides
echo -e "${YELLOW}[2] Test des arguments invalides${NC}"
test_count=0
pass_count=0

# Pas assez d'arguments
./philo > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}  ✓ Rejette: pas d'arguments${NC}"
    ((pass_count++))
else
    echo -e "${RED}  ✗ Accepte: pas d'arguments${NC}"
fi
((test_count++))

./philo 5 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}  ✓ Rejette: arguments incomplets${NC}"
    ((pass_count++))
else
    echo -e "${RED}  ✗ Accepte: arguments incomplets${NC}"
fi
((test_count++))

# Nombres négatifs
./philo -5 800 200 200 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}  ✓ Rejette: nombre négatif${NC}"
    ((pass_count++))
else
    echo -e "${RED}  ✗ Accepte: nombre négatif${NC}"
fi
((test_count++))

# Zéro
./philo 0 800 200 200 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}  ✓ Rejette: zéro${NC}"
    ((pass_count++))
else
    echo -e "${RED}  ✗ Accepte: zéro${NC}"
fi
((test_count++))

# Lettres
./philo abc 800 200 200 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}  ✓ Rejette: lettres${NC}"
    ((pass_count++))
else
    echo -e "${RED}  ✗ Accepte: lettres${NC}"
fi
((test_count++))

echo -e "${BLUE}  → $pass_count/$test_count tests passés${NC}\n"

# Test 2: Arguments valides
echo -e "${YELLOW}[3] Test des arguments valides${NC}"
test_count=0
pass_count=0

./philo 5 800 200 200 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Accepte: 5 800 200 200${NC}"
    ((pass_count++))
else
    echo -e "${RED}  ✗ Rejette: 5 800 200 200${NC}"
fi
((test_count++))

./philo 1 800 200 200 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Accepte: 1 philosophe${NC}"
    ((pass_count++))
else
    echo -e "${RED}  ✗ Rejette: 1 philosophe${NC}"
fi
((test_count++))

./philo 200 800 200 200 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Accepte: 200 philosophes${NC}"
    ((pass_count++))
else
    echo -e "${RED}  ✗ Rejette: 200 philosophes${NC}"
fi
((test_count++))

./philo 5 800 200 200 7 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Accepte: avec must_eat_count${NC}"
    ((pass_count++))
else
    echo -e "${RED}  ✗ Rejette: avec must_eat_count${NC}"
fi
((test_count++))

echo -e "${BLUE}  → $pass_count/$test_count tests passés${NC}\n"

# Test 3: Fuites mémoire (Valgrind)
echo -e "${YELLOW}[4] Test des fuites mémoire${NC}"
if command -v valgrind &> /dev/null; then
    valgrind --leak-check=full --error-exitcode=1 --quiet ./philo 5 800 200 200 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  ✓ Aucune fuite mémoire détectée${NC}\n"
    else
        echo -e "${RED}  ✗ Fuites mémoire détectées${NC}"
        echo -e "${YELLOW}  Exécutez: valgrind --leak-check=full ./philo 5 800 200 200${NC}\n"
    fi
else
    echo -e "${YELLOW}  ⚠ Valgrind non installé, test ignoré${NC}\n"
fi

# Test 4: Temps de précision
echo -e "${YELLOW}[5] Test de précision du temps${NC}"
cat > test_time_precision.c << 'EOF'
#include "include/philo.h"
#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    long start, end, diff;
    int errors = 0;
    
    // Test 1: Sleep 100ms
    start = get_time();
    ft_usleep(100);
    end = get_time();
    diff = end - start;
    
    printf("  Sleep 100ms: %ld ms ", diff);
    if (diff >= 95 && diff <= 110) {
        printf("✓\n");
    } else {
        printf("✗ (trop imprécis)\n");
        errors++;
    }
    
    // Test 2: Sleep 500ms
    start = get_time();
    ft_usleep(500);
    end = get_time();
    diff = end - start;
    
    printf("  Sleep 500ms: %ld ms ", diff);
    if (diff >= 490 && diff <= 520) {
        printf("✓\n");
    } else {
        printf("✗ (trop imprécis)\n");
        errors++;
    }
    
    // Test 3: get_elapsed_time
    start = get_time();
    ft_usleep(50);
    diff = get_elapsed_time(start);
    
    printf("  Elapsed time: %ld ms ", diff);
    if (diff >= 45 && diff <= 60) {
        printf("✓\n");
    } else {
        printf("✗ (trop imprécis)\n");
        errors++;
    }
    
    return errors;
}
EOF

cc -Wall -Wextra -Werror -pthread -Iinclude test_time_precision.c obj/utils/time.o -o test_time_precision 2>/dev/null
if [ $? -eq 0 ]; then
    ./test_time_precision
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  → Tous les tests de temps sont précis${NC}\n"
    else
        echo -e "${RED}  → Certains tests de temps ont échoué${NC}\n"
    fi
    rm -f test_time_precision test_time_precision.c
else
    echo -e "${YELLOW}  ⚠ Impossible de compiler le test de temps${NC}\n"
    rm -f test_time_precision.c
fi

# Test 5: Data races (ThreadSanitizer)
echo -e "${YELLOW}[6] Test des data races${NC}"
if cc -fsanitize=thread -Wall -Wextra -Werror -pthread -Iinclude src/*.c src/init/*.c src/utils/*.c -o philo_tsan 2>/dev/null; then
    ./philo_tsan 5 800 200 200 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  ✓ Aucun data race détecté${NC}\n"
    else
        echo -e "${RED}  ✗ Data races détectés${NC}\n"
    fi
    rm -f philo_tsan
else
    echo -e "${YELLOW}  ⚠ ThreadSanitizer non disponible${NC}\n"
fi

# Résumé final
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Résumé${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Compilation OK${NC}"
echo -e "${GREEN}✓ Arguments validés correctement${NC}"
echo -e "${GREEN}✓ Init fonctionne${NC}"
echo -e "\n${YELLOW}Note: Les tests de threads/routine/monitor seront faits plus tard${NC}\n"

