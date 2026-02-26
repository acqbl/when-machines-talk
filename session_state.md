# Session State — Packaging Industry Anomaly Detection

## Contexte du projet

Dataset Kaggle : `orvile/packaging-industry-anomaly-detection-dataset`
Objectif : analyse exploratoire + détection d'anomalies sur des données de production d'emballage industriel.

---

## Fichiers produits

| Fichier | Contenu |
|---|---|
| `scripts/1 - ETL.R` | Script ETL corrigé — lit `data/raw_data.csv`, convertit start/end en POSIXct, elapsed en dmilliseconds, sauvegarde `data/clean_data.rds` |
| `analysis_data_understanding.md` | Analyse de la structure des données : logique du log, signification de alarm/type/speed/pi/po |
| `analysis_eda_trs.md` | EDA complète : TRS par machine, analyse des downtimes (top alarmes), analyse des performance_loss |
| `Analysis.qmd` | Document Quarto de référence pour la structure des données (non modifié) |

`data/clean_data.rds` n'a pas encore été généré (ETL non exécuté depuis la correction).

---

## Ce qui a été compris sur les données

- 429 394 lignes, 5 machines (s_1–s_5), 2020-01-01 → 2022-01-02
- Chaque ligne = intervalle temporel consécutif sur une machine
- `type` : état de la machine (`production`, `performance_loss`, `downtime`, `idle`, `scheduled_downtime`)
- `alarm` : `A_000` = neutre (tous types sauf downtime) ; codes A_001–A_132 uniquement sur `downtime`
- `speed` : vitesse de consigne de la ligne au moment de l'intervalle, **pas** la production de l'intervalle
- `pi`/`po` : compteurs cumulatifs absolus (remises à zéro sur s_2, s_3, s_4)
- `elapsed` : durée en millisecondes

---

## Résultats EDA

### TRS global (Disponibilité × Performance, sans qualité)

| Machine | Dispo | Perf | TRS | Problème principal |
|---|---|---|---|---|
| s_1 | 88% | 73% | 65% | Downtime A_065 (858h) |
| s_2 | 86% | 38% | 33% | Idle 45% du temps ouvert |
| s_3 | 93% | 48% | 45% | Idle 44% du temps ouvert |
| s_4 | 94% | 47% | 44% | Performance_loss 25% du temps |
| s_5 | 96% | 56% | 53% | Idle 30% du temps ouvert |

### Top alarmes (downtime)
- **A_065** : 18 879 evt, 858h — quasi-exclusive à s_1
- **A_101** : 18 416 evt, 515h — s_5 (285h), s_2, s_3
- **A_006** : 3 943 evt, 411h — transversale s_2/s_3/s_4, durée moy. 6 min
- **A_001** : 4 403 evt, 388h — toutes machines, durée moy. 5 min
- **A_045** : 64 evt, 18h — rare mais durée moy. 17 min (alarme critique)

### Performance_loss
- Produisent seulement 5–18% de la production théorique (machine tourne mais ne produit quasi rien)
- s_4 : 1 540h en performance_loss = 25% du temps ouvert

---

## Prochaines étapes convenues

1. **Analyse temporelle des alarmes** A_065 (s_1) et A_101 (s_5) : périodicité, clustering, corrélation avec vitesse
2. **Analyse des séquences d'états** : les `performance_loss` annoncent-ils les `downtime` ?
3. **Analyse des idle** de s_2/s_3 : concentration horaire / hebdomadaire ?
4. **Détection d'anomalies** : événements atypiques en durée, fréquence, patterns de séquence
5. Intégrer les résultats dans `Analysis.qmd`
