# Analyse exploratoire — TRS et pertes de performance

## 1. Définition du TRS utilisé

Le TRS (Taux de Rendement Synthétique) est décomposé en deux composantes. La **qualité** est exclue : `po` et `pi` sont des compteurs cumulatifs avec des remises à zéro non documentées, rendant leur exploitation directe non fiable à ce stade.

```
TRS = Disponibilité × Performance

Disponibilité = (Temps ouvert − Downtime) / Temps ouvert
  Temps ouvert = Temps total − scheduled_downtime

Performance = Temps en production / (Temps en production + performance_loss + idle)
```

Ce TRS-temps mesure la fraction du temps utile effectivement passée en production.

---

## 2. TRS global par machine

| Machine | Dispo | Perf | TRS | Idle (% temps ouvert) |
|---|---|---|---|---|
| s_1 | **88,3%** | **73,3%** | **64,7%** | 10,6% |
| s_2 | 86,2% | 37,8% | 32,6% | 44,9% |
| s_3 | 93,1% | 48,0% | 44,7% | 43,9% |
| s_4 | 94,2% | 46,7% | 44,0% | 25,0% |
| s_5 | 95,9% | 55,7% | 53,4% | 30,4% |

**Observations :**

- **s_1** est la machine la plus performante et la plus documentée (24 mois complets). Son TRS (~65%) est pénalisé principalement par la disponibilité (alarme A_065 dominante, voir §4) et par les performances_loss.
- **s_2 et s_3** ont une disponibilité correcte (~86–93%) mais une performance catastrophique : elles passent respectivement 45% et 44% de leur temps ouvert en `idle`. Le problème n'est pas la panne mais l'alimentation / cadence amont.
- **s_4** bonne disponibilité (94%) mais performance très dégradée par `performance_loss` (25% du temps ouvert, 1 540 h sur 2 ans).
- **s_5** meilleure disponibilité (96%) mais 30% de temps idle — problème de flux similaire à s_3.

---

## 3. TRS mensuel de s_1 (machine de référence)

| Période | Dispo | Perf | TRS |
|---|---|---|---|
| Jan–Mar 2020 | 87–90% | 74–75% | 65–67% |
| Avr–Juil 2020 | 88–91% | 68–73% | 61–66% |
| Aoû–Déc 2020 | 88–91% | 74–81% | 67–71% |
| Jan–Juin 2021 | 84–90% | 69–77% | 58–68% |
| **Juil 2021** | **82%** | **67%** | **55%** ← pire mois |
| Aoû–Déc 2021 | 87–89% | 67–79% | 60–69% |

- La disponibilité est relativement stable (82–91%) ; les pics de downtime de juillet 2021 et mars 2021 tirent le TRS vers le bas.
- La performance est le facteur le plus variable (67–81%), pilotée par les alternances production/performance_loss/idle.
- Pas de tendance dégradante nette sur 2 ans : la machine est dans un régime stable.

---

## 4. Analyse des downtimes (pertes de disponibilité)

### 4.1 Distribution des durées

| Percentile | Durée |
|---|---|
| P25 | 18 sec |
| P50 (médiane) | 54 sec |
| P75 | 1 min 49 |
| P90 | 4 min |
| P99 | 19 min |
| Max | 911 min (~15h) |

La majorité des downtimes sont **courts** (micro-arrêts < 2 min). Les événements longs sont rares mais très coûteux en temps.

### 4.2 Top 20 alarmes (toutes machines, par durée totale)

| Alarme | Événements | Durée totale (h) | Durée moyenne (min) | Médiane (min) |
|---|---|---|---|---|
| **A_065** | 18 879 | **858 h** | 2,7 | 1,3 |
| **A_101** | 18 416 | **515 h** | 1,7 | 1,1 |
| A_006 | 3 943 | 411 h | 6,3 | 1,4 |
| A_001 | 4 403 | 388 h | 5,3 | 3,0 |
| A_066 | 3 384 | 153 h | 2,7 | 1,2 |
| A_005 | 12 226 | 132 h | 0,6 | 0,3 |
| A_020 | 5 100 | 111 h | 1,3 | 0,9 |
| A_010 | 9 278 | 91 h | 0,6 | 0,3 |
| A_045 | 64 | 18 h | **17,2** | 2,7 |

**A_065 et A_101** dominent en durée absolue par leur fréquence élevée (>18 000 événements chacune). **A_006 et A_001** sont moins fréquentes mais plus longues en moyenne (~5–6 min), suggérant des pannes plus sérieuses. **A_045** : seulement 64 événements mais durée moyenne de 17 min — alarme rare mais critique.

### 4.3 Alarmes dominantes par machine

| Machine | #1 | #2 | #3 |
|---|---|---|---|
| s_1 | A_065 (858h, 18 879 evt) | A_066 (151h) | A_001 (102h) |
| s_2 | A_001 (181h) | A_101 (134h) | A_006 (113h) |
| s_3 | A_006 (234h) | A_101 (96h) | A_001 (82h) |
| s_4 | A_005 (71h) | A_006 (64h) | A_020 (45h) |
| s_5 | A_101 (285h) | A_005 (19h) | A_010 (15h) |

- **A_065** est quasi-exclusive à **s_1** (858h sur 858h total de cette alarme) : cause de défaillance spécifique à cette machine.
- **A_101** touche principalement **s_5** (285h) et **s_2/s_3** — probablement une alarme liée à un équipement commun.
- **A_006** est répandue sur s_2, s_3, s_4 : défaillance transversale.
- **A_001** est présente sur toutes les machines : alarme générique (démarrage, reset ?).

---

## 5. Analyse des pertes de performance

### 5.1 Ratio production réelle / théorique pendant performance_loss

| Machine | Durée (h) | Ratio réel/théorique |
|---|---|---|
| s_1 | 1 360 h | **6,7%** |
| s_2 | 363 h | 5,6% |
| s_3 | 305 h | **18,1%** |
| s_4 | 1 466 h | 7,4% |
| s_5 | 1 036 h | 17,2% |

Les intervalles `performance_loss` produisent **< 20% de la production théorique** que la vitesse affichée laisse espérer. Ce type d'intervalle correspond à une machine qui tourne en régime mais **ne produit presque rien** (attente, ralentissement, blocage partiel). s_3 et s_5 produisent un peu plus (~17–18%) que s_1/s_2/s_4 (~6–7%).

### 5.2 Distribution des durées de performance_loss

| Percentile | Durée |
|---|---|
| P25 | 10 sec |
| P50 | 41 sec |
| P75 | 1 min 58 |
| P90 | 5 min 47 |
| P99 | 29 min |
| Max | 498 min (~8h) |

Profil très similaire aux downtimes : dominance de micro-événements courts, mais une longue queue avec des événements > 30 min.

### 5.3 Poids des pertes par machine

| Machine | Temps en performance_loss | % du temps ouvert |
|---|---|---|
| s_1 | 1 541 h | 13,0% |
| s_2 | 363 h | 8,7% |
| s_3 | 305 h | 4,5% |
| **s_4** | **1 540 h** | **25,2%** |
| s_5 | 1 043 h | 12,1% |

**s_4** est la machine la plus pénalisée par les `performance_loss` (25% du temps ouvert), ce qui explique son TRS faible malgré une excellente disponibilité (94%).

---

## 6. Synthèse des leviers d'amélioration

| Machine | Levier principal | Levier secondaire |
|---|---|---|
| **s_1** | Réduire A_065 (858h de downtime) | Réduire performance_loss |
| **s_2** | Réduire idle (45% du temps) | Réduire A_001/A_006 |
| **s_3** | Réduire idle (44% du temps) | Réduire A_006 |
| **s_4** | Réduire performance_loss (25%) | Réduire A_005/A_006 |
| **s_5** | Réduire idle (30% du temps) | Réduire A_101 |

Le `idle` élevé de s_2, s_3, s_5 suggère un problème de **flux (approvisionnement ou synchronisation)** plutôt que de fiabilité machine. A_065 sur s_1 et A_101 sur s_5 sont les alarmes à investiguer en priorité pour la disponibilité.

---

## 7. Prochaines étapes suggérées

- **Analyse temporelle fine** des alarmes A_065 (s_1) et A_101 (s_5) : périodicité, clustering, corrélation avec vitesse
- **Analyse des séquences** : quel état précède/suit un downtime ? Les `performance_loss` annoncent-ils les `downtime` ?
- **Analyse des idle** : s_2/s_3 — les idlings sont-ils concentrés sur certaines heures ou plages horaires ?
- **Détection d'anomalies** : événements statistiquement atypiques en durée, fréquence, ou patterns de séquence
