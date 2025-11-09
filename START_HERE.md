# 🚀 DÉMARRAGE RAPIDE - Tests Philosophers

## ⚡ Quick Start (30 secondes)

```bash
# 1. Vérifier l'environnement
./check_setup.sh

# 2. Compiler
make re

# 3. Lancer les tests rapides
./quick_test.sh
```

---

## 📚 Scripts disponibles

| Script | Durée | Description |
|--------|-------|-------------|
| `./check_setup.sh` | 10s | Vérifier que tout est installé |
| `./quick_test.sh` | 2-5 min | Tests rapides sans Valgrind ⚡ |
| `./test_leaks.sh` | 30-60 min | **Tests complets** (recommandé avant soumission) 🔍 |
| `./analyze_results.sh` | 10s | Analyser les résultats des tests |
| `./run_custom_tests.sh` | Variable | Lancer vos tests personnalisés |

---

## 🎯 Workflow recommandé

### Pendant le développement
```bash
./quick_test.sh          # Après chaque changement
```

### Avant de soumettre
```bash
./test_leaks.sh          # Choisir option 6 (TOUS les tests)
./analyze_results.sh     # Voir le résumé
```

### Si un test échoue
```bash
# Voir les logs détaillés
cat test_logs/YYYYMMDD_HHMMSS/valgrind/<test_name>.log
cat test_logs/YYYYMMDD_HHMMSS/helgrind/<test_name>.log
```

---

## ✅ Ce qui est testé

- ✓ **Memory leaks** (Valgrind)
- ✓ **Data races** (Helgrind)  
- ✓ **Deadlocks** (Helgrind)
- ✓ **Arguments invalides**
- ✓ **Cas limites** (1, 2, 200 philos)
- ✓ **Death detection**
- ✓ **Must_eat completion**
- ✓ **Tests de stress**
- ✓ **Invalid memory access**

---

## 📖 Documentation complète

- **`SCRIPTS_OVERVIEW.md`** → Vue d'ensemble détaillée des scripts
- **`TEST_README.md`** → Documentation exhaustive
- **`test_config.txt`** → Ajouter vos tests personnalisés

---

## 🆘 Problèmes ?

### Valgrind non installé
```bash
# Ubuntu/Debian
sudo apt-get install valgrind

# Fedora/RHEL
sudo dnf install valgrind

# Arch
sudo pacman -S valgrind
```

### Script non exécutable
```bash
chmod +x *.sh
```

### Compilation échoue
```bash
make fclean
make re
```

---

## 🎓 Tests critiques à passer

```bash
./philo 1 800 200 200              # 1 philo doit mourir
./philo 4 410 200 200              # Ne doit PAS mourir
./philo 4 310 200 100              # Quelqu'un doit mourir
./philo 5 800 200 200 7            # Doit se terminer proprement
./philo 200 410 200 200            # Beaucoup de philos
```

Ces tests sont **TOUS** inclus dans les scripts !

---

**Bon courage ! 💪**

