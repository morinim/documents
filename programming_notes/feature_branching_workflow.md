Questo flusso di lavoro è tra i più semplici da adottare:
- il classico branch `main` (o `master`) costituirà la linea principale di sviluppo;
- parallelamente ad esso si dirameranno `n` *feature branch*, ovvero rami di sviluppo focalizzati su funzionalità specifiche da aggiungere al progetto.

Così, quando si comincia a lavorare su una nuova funzionalità, si crea un nuovo *branch* partendo da *main*:
```shell
git switch main
git pull
git switch -c nuova_funzionalita
```

I *commit* relativi alla nuova funzionalità avverranno nel *branch* corrispondente. Questo potrebbe risiedere solamente nel nostro *repository* locale, oppure esser disponibile anche nel *repository* centrale così da permettere ad altri componenti del *team* di collaborare:

```shell
git push origin nuova_funzionalita
```

In questo secondo caso è utile aggiungere anche:

```shell
git branch --set-upstream-to=origin/nuova_funzionalita nuova_funzionalita
```

così che ogni futuro comando `git pull`, quando localmente è attivo il ramo `nuova_funzionalita`, faccia automaticamente riferimento a `origin/nuova_funzionalita`. In altre parole stiamo dicendo a `git` di voler mantenere in sincronia la ramificazione locale e quella remota.

Se non facciamo così dobbiamo sembre aver presente in quale ramo locale siamo e quali *commit* vogliamo importare specificandolo nel comando `git pull` (così come per `git push` e `git fetch`).

Lo stesso risultato si poteva ottenere della ramificazione nel *repository* centrale:

```shell
git push -u origin nuova_funzionalita
```

Nel momento in cui la nuova funzionalità è pronta per essere rilasciata in produzione, si può effettuare il *merge* con *main*:

```shell
git switch main
git pull
git merge --squash nuova_funzionalita
git push origin main
```

L'opzione `--squash` aggiunge tutte le modifiche apportate in `nuova_funzionalita` in un singolo commit nel ramo `main`:

```
┈◯─◯─◯─◯─◯─◯─⚫  <┄┄┄ main                lo squash merge commit contiene tutte le modifiche di `nuova_funzionalita`
   │      ┌──┘   
   └◯─◯─◯─┘      <┄┄┄ nuova_funzionalita
```

In alternativa si può utilizzare l'opzione `--no-ff` (*no fast forward*) così da creare esplicitamente un *merge commit* che rappresenti un "punto di giunzione" tra `nuova_funzionalita` e `main` che identifichi, anche visivamente, un nuovo rilascio in produzione:

```
┈◯─◯─◯─◯─◯─◯─Ⓜ  <┄┄┄ main
   │      ┌──┘   
   └◯─◯─◯─┘      <┄┄┄ nuova_funzionalita
```

Dopo il *merge* è buona norma eliminare il ramo di sviluppo relativo alla funzionalità completata (eventualmente, anche dal *repository* centrale):

```shell
git branch -d nuova_funzionalita
git push origin --delete nuova_funzionalita
```

Il primo comando potrebbe mostrare un *warning* proprio relativo al fatto che il ramo di sviluppo è stato cancellato solo localmente.

La situazione finale sarà nel caso di *squash*:

```
┈◯─◯─◯─◯─◯─◯─⚫  <┄┄┄ main
```

mentre nel caso di *no fast forward*:

```
┈◯─◯─◯─◯─◯─◯─Ⓜ  <┄┄┄ main
   │      ┌──┘   
   └◯─◯─◯─┘         
```

In questo caso il ramo di sviluppo ha perso il suo nome ma non viene effettivamente cancellato.
