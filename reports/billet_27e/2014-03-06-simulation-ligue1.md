---                                                                                                                                                                  
layout: post                                                                                                                                                         
title: "Simulation de la fin du championnat de Ligue 1 2013/2014"                                                                                                                                                        
category: posts                                                                                                                                                      
---  








<div class="alert">
 Il y a désormais une <a href="/app/sim/">application en ligne</a>, régulièrement
 mise à jour, pour visualiser les résultats des simulations de différents championnats.
</div>

# C'est quoi ?

La fin du championnat approchant, les mêmes questions reviennent fréquemment : le
titre est-il déjà joué ? Le 19ème du classement a-t-il encore une chance de rester
en Ligue 1 ? Qui peut encore croire à une place en Champions League ?

On peut apporter des éléments de réponse à ces questions en effectuant une
simulation. Il ne s'agit pas ici de s'écrouler dans la surface en hurlant, mais
plutôt, pour l'ensemble des matchs restant à jouer, de tirer au sort le résultat de la rencontre et de voir au final quels sont les classements obtenus.

La première partie présente la méthode utilisée. Si vous êtes pressés vous
pouvez passer directement aux résultats.

À noter que les [données et le code source utilisés](https://github.com/juba/simulation-ligue1) sont librement téléchargeables.


# Méthode

Toute la question est de savoir comment on tire au sort le résultat d'une rencontre
tout en gardant un minimum de logique sportive, sans quoi ça n'aurait aucun sens.

On regarde d'abord les journées pour lesquelles les résultats sont connus. À partir
des scores des différentes rencontres, on calcule, pour chaque équipe, le pourcentage
de victoires, de nuls et de défaites, à domicile et à l'extérieur. On interprète
alors ces pourcentages en probabilités pour la suite des rencontres : si une équipe
a remporté 70% de ses matchs à domicile jusque-là, on considère que la probabilité
qu'elle remporte un prochain match à domicile est de 7 chances sur 10.

Pour chaque rencontre à venir, on combine alors les probabilités de victoire, nul et
défaite à domicile de l'équipe qui reçoit, et celles de victoire, nul et défaite à
l'extérieur pour l'équipe qui se déplace. Ceci permet de calculer trois nouvelles
probabilités pour la rencontre : celle d'une victoire à domicile, celle d'un nul,
et celle d'une victoire à l'extérieur. 

<div class="alert" style="font-size: 80%;">
<a data-toggle="collapse" data-target="#explications" style="cursor: pointer;">Comment les probabilités sont-elles combinées ?</a>
 <div id="explications" class="collapse">
En pratique les trois probabilités concernant l'issue du match sont calculées de la manière suivante :

<ul>
<li>La probabilité d'une victoire de l'équipe qui reçoit est la moyenne de la probabilité
de victoire à domicile de l'équipe qui reçoit, et de celle de défaite à l'extérieur de
l'équipe qui se déplace.</li>
<li>À l'inverse, la probabilité d'une victoire à l'extérieur est la moyenne entre la
probabilité de victoire à l'extérieur de l'équipe qui se déplace, et celle de défaite
à domicile de l'équipe qui reçoit.</li>
<li>Enfin, la probabilité d'un match nul est la moyenne entre la probabilité d'un nul
à domicile pour l'équipe qui reçoit, et celle d'un nul à l'extérieur pour l'équipe
qui se déplace</li>
</ul>

L'avantage est que la somme de ces trois probabilités fait toujours 1, ce qui est
toujours bien pour des probabilités...
 </div>
</div>

On utilise alors ces probabilités pour tirer aléatoirement le résultat du match.
On fait cette opération pour tous les matchs à venir, et on peut alors calculer le 
nombre de points et le classement simulés pour chaque équipe au soir de la 38ème
journée.


# Limites

Il ne s'agit évidemment que d'une méthode possible parmi d'autres. L'avantage est
qu'elle prend en compte si le match est joué à domicile ou à l'extérieur, ainsi
que le niveau des équipes, mesuré par leurs résultats précédents. 

Mais cette approche a évidemment plusieurs limites :

* elle "fige" le niveau d'une équipe à celui de la dernière journée connnue, et ne peut
évidemment pas prendre en compte des dynamiques propres à chaque équipe qui 
interviendraient pendant les journées à venir.

* elle ne prend pas en compte les événements tels que les blessures ou le fait que
certaines équipes jouent plus de matchs que d'autres.

* elle ne tient pas compte des aspects tactiques ou du fait que le jeu de certaines
équipes convient plus ou moins bien à d'autres.


# Résultats

Grâce à cette méthode on peut simuler une fin de championnat, et obtenir un classement
final possible. Cela n'a aucun intérêt vu l'aspect très aléatoire du résultat. On peut
par contre simuler 1000 fins de championnats, et regarder les différents classements
obtenus. C'est déjà beaucoup plus intéressant, et c'est donc ce qu'on a fait.

Ici on prend en compte les résultats obtenus lors des 15 dernières journées précédant
la dernière en date (c'est-à-dire la 27ème), et on a effectué 
1000 simulations de la fin du championnat, c'est-à-dire des résultats de toutes les
rencontres restantes. Pour chaque équipe, on a donc 1000 totaux de point différents
obtenus et 1000 classements à la fin du championnat.

## Moyenne des points

On pourrait regarder d'abord le nombre de points obtenus en moyenne par chaque équipe
lors des 1000 simulations, et le classement qui en découle. Le tableau correspondant
était affiché dans une précédente version de ce billet, mais j'ai décidé de le retirer,
car celui-ci est fondamentalement trompeur.




La moyenne n'est qu'un résumé, elle n'est donc pas très intéressante car elle 
écrase toutes les variations : quels ont été le nombre minimal et le nombre maximal
de points obtenus par chaque équipe ? Quels étaient les nombres de points les plus
fréquents ? En ne donnant qu'un classement basé sur la moyenne des points obtenus,
on peut faire croire que les résultats de ces simulations conduisent à fabriquer un
unique classement, alors qu'il est beaucoup plus intéressant de parler en termes de
variabilité des points obtenus, et de probabilités de classement pour chaque équipe.

## Variation du nombre de points obtenus

On peut représenter graphiquement les résultats des 1000 simulations tout en préservant 
la variabilité, par exemple sous forme de [boîtesà moustaches](https://www.tns-ilres.com/cms/Home/WikiStat/La-boite-a-moustaches) :

![center](/images/2014-03-06-simulation-ligue1/graph_points.png) 


Ou sous forme de "graphe en violons". Dans ce cas, la "patate" est d'autant plus
haute que la fréquence du nombre de points correspondant est élevée.

![center](/images/2014-03-06-simulation-ligue1/graph_pointsv.png) 


Quelle conclusion tirer de ces graphiques ? 

* *A priori* les deux premières places sont jouées. Pour que Paris ne soit pas 
champion il faudrait que l'équipe ait une performance exceptionnellement basse, 
et que Monaco ait un nombre de points très élevé. Et il est encore moins probable
que Monaco soit rattrapé.

* La troisième place se joue entre Lille et Saint-Étienne, avec un léger avantage
pour les Verts.

* Pour la relégation, si Ajaccio est définitivement en Ligue 2, Valenciennes et 
Sochaux sont en position très délicates, en concurrence essentiellement avec 
Évian Thonon-Gaillard, les autres équipes étant relativement à l'abri.


## Classement des équipes

On peut aussi regarder les résultats de ces simulations équipe par équipe. Pour
chaque club, on regarde la répartition des classements lors de ces 1000
simulations, et on peut en déduire la probabilité de chaque position obtenue.

C'est ce qu'on représente sur le graphique suivant :

<i class="icon-question-sign icon-2x icon-popover pull-left" data-toggle="popover"
data-original-title="Lecture" data-content="La hauteur de chaque barre représente
la probabilité que le club finisse à cette position en fin de championnat">
</i>

![center](/images/2014-03-06-simulation-ligue1/graph_position.png) 


Comment interpréter ce graphique ? 

* Dans les 1000 simulations effectuées, le Paris SG arrive en 1ère position dans 88%
des cas. On peut convertir ce pourcentage en probabilité en disant que Paris a 8,8
chances sur 10 de finir champion.

* De même Monaco a 80% de chances de finir 2ème.

* Pour la troisième place, Saint-Étienne aurait une chance sur deux d'accrocher un tour
préliminaire de Champions League, contre 3 chances sur 10 pour Lille. Marseille n'a
que 7% de chances, et Lyon 2%.

* Pour la relégation, Ajaccio finit relégué dans 100% des simulations, Sochaux a 70% de
chances de descendre en L2, contre un peu plus de 60% pour Valenciennes. À l'inverse,
Évian a 3 chances sur 10 de descendre, Nice 18% de chances et Rennes 10%.





# Liens

Les résultats et le calendrier des matchs sont extraits automatiquement de
[la page Calendrier](http://www.maxifoot.fr/calendrier-ligue1.php) du site
Maxifoot.

[Fabien Torre](http://www.grappa.univ-lille3.fr/~torre/Football/) met également
en ligne, et depuis bien plus longtemps, des simulations de fins de championnat,
avec une méthode différente mais assez semblable (je n'avais pas connaissance de 
ses travaux avant d'avoir développé cette application).


