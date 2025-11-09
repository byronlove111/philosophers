# 📋 Vue d'ensemble des scripts de test

Ce projet contient plusieurs scripts de test pour valider votre implémentation de Philosophers de manière exhaustive.

## 🎯 Scripts disponibles

### 1. `test_leaks.sh` - Suite complète de tests 
**Le script principal et le plus complet**

```bash
./test_leaks.sh
```

**Ce qu'il fait :**
- Tests Valgrind pour détecter les memory leaks
- Tests Helgrind pour détecter les data races et deadlocks
- Tests rapides de comportement
- Tests de stress avec beaucoup de philosophes
- Tests de cas limites extrêmes

**Options disponibles :**
1. Tests rapides uniquement (~2-5 min)
2. Tests valgrind seulement (~10-15 min)
3. Tests helgrind seulement (~10-15 min)
4. Tests de stress (~15-20 min)
5. Tests cas limites (~10 min)
6. **TOUS les tests** (~30-60 min) ⭐ RECOMMANDÉ avant soumission

**Résultats :**
- Logs détaillés dans `test_logs/<timestamp>/`
- Rapport d'analyse automatique
- Compteurs de tests passés/échoués

---

### 2. `quick_test.sh` - Tests rapides sans Valgrind
**Pour tester rapidement sans attendre Valgrind**

```bash
./quick_test.sh
```

**Ce qu'il fait :**
- Tests de base sans Valgrind
- Validation des arguments
- Tests de mort et de complétion
- Tests avec différents nombres de philosophes
- Tests de stress légers

**Avantages :**
- ⚡ Très rapide (2-5 minutes pour tous les tests)
- 👁️ Voir la sortie du programme en temps réel
- 🔍 Identifier rapidement les problèmes de logique

**Quand l'utiliser :**
- Pendant le développement
- Pour valider rapidement un changement
- Avant de lancer les tests lourds avec Valgrind

---

### 3. `analyze_results.sh` - Analyse des logs
**Analyse intelligente des résultats de tests**

```bash
./analyze_results.sh
# ou
./analyze_results.sh test_logs/20250108_143022
```

**Ce qu'il fait :**
- Parse tous les logs Valgrind pour trouver les leaks
- Parse tous les logs Helgrind pour trouver les data races
- Génère un rapport détaillé en format texte
- Affiche un résumé coloré avec statistiques

**Résultats :**
- Rapport complet dans `test_logs/<timestamp>/REPORT.txt`
- Résumé dans le terminal avec codes couleur
- Indique exactement où regarder pour chaque problème

---

### 4. `run_custom_tests.sh` - Tests personnalisés
**Exécute vos propres tests définis dans `test_config.txt`**

```bash
./run_custom_tests.sh
```

**Ce qu'il fait :**
- Lit le fichier `test_config.txt`
- Exécute chaque test défini
- Supporte Valgrind, Helgrind et tests rapides
- Génère des logs comme `test_leaks.sh`

**Comment l'utiliser :**
1. Éditer `test_config.txt`
2. Ajouter vos tests au format : `nom | args | timeout | type`
3. Lancer le script

**Exemple de configuration :**
```
mon_test | 4 410 200 200 | 5s | valgrind
test_eval | 5 800 200 200 7 | 15s | helgrind
```

**Quand l'utiliser :**
- Pour les tests spécifiques de votre évaluateur
- Pour reproduire un bug spécifique
- Pour créer votre propre batterie de tests

---

## 🚀 Workflow recommandé

### Pendant le développement
```bash
# 1. Test rapide après chaque changement
./quick_test.sh

# 2. Si tout va bien, test avec Valgrind
./test_leaks.sh   # Option 1 (tests rapides avec Valgrind)
```

### Avant une évaluation
```bash
# 1. Recompiler proprement
make re

# 2. Tests rapides
./quick_test.sh

# 3. Tests complets avec Valgrind et Helgrind
./test_leaks.sh   # Option 6 (TOUS les tests)

# 4. Analyser les résultats
./analyze_results.sh

# 5. Corriger les problèmes et recommencer
```

### Pour reproduire un problème spécifique
```bash
# 1. Ajouter le test dans test_config.txt
echo "bug_reproduction | 4 310 200 100 | 5s | valgrind" >> test_config.txt

# 2. Lancer le test
./run_custom_tests.sh

# 3. Analyser
./analyze_results.sh custom_test_logs/<timestamp>
```

---

## 📊 Comparaison des scripts

| Script | Durée | Valgrind | Helgrind | Tests | Usage |
|--------|-------|----------|----------|-------|-------|
| `quick_test.sh` | 2-5 min | ❌ | ❌ | ~30 | Développement quotidien |
| `test_leaks.sh` (opt 1) | 5-10 min | ✅ | ❌ | ~15 | Vérification rapide leaks |
| `test_leaks.sh` (opt 6) | 30-60 min | ✅ | ✅ | ~100+ | **Avant soumission** |
| `run_custom_tests.sh` | Variable | ✅ | ✅ | Custom | Tests spécifiques |
| `analyze_results.sh` | <1 min | - | - | - | Après tests |

---

## 🔍 Que chercher dans les résultats

### ✅ Bon résultat
```
LEAK SUMMARY:
   definitely lost: 0 bytes in 0 blocks
ERROR SUMMARY: 0 errors

Helgrind:
   Possible data race: 0
```

### ❌ Problèmes courants

**Memory Leak:**
```
definitely lost: 1,024 bytes in 4 blocks
→ Vérifier les malloc/free
→ Vérifier la destruction des mutex
```

**Data Race:**
```
Possible data race during read/write
→ Protéger avec un mutex
→ Variables partagées non synchronisées
```

**Invalid Access:**
```
Invalid read of size 4
→ Use after free
→ Accès hors limites
```

---

## 📝 Fichiers générés

```
philosophers/
├── test_leaks.sh           # Script principal
├── quick_test.sh           # Tests rapides
├── analyze_results.sh      # Analyse de logs
├── run_custom_tests.sh     # Tests personnalisés
├── test_config.txt         # Configuration tests perso
├── TEST_README.md          # Documentation complète
├── SCRIPTS_OVERVIEW.md     # Ce fichier
│
├── test_logs/              # Logs des tests principaux
│   └── 20250108_143022/
│       ├── valgrind/
│       ├── helgrind/
│       ├── quick/
│       └── REPORT.txt
│
└── custom_test_logs/       # Logs des tests personnalisés
    └── 20250108_150000/
        └── ...
```

---

## 💡 Astuces

### Pour gagner du temps
```bash
# Ne tester que les leaks (pas helgrind)
./test_leaks.sh  # puis choisir option 2

# Tester seulement un cas spécifique
valgrind --leak-check=full ./philo 4 410 200 200
```

### Pour debugger un leak
```bash
# 1. Identifier le test qui leak
./analyze_results.sh

# 2. Voir le log détaillé
cat test_logs/<timestamp>/valgrind/<test_name>.log

# 3. Chercher la stack trace
grep -A 20 "definitely lost" test_logs/<timestamp>/valgrind/<test_name>.log
```

### Pour debugger un data race
```bash
# 1. Voir quels tests ont des races
./analyze_results.sh

# 2. Voir le détail
cat test_logs/<timestamp>/helgrind/<test_name>.log

# 3. Chercher la race spécifique
grep -A 30 "Possible data race" test_logs/<timestamp>/helgrind/<test_name>.log
```

---

## 🎯 Tests critiques à passer

Ces tests sont essentiels et souvent utilisés en évaluation :

```bash
# Test 1 philosophe (doit mourir)
./philo 1 800 200 200

# Test basique (ne doit pas mourir)
./philo 4 410 200 200

# Test mort rapide
./philo 4 310 200 100

# Test avec must_eat
./philo 5 800 200 200 7

# Test beaucoup de philos
./philo 200 410 200 200
```

Tous ces tests sont inclus dans `test_leaks.sh` et `quick_test.sh`.

---

## ⚙️ Configuration requise

### Sur votre VM Linux
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install valgrind build-essential

# Fedora/RHEL
sudo dnf install valgrind gcc make

# Arch
sudo pacman -S valgrind gcc make
```

### Vérifier l'installation
```bash
valgrind --version
gcc --version
make --version
```

---

## 📚 Documentation complète

Pour plus de détails, voir :
- **`TEST_README.md`** - Documentation exhaustive
- Logs dans `test_logs/` après exécution
- Rapport d'analyse dans `test_logs/<timestamp>/REPORT.txt`

---

## 🆘 Support

### Le script ne trouve pas le binaire
```bash
make re
./test_leaks.sh
```

### Valgrind n'est pas installé
```bash
sudo apt-get install valgrind
```

### Les tests prennent trop de temps
```bash
# Utiliser quick_test à la place
./quick_test.sh

# Ou seulement les tests rapides avec valgrind
./test_leaks.sh  # puis option 1
```

### Trop de faux positifs
- Vérifier que vous avez la dernière version de valgrind
- Certains "still reachable" sont normaux (libc/pthread)
- Focus sur "definitely lost" et "Invalid read/write"

---

**Bon courage pour vos tests ! 🚀**

