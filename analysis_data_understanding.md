# Compréhension des données — Packaging Industry Anomaly Detection

## Vue d'ensemble

- **Source** : Kaggle — `orvile/packaging-industry-anomaly-detection-dataset`
- **Lignes** : 429 394
- **Machines** : 5 (`s_1` à `s_5`)
- **Période** : 2020-01-01 → 2022-01-02 (2 ans)

---

## Ce que représente une ligne

Chaque ligne est un **intervalle temporel continu sur une machine**, délimité par `start` et `end` (timestamps Unix en secondes). Ces intervalles se succèdent sans chevauchement par machine : la fin d'un intervalle est le début du suivant.

```
[scheduled_downtime]──[idle]──[production]──[downtime]──[production]──...
```

`interval_start` est redondant avec `start` (format ISO lisible vs Unix float).
`elapsed` est la durée en millisecondes, cohérente avec `end - start`.

---

## Le champ `type` : l'état de la machine

Cinq états possibles, mutuellement exclusifs :

| type | n | description |
|---|---|---|
| `production` | 146 795 | La machine produit normalement |
| `performance_loss` | 118 584 | La machine tourne mais en dessous de sa vitesse nominale |
| `downtime` | 92 084 | Arrêt non planifié déclenché par une alarme |
| `idle` | 50 149 | Machine à l'arrêt, en attente, sans alarme active |
| `scheduled_downtime` | 21 782 | Arrêt planifié (maintenance, changement de format…) |

---

## Le champ `alarm` : le code raison

`alarm` identifie la **cause active** de l'état courant. Il y a 133 codes distincts (`A_000` à `A_132`).

**Règle fondamentale** : `A_000` est le code neutre (pas d'alarme).

| alarm | types associés |
|---|---|
| `A_000` uniquement | `idle`, `production`, `performance_loss`, `scheduled_downtime` |
| Codes `A_001`–`A_132` | `downtime` uniquement |

**Conséquence** : `downtime` est le seul type porteur d'une alarme réelle. Les 132 autres codes identifient l'origine de l'arrêt non planifié (pannes mécaniques, capteurs, etc.). Tous les autres états tournent sous `A_000`.

---

## Le champ `speed` : vitesse nominale de la ligne

`speed` exprime la **vitesse de consigne de la ligne en packages/heure**, non la vitesse instantanée de production de l'intervalle.

### Observations clés

1. **`speed` ne reflète pas l'activité de l'intervalle** : on observe `speed = 4650` simultanément sur des intervalles `production`, `downtime`, `performance_loss` et `scheduled_downtime` consécutifs sur la même machine. C'est la vitesse à laquelle la ligne *tourne* (ou *tournait*), pas ce qu'elle a produit pendant l'intervalle.

2. **`speed = 0`** signifie que la ligne est complètement à l'arrêt (démarrage, fin de production, changement de format). Cela arrive dans tous les types, y compris `production`.

3. **`speed > 0` lors d'un `downtime`** : la machine s'est arrêtée alors qu'elle était en régime. La vitesse enregistrée est celle du régime *avant* l'arrêt.

4. **`speed > 0` lors d'un `idle`** : la machine était en régime et s'est mise en attente sans s'arrêter complètement (ex. manque d'approvisionnement amont).

5. Les valeurs de speed ne sont pas continues : elles reflètent des paliers de consigne (ex. 975, 1300, 1625, 4500, 4650, 5526, 6176, 6500 pkg/h).

---

## Les champs `pi` / `po` : compteurs cumulatifs de packages

`pi` (packages in) et `po` (packages out) sont des **compteurs absolus cumulatifs** par machine, *non* des volumes produits pendant l'intervalle.

- La valeur d'un intervalle est la valeur du compteur **à la fin** de cet intervalle.
- Pour obtenir le volume produit sur un intervalle, il faut calculer `pi[n] - pi[n-1]` (différence entre lignes consécutives de la même machine).
- Quand `pi` ou `po` ne changent pas entre deux lignes consécutives, rien n'a été produit/consommé.
- `pi - po` représente le **rejet** (packages entrés mais non sortis conformes). On observe des valeurs négatives (incohérences ou remises à zéro du compteur).
- Les compteurs ne sont pas strictement croissants sur toutes les machines (remises à zéro détectées).

---

## Synthèse : comment lire le log

```
Une ligne = un intervalle sur une machine
  → type    : ce que faisait la machine
  → alarm   : pourquoi (A_000 = rien, autre = cause d'arrêt non planifié)
  → speed   : à quelle vitesse nominale tournait la ligne
  → pi/po   : compteurs cumulatifs (calculer les diff pour avoir les volumes)
  → elapsed : durée de l'intervalle en ms
```

La détection d'anomalies portera naturellement sur :
- Les `downtime` fréquents ou longs (par alarme, par machine, par période)
- Les `performance_loss` prolongés (speed élevé mais production faible)
- Les ratios pi/po anormaux (taux de rejet)
- Les transitions d'état inhabituelles entre intervalles
