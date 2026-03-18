Questo flusso di lavoro è tra i più semplici da adottare:
- il classico branch `main` (o `master`) costituirà la linea principale di sviluppo;
- parallelamente ad esso si dirameranno `n` *feature branch*, ovvero rami di sviluppo focalizzati su funzionalità specifiche da aggiungere al progetto.

Quando si comincia a lavorare su una nuova funzionalità, si crea un nuovo ramo partendo da *main*:
```shell
git switch main
git pull
git switch -c nuova_funzionalita
```

I *commit* relativi alla nuova funzionalità verranno eseguiti nel ramo corrispondente. Il ramo può restare solo nel _repository_ locale oppure essere pubblicato anche nel _repository_ centrale, così da permettere ad altri membri del _team_ di collaborare:

```shell
git push origin nuova_funzionalita
```

In questo secondo caso è utile aggiungere anche:

```shell
git branch --set-upstream-to=origin/nuova_funzionalita nuova_funzionalita
```

così che ogni futuro comando `git pull`, quando localmente è attivo il ramo `nuova_funzionalita`, faccia automaticamente riferimento a `origin/nuova_funzionalita`. In altre parole stiamo dicendo a `git` di voler mantenere in sincronia la ramificazione locale e quella remota.

Se non configuriamo un ramo remoto di riferimento, `git pull` e `git push` potrebbero richiedere di specificare esplicitamente quale ramo remoto usare, perché `git` non saprebbe automaticamente con quale ramo mantenere la sincronizzazione.

Lo stesso risultato si può ottenere direttamente al momento della creazione del ramo remoto nel _repository_ centrale:

```shell
git push -u origin nuova_funzionalita
```

Nel momento in cui la nuova funzionalità è pronta per essere rilasciata in produzione, si può effettuare il *merge* con *main*:

```shell
git switch main
git pull
git merge --squash nuova_funzionalita
git commit -m "Aggiunge nuova funzionalità"
git push origin main
```

L'opzione `--squash` aggiunge tutte le modifiche apportate in `nuova_funzionalita` in un singolo *commit* nel ramo `main`:

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

Il comando `git branch -d` cancella il ramo locale solo se `git` riconosce che la sua cronologia è già confluita nel ramo corrente. Questo avviene normalmente quando si utilizza un _merge commit_ (ad esempio con `--no-ff`) oppure un _fast-forward_.

Nel caso di _squash merge_, invece, `git` potrebbe mostrare un messaggio come:

```
error: The branch 'nuova_funzionalita' is not fully merged.
```

Questo accade perché `git merge --squash` non crea un vero _merge commit_: le modifiche del ramo vengono integrate in `main` tramite un nuovo _commit_, ma la cronologia originale del ramo non viene collegata a quella di `main`. Di conseguenza `git` non può stabilire automaticamente che il ramo sia già stato incorporato.

Se siamo certi che le modifiche siano state integrate correttamente, è comunque possibile eliminare il ramo forzando l’operazione:

```
git branch -D nuova_funzionalita
```

La situazione finale sarà, nel caso di *squash*:

```
┈◯─◯─◯─◯─◯─◯─⚫  <┄┄┄ main
```

mentre nel caso di *no fast forward*:

```
┈◯─◯─◯─◯─◯─◯─Ⓜ  <┄┄┄ main
   │      ┌──┘   
   └◯─◯─◯─┘         
```

Nel secondo caso la cronologia del ramo rimane esplicitamente collegata alla storia di `main`: il ramo perde il proprio nome ma i suoi _commit_ restano visibili nella struttura del _repository_.

**NOTA**: se l'obiettivo principale è mantenere main ordinato e leggibile, conviene preferire lo _squash merge_. Se invece si vuole conservare la storia completa dello sviluppo della funzionalità, è più opportuno utilizzare un _merge_ con `--no-ff`.
