<a id="top"></a>

<div align="center">

# highway-route-planner

*Pianifica il percorso con meno tappe lungo un'autostrada di stazioni di servizio.*

![Standard: gnu11](https://img.shields.io/badge/standard-gnu11-0080ff?style=flat)
![Licenza: MIT](https://img.shields.io/badge/licenza-MIT-green?style=flat)

</div>

Prova finale di Algoritmi e Strutture Dati, anno accademico 2022–2023.
Il programma è scritto in C, in un unico file, senza librerie esterne.
La specifica completa è in [`specifica.pdf`](specifica.pdf).

## Indice

- [Il problema](#il-problema)
- [Compilazione](#compilazione)
- [Comandi](#comandi)
- [Scelte implementative](#scelte-implementative)
- [Verifica in locale](#verifica-in-locale)
- [Costi](#costi)

---

## Il problema

Un'autostrada è una sequenza di stazioni di servizio. Ogni stazione è identificata dalla distanza dall'inizio e offre al più 512 veicoli elettrici a noleggio. Da una stazione si raggiungono tutte quelle che distano non più dell'autonomia del veicolo noleggiato.

Il programma legge da standard input una sequenza di comandi che modificano stazioni e veicoli. A ogni richiesta di percorso risponde con quello che ha il minor numero di tappe. A parità di tappe sceglie il percorso che passa per le stazioni più vicine all'inizio dell'autostrada.

## Compilazione

Il codice compila senza warning con le stesse opzioni del verificatore ufficiale.

Con il `Makefile`:

```sh
make
./highway < input.txt > output.txt
```

Direttamente con gcc:

```sh
gcc -Wall -Werror -std=gnu11 -O2 -lm highway.c -o highway
./highway < input.txt > output.txt
```

Per eliminare l'eseguibile: `make clean`.

## Comandi

| Comando | Risposta |
|---|---|
| `aggiungi-stazione <distanza> <n> <autonomia_1> ... <autonomia_n>` | `aggiunta` / `non aggiunta` |
| `demolisci-stazione <distanza>` | `demolita` / `non demolita` |
| `aggiungi-auto <distanza> <autonomia>` | `aggiunta` / `non aggiunta` |
| `rottama-auto <distanza> <autonomia>` | `rottamata` / `non rottamata` |
| `pianifica-percorso <partenza> <arrivo>` | le tappe separate da spazi, oppure `nessun percorso` |

**Esempio.** Date le stazioni a distanza 20 (autonomie 5, 10, 15, 25), 30 (40), 45 (30) e 50 (20, 25), il comando `pianifica-percorso 50 20` risponde `50 30 20`. Anche `50 45 20` ha tre tappe, ma 30 è più vicina all'inizio dell'autostrada di 45.

## Scelte implementative

**Stazioni: albero AVL** ordinato per distanza. Ricerca, inserimento e demolizione costano O(log n). La memoria è proporzionale alle sole stazioni esistenti.

**Veicoli: vettore ordinato in modo decrescente**, allocato su misura invece che con capacità fissa 512. L'autonomia massima, l'unico dato necessario a pianificare, è sempre il primo elemento. La rottamazione usa la ricerca binaria.

**Sintesi dell'autostrada.** Pianificare richiede di scorrere le stazioni in ordine, e la visita dell'albero comporta molti salti in memoria. Il programma mantiene quindi un vettore contiguo di coppie (distanza, autonomia massima). Lo rigenera solo quando cambia l'insieme delle stazioni; aggiungere o rottamare un'auto aggiorna la singola voce.

**Percorso: visita in ampiezza a fasce.** Da una stazione si raggiunge sempre un intervallo contiguo di stazioni successive. Le stazioni raggiungibili con L spostamenti formano quindi un blocco, di cui basta ricordare l'ultimo indice. La visita costa O(k) sul vettore contiguo, senza allocazioni né code esplicite.

Il percorso si ricostruisce a ritroso dall'arrivo. Tra i predecessori validi della fascia precedente si sceglie il primo se si viaggia in avanti, l'ultimo se si torna indietro. In entrambi i casi si ottiene la stazione più vicina all'inizio dell'autostrada, come richiede la regola di spareggio. Numerando le tappe nel verso di marcia, i due sensi di percorrenza condividono lo stesso codice.

**I/O bufferizzato.** I file di prova contengono milioni di token, e leggerli con `scanf` costerebbe più dell'algoritmo. Il programma usa due buffer da 64 KB e un parser di interi scritto a mano.

## Verifica in locale

Per confrontare l'output del programma con quello atteso di un caso di test:

```sh
./highway < caso.txt > risultato.txt
diff atteso.txt risultato.txt
```

Se i due file sono identici, `diff` non stampa nulla.

Durante lo sviluppo il programma è stato controllato con AddressSanitizer (`gcc -fsanitize=address`) e con Valgrind Memcheck, per escludere accessi fuori dai limiti e perdite di memoria. I due strumenti sono incompatibili fra loro e richiedono compilazioni separate.

## Costi

n = stazioni sull'autostrada, k = stazioni fra partenza e arrivo, m ≤ 512 auto.

| Operazione | Costo |
|---|---|
| `aggiungi-stazione` | O(log n + m log m) |
| `demolisci-stazione` | O(log n) |
| `aggiungi-auto`, `rottama-auto` | O(log n + m) |
| `pianifica-percorso` | O(k), più O(n) per rigenerare la sintesi dopo una modifica alle stazioni |

La sintesi si rigenera per intero dopo ogni aggiunta o demolizione di una stazione. Renderla incrementale conviene solo se le modifiche alle stazioni si alternano fittamente alle pianificazioni.

---

[Torna su](#top)
