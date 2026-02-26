# Stratégie LinkedIn — Série "Anomaly Detection in Packaging"

---

## 1. Pourquoi un Quarto Book ?

Oui, **Quarto Book est le format idéal** pour ce feuilleton.

**Avantages vs une collection de `.qmd` indépendants :**
- Navigation entre chapitres intégrée (sidebar, prev/next)
- Table des matières globale visible dès l'arrivée sur le site
- Un seul dépôt, un seul site — URL stable à partager sur LinkedIn
- Chaque chapitre = une page autonome avec sa propre URL → parfait pour le lien en commentaire
- Le lecteur qui arrive au chapitre 4 voit qu'il y a 6 chapitres : il remonte, il s'abonne, il revient

**La structure "Book" renforce le storytelling** : le lecteur comprend qu'il est dans une série progressive, pas dans une collection de posts déconnectés.

---

## 2. Structure du Quarto Book

```
packaging-anomaly/
├── _quarto.yml          ← configuration du book
├── index.qmd            ← page d'accueil / introduction générale
├── 01-dataset.qmd       ← Chapitre 1
├── 02-trs.qmd           ← Chapitre 2
├── 03-downtime.qmd      ← Chapitre 3
├── 04-sequences.qmd     ← Chapitre 4
├── 05-anomalies.qmd     ← Chapitre 5
├── 06-prediction.qmd    ← Chapitre 6
├── data/
│   └── clean_data.rds
├── scripts/
│   └── 1 - ETL.R
└── .github/
    └── workflows/
        └── publish.yml  ← déploiement automatique GitHub Pages
```

### `_quarto.yml` (exemple)

```yaml
project:
  type: book
  output-dir: docs

book:
  title: "When Machines Talk: Anomaly Detection in Packaging"
  author: "Arnaud Coqueblin"
  date: today
  chapters:
    - index.qmd
    - 01-dataset.qmd
    - 02-trs.qmd
    - 03-downtime.qmd
    - 04-sequences.qmd
    - 05-anomalies.qmd
    - 06-prediction.qmd

format:
  html:
    theme: cosmo
    code-fold: true        # le code est replié par défaut — lisible par tous
    code-tools: true
    toc: true
```

`code-fold: true` est clé : le Dir. industriel voit les graphiques, le data scientist peut déplier le code. **Un seul document, deux lectures.**

---

## 3. Setup GitHub Pages — Marche à suivre

### Étape 1 — Créer le dépôt GitHub

```bash
# Dans le dossier du projet
git init
git add .
git commit -m "Initial commit"
# Créer le dépôt sur github.com (Public), puis :
git remote add origin https://github.com/TON_USERNAME/packaging-anomaly.git
git push -u origin main
```

### Étape 2 — Configurer GitHub Pages

Dans le dépôt GitHub :
- Settings → Pages → Source : **GitHub Actions**

### Étape 3 — Workflow de déploiement automatique

Créer `.github/workflows/publish.yml` :

```yaml
name: Publish Quarto Book

on:
  push:
    branches: [main]

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: r-lib/actions/setup-r@v2
        with:
          use-public-rspm: true

      - uses: r-lib/actions/setup-r-dependencies@v2

      - uses: quarto-dev/quarto-actions/setup@v2

      - name: Render and Publish
        uses: quarto-dev/quarto-actions/publish@v2
        with:
          target: gh-pages
```

À chaque `git push`, le site se reconstruit automatiquement.

### Étape 4 — URL finale

```
https://TON_USERNAME.github.io/packaging-anomaly/
```

Chaque chapitre aura son URL propre :
```
https://TON_USERNAME.github.io/packaging-anomaly/01-dataset.html
```

---

## 4. La série — Plan crescendo avec suspens

### Principe narratif

Chaque post LinkedIn suit la même mécanique en 4 temps :
1. **Hook** — une phrase qui crée une tension ou une surprise (chiffre, question, paradoxe)
2. **Développement** — 3-5 slides carrousel avec les visuels clés
3. **Résolution partielle** — on répond à la question du hook
4. **Teasing** — une promesse pour le prochain épisode

---

### Épisode 1 — *"Deux ans de données, cinq machines : que nous dit vraiment ce log ?"*

**Niveau** : accessible à tous
**Hook** : *"429 000 lignes de données. Chaque ligne est une machine qui parle. Voici comment l'écouter."*

**Contenu** :
- Ce que représente une ligne du dataset (intervalle, état, alarme)
- Les 5 états d'une machine (production, idle, downtime…) expliqués avec une frise temporelle visuelle
- L'explication de `alarm` : A_000 = silence, le reste = un cri

**Angle concret** : *"Ce log ressemble à ce que votre GMAO ou votre MES génère tous les jours. La différence : on va l'analyser vraiment."*

**Teasing** : *"Mais combien de temps ces machines produisent-elles vraiment ? La réponse, dans le prochain épisode, va surprendre."*

---

### Épisode 2 — *"La machine avec 94% de disponibilité a le pire TRS. Voici pourquoi."*

**Niveau** : OE + Data
**Hook** : *"S4 : disponibilité 94%. TRS : 44%. Ce paradoxe apparent cache une réalité que beaucoup d'usines vivent sans le savoir."*

**Contenu** :
- Définition du TRS en une slide (pas de formule : une image en 3 blocs)
- Tableau comparatif des 5 machines
- Décomposition : s4 perd 25% de son temps ouvert en `performance_loss`
- s2/s3 : disponibilité correcte mais 45% du temps en `idle` → problème de flux, pas de panne

**Angle concret** : *"Vous mesurez votre TRS ? Regardez d'abord où il fuit avant d'investir en maintenance."*

**Teasing** : *"858 heures perdues à cause d'une seule alarme sur une seule machine. On creuse ça la semaine prochaine."*

---

### Épisode 3 — *"Une alarme. 858 heures perdues. Le Pareto que personne n'avait fait."*

**Niveau** : OE + Dir. industriel
**Hook** : *"Sur 133 types d'alarmes, 2 codes représentent plus de 50% du temps d'arrêt total. Lequel avez-vous sur votre ligne ?"*

**Contenu** :
- Graphique Pareto des alarmes (durée totale + fréquence)
- Distinction fréquence vs durée : A_005 = 12 000 événements mais courts / A_006 = moins fréquent mais +6 min en moyenne
- A_045 : 64 occurrences, 17 min de moyenne — l'alarme rare et silencieuse qui coûte cher
- Signature de chaque machine : A_065 exclusive à s1, A_101 sur s5/s2/s3

**Angle concret** : *"Un Pareto des alarmes, c'est 2h de travail. Ça peut orienter 6 mois de plan de maintenance."*

**Teasing** : *"Ces arrêts arrivent-ils par surprise, ou est-ce que la machine envoie des signaux avant de tomber ? C'est ce qu'on cherche dans l'épisode suivant."*

---

### Épisode 4 — *"La machine signale qu'elle va tomber. On ne l'entend pas."*

**Niveau** : Data + OE avancé
**Hook** : *"Avant chaque arrêt, il y a une séquence. Toujours. La question : est-elle détectable ?"*

**Contenu** :
- Analyse des transitions d'états : qu'est-ce qui précède un `downtime` ?
- Les `performance_loss` comme signal précurseur (durée, fréquence avant un arrêt)
- Visualisation des séquences typiques sur s1 autour de A_065
- Introduction de la notion de "fenêtre temporelle d'observation"

**Angle concret** : *"Ce n'est pas de la science-fiction. C'est de l'analyse de séquence sur des données que vous avez déjà."*

**Teasing** : *"On a les séquences. Mais est-ce qu'un algorithme peut apprendre à repérer l'anomalie avant qu'elle se produise ? Réponse dans 7 jours."*

---

### Épisode 5 — *"Anomalie détectée. L'algorithme a vu ce que le tableau de bord avait manqué."*

**Niveau** : Data
**Hook** : *"Un événement 'normal' qui ne l'est pas vraiment. Comment le trouver dans 429 000 lignes ?"*

**Contenu** :
- Approche détection d'anomalies (isolation forest, ou statistique simple selon résultats réels)
- Visualisation des points atypiques (durée, fréquence, contexte machine)
- Un ou deux cas concrets : "cette alarme à 3h du matin, ce dimanche, avec cette durée — c'est anormal"
- Limites : on détecte, on n'explique pas encore

**Angle concret** : *"La détection d'anomalies ne remplace pas l'expert métier. Elle lui pointe où regarder."*

**Teasing** : *"Détecter c'est bien. Prédire, c'est mieux. La semaine prochaine : peut-on anticiper l'arrêt avant qu'il arrive ?"*

---

### Épisode 6 — *"Peut-on prédire un arrêt machine ? Ce que les Bayesian Networks nous apprennent."*

**Niveau** : Data avancé — épisode "wahou"
**Hook** : *"Et si les données de production pouvaient vous dire : dans les 2 prochaines heures, il y a 73% de chances que cette machine s'arrête ?"*

**Contenu** :
- Introduction des Bayesian Networks : en une slide, sans équation — un graphe de causalité
- Variables : type d'intervalle précédent, durée, alarme, heure, machine
- Réseau appris sur les données : quelles variables prédisent le mieux le downtime ?
- Probabilités conditionnelles visualisées
- Performance du modèle (précision, rappel) et limites honnêtes

**Angle concret** : *"Ce modèle tourne sur 2 ans de données d'une vraie ligne. Avec vos données, il tournerait sur votre ligne."*

**Clôture de série** : *"Six épisodes, une ligne de packaging, des vraies données. Le code est intégralement disponible sur GitHub. Qu'est-ce que ça vous inspire pour vos propres lignes ?"*

---

## 5. Format des posts LinkedIn

### Anatomie d'un post

```
[Ligne 1-2] : Hook — tension, chiffre, paradoxe. Pas de contexte.
[Ligne 3]   : (vide — force le "voir plus")
[Corps]     : 3-5 points courts, aérés, lisibles sur mobile
[CTA]       : "Le chapitre complet avec les graphiques et le code R ↓"

[COMMENTAIRE ÉPINGLÉ] : lien vers le chapitre du Book
```

### Carrousel (format recommandé)

- 5-7 slides maximum
- Slide 1 = titre + chiffre clé (identique au hook du post)
- Slides 2-5 = un visuel par idée (pas de texte dense)
- Slide finale = teasing du prochain épisode + "Code sur GitHub"
- Outil : **Canva** (template LinkedIn Carousel, format 1080×1080)

### Rythme

- 1 post tous les **7-10 jours** (pas moins — laisser le temps à l'engagement)
- Publier **mardi ou mercredi matin** (9h-11h) pour maximiser la portée

---

## 6. Checklist avant publication de chaque épisode

- [ ] Chapitre Quarto rendu et déployé sur GitHub Pages
- [ ] URL du chapitre testée
- [ ] Carrousel créé sur Canva (5-7 slides)
- [ ] Post LinkedIn rédigé (hook + corps + CTA)
- [ ] Teasing du prochain épisode présent
- [ ] Lien placé en **commentaire** (pas dans le post)
- [ ] Commentaire épinglé après publication
