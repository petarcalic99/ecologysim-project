Rendu V1.0 ECOSYSTEME - 19 décembre 2021

==================================
====MOSIMA=====BLOC:ECOSYSTEME====
==================================

1) Dans le fichier parameters.gaml on a les différents paramètres que l’utilisateur peut modifier.
2) Dans le fichier individual.gaml nous avons implémenté une première version des individus avec une structure en FSM pour gérer leurs comportements dans différents états. 
3) Pour l’instant les individus sont uniquement utilisés pour la consommation, leurs comportements au sein du FSM est mis en commentaire et sera utilisé plus tard lors du merge avec les autres blocs. 
4) Pour faire tourner l’ensemble des agents des différents fichiers, il faut lancer l’expérience “main” dans le fichier main.gaml. 
5) Différentes images sur des boutons en haut à gauche de la carte correspondent aux élevages d’animaux, aux champs de plantes et de coton. 
6) Avant le lancement et pendant la simulation l’utilisateur pourra placer les différentes images sur la carte (une image par case) en cliquant sur un des boutons en haut à gauche de la carte puis en cliquant sur une des cases de la carte pour la placer dessus. 
7) Il est obligatoire d'ajouter au moins une ferme d'animaux, un champ de légumes et un champ de coton pour démarrer la simulation correctement
8) En sortie on trace différentes courbes représentant la consommation et la production des ressources et de l’eau au cours du temps.

===================================
==EXPLICATION=DE=LA=VISUALISATION==
===================================

 ________ ____ ____
|        |    |    |
|        | 2  | 3  |
|   1    |    |    |
|        |____|____|
|        |    |    |
|________| 5  | 6  |
|   4    |    |    |
|________|____|____|

1 : Correspond a la carte de la Californie avec la grille des fermes et champs ainsi que les forêts

2 : En haut se trouve les boutons pour placer les fermes et les champs,
    En bas se trouve la courbe des productions des fermes et champs
    
3 : En haut se trouve la courbe des temperatures de nuit et de jour,
    En bas se trouve a gauche l'image indiquant si on est la nuit ou le jour,
    et a droite l'image indiquant la saison actuelle

4 : Montre les courbes de la météo, en partant de la gauche vers la droite :
    - la courbe de la pluie
    - la courbe du soleil
    - la courbe du vent

5 : Affiche en haut la courbe de la consommation de nourriture par la population et les animaux,
    et en bas la courbe de la consommation en eau
    
6 : Affiche la courbe de la quantité de biodéchets en haut et de gas à effet de serre en bas
