# Guide de Test Rigoureux pour Philosophers

Ce dossier contient une suite de tests exhaustive pour détecter tous les problèmes possibles dans votre implémentation de Philosophers.

## 📋 Prérequis

### Sur Ubuntu/Debian (VM Linux)
```bash
sudo apt-get update
sudo apt-get install -y valgrind build-essential
```

### Sur d'autres distributions
```bash
# Fedora/RHEL
sudo dnf install valgrind gcc make

# Arch
sudo pacman -S valgrind gcc make
```

## 🚀 Utilisation Rapide

### 1. Rendre les scripts exécutables
```bash
chmod +x test_leaks.sh analyze_results.sh
```

### 2. Compiler votre programme
```bash
make re
```

### 3. Lancer les tests
```bash
./test_leaks.sh
```

Le script vous demandera quel type de tests exécuter :
- **Option 1** : Tests rapides uniquement (~2-5 minutes)
- **Option 2** : Tests Valgrind pour les memory leaks (~10-15 minutes)
- **Option 3** : Tests Helgrind pour les data races (~10-15 minutes)
- **Option 4** : Tests de stress (~15-20 minutes)
- **Option 5** : Tests de cas limites (~10 minutes)
- **Option 6** : TOUS les tests (~30-60 minutes)

### 4. Analyser les résultats
```bash
./analyze_results.sh
```

Cela génèrera un rapport détaillé dans `test_logs/<timestamp>/REPORT.txt`

## 📊 Types de Tests

### 🔍 Tests Valgrind (Memory Leaks)
Détecte :
- Memory leaks (definitely lost, still reachable)
- Invalid memory access (read/write)
- Use after free
- Double free
- Memory corruption

**Tests inclus :**
- Configurations basiques (4, 5, 10 philos)
- Configurations avec `must_eat`
- Cas limites (1, 2, 50, 100, 200 philos)
- Temps courts/longs
- Cas de stress

### 🔒 Tests Helgrind (Data Races & Deadlocks)
Détecte :
- Data races entre threads
- Problèmes d'ordre de locks
- Deadlocks potentiels
- Accès non synchronisés aux variables partagées

**Tests inclus :**
- Configurations avec beaucoup de philosophes
- Temps très courts (beaucoup de synchronisation)
- Nombres pairs/impairs de philosophes
- Tests avec terminaison (`must_eat`)

### ⚡ Tests Rapides (Sans Valgrind)
Vérifie :
- Arguments invalides
- Comportement général
- Détection de mort
- Complétion avec `must_eat`
- Stabilité sans crash

**Tests inclus :**
- Validation des arguments
- Tests fonctionnels normaux
- Tests de death detection
- Tests de complétion

### 💪 Tests de Stress
Pousse le programme à ses limites :
- Jusqu'à 200 philosophes
- `must_eat` très élevé (500+)
- Temps très courts avec beaucoup de philosophes
- Combinaisons extrêmes

### 🎯 Tests de Cas Limites
Cas extrêmes et edge cases :
- Valeurs INT_MAX
- Temps de 1ms
- Ratios eat/sleep variés
- Nombres pairs vs impairs
- Timing précis de mort

## 📁 Structure des Logs

```
test_logs/
└── 20250108_143022/          # Timestamp de l'exécution
    ├── valgrind/              # Logs des tests valgrind
    │   ├── basic_4_410_200_200.log
    │   ├── many_philos_100.log
    │   └── ...
    ├── helgrind/              # Logs des tests helgrind
    │   ├── basic_4_410_200_200.log
    │   └── ...
    ├── quick/                 # Logs des tests rapides
    │   ├── invalid_no_args.log
    │   └── ...
    └── REPORT.txt            # Rapport d'analyse détaillé
```

## 🔧 Commandes Utiles

### Voir un log spécifique
```bash
cat test_logs/<timestamp>/valgrind/<test_name>.log
cat test_logs/<timestamp>/helgrind/<test_name>.log
```

### Chercher tous les leaks
```bash
grep -r "definitely lost" test_logs/<timestamp>/valgrind/
```

### Chercher tous les data races
```bash
grep -r "Possible data race" test_logs/<timestamp>/helgrind/
```

### Voir le résumé de tous les tests
```bash
cat test_logs/<timestamp>/REPORT.txt
```

### Tester manuellement avec valgrind
```bash
valgrind --leak-check=full --show-leak-kinds=all ./philo 4 410 200 200
```

### Tester manuellement avec helgrind
```bash
valgrind --tool=helgrind ./philo 4 410 200 200
```

## 📈 Interprétation des Résultats

### ✅ Résultat Idéal
```
LEAK SUMMARY:
   definitely lost: 0 bytes in 0 blocks
   indirectly lost: 0 bytes in 0 blocks
   possibly lost: 0 bytes in 0 blocks
   still reachable: 0 bytes in 0 blocks

ERROR SUMMARY: 0 errors from 0 contexts
```

### ⚠️ Still Reachable (Acceptable dans certains cas)
```
still reachable: 72 bytes in 3 blocks
```
- Peut être acceptable si c'est la libc ou pthread
- Vérifier que ce n'est pas votre code

### ❌ Definitely Lost (PROBLÈME)
```
definitely lost: 1,024 bytes in 4 blocks
```
- **C'est un leak !** À corriger absolument
- Regarder la stack trace dans le log pour localiser

### ❌ Invalid Read/Write (PROBLÈME GRAVE)
```
Invalid read of size 4
Invalid write of size 8
```
- Accès à de la mémoire non allouée
- Use after free possible
- Corruption mémoire

### ❌ Data Race (PROBLÈME)
```
Possible data race during write
Possible data race during read
```
- Accès concurrent non synchronisé
- Utiliser des mutex appropriés

## 🐛 Debugging

### Si vous trouvez un leak
1. Ouvrir le log concerné
2. Chercher "definitely lost"
3. Regarder la stack trace pour voir où l'allocation a eu lieu
4. Vérifier que vous faites bien le `free()` correspondant

### Si vous trouvez un data race
1. Ouvrir le log helgrind
2. Chercher "Possible data race"
3. Regarder quelles variables sont accédées
4. Protéger les accès avec un mutex approprié

### Si un test timeout
- C'est normal pour certains tests (indiqué comme tel)
- Si c'est un deadlock, vérifier l'ordre de prise des locks
- Utiliser helgrind pour détecter les deadlocks

## 🎯 Conseils

### Pour passer tous les tests
1. **Pas de leaks** : Tout `malloc` doit avoir son `free`
2. **Pas de data races** : Protéger TOUTES les variables partagées
3. **Pas de deadlock** : Ordre cohérent des locks (même philo pair/impair)
4. **Death detection** : Vérifier régulièrement et précisément
5. **Cleanup propre** : Détruire tous les mutex, joindre tous les threads

### Tests critiques à passer
- `1 800 200 200` : Un seul philo doit mourir
- `4 410 200 200` : Ne doit pas mourir
- `4 310 200 100` : Quelqu'un doit mourir
- `5 800 200 200 7` : Doit se terminer proprement
- `200 410 200 200` : Doit gérer beaucoup de philos

## 📝 Checklist Avant Soumission

- [ ] Tous les tests Valgrind passent (0 leaks)
- [ ] Tous les tests Helgrind passent (0 data races)
- [ ] Tests rapides passent (pas de crash)
- [ ] Test avec 1 philo fonctionne
- [ ] Test avec 200 philos fonctionne
- [ ] `must_eat` termine proprement le programme
- [ ] Death detection est précise (<10ms)
- [ ] Pas de messages après la mort
- [ ] Cleanup libère toute la mémoire
- [ ] Respect de la Norm

## 🚨 Erreurs Courantes

### Memory Leaks
- Oublier de `free()` les philos
- Oublier de `free()` les forks
- Oublier de détruire les mutex

### Data Races
- Accès à `someone_died` sans mutex
- Accès à `last_meal_time` sans mutex
- Accès à `meals_eaten` sans mutex
- Printf sans mutex

### Deadlocks
- Tous les philos prennent la fourchette gauche en même temps
- Ordre de lock incohérent
- Ne pas unlock avant de sortir

### Logique
- Ne pas initialiser `last_meal_time` avant de créer les threads
- Vérifier la mort après manger au lieu d'avant
- Death detection trop lente (usleep dans le monitor)

## 📞 Support

Si vous trouvez des faux positifs ou des bugs dans les scripts :
1. Vérifier que valgrind est à jour
2. Vérifier que le programme compile sans warnings
3. Tester manuellement le cas problématique
4. Vérifier les logs détaillés

## 🎓 Ressources

- [Valgrind Manual](https://valgrind.org/docs/manual/manual.html)
- [Helgrind Manual](https://valgrind.org/docs/manual/hg-manual.html)
- [Philosophers Subject](https://cdn.intra.42.fr/pdf/pdf/960/philosophers.pdf)

---

**Bon courage pour vos tests ! 🚀**

