Questo flusso di lavoro è tra i più semplici da adottare:
- il classico branch `master` costituirà la linea principale di sviluppo;
- parallelamente ad esso si dirameranno `n` *feature branch*, ovvero rami di sviluppo focalizzati su funzionalità specifiche da aggiungere al progetto.

Così, quando si comincia a lavorare su una nuova funzionalità, si crea un nuovo *branch* partendo da *master*:
```shell
git switch master
git pull
git switch -c nuova-funzionalita
```

I *commit* relativi alla nuova funzionalità avverranno nel *branch* corrispondente. Questo potrebbe risiedere solamente nel nostro *repository* locale, oppure esser disponibile anche nel *repository* centrale così da permettere ad altri componenti del *team* di collaborare:

```shell
git push origin nuova-funzionalita
```

Nel momento in cui la nuova funzionalità è pronta per essere rilasciata in produzione, si può effettuare il *merge* con *master*:

```shell
git switch master
git pull
git merge --no-ff nuova-funzionalita
git push origin master
```

Solitamente viene utilizzata l'opzione `--no-ff` per il *merge* così da creare esplicitamente un *merge commit* che rappresenti un "punto di giunzione" tra il *feature branch* e *master* che identifichi, anche visivamente, un nuovo rilascio in produzione.

Dopo il *merge* è buona norma eliminare il ramo di sviluppo relativo alla funzionalità completata (eventualmente, anche dal *repository* centrale):

```shell
git branch -d nuova-funzionalita
git push origin --delete nuova-funzionalita
```
