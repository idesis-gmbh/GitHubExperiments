# Von rohem JSON zum Data Warehouse: GitHub-Daten lokal analysieren

Wer verstehen will, wie Open-Source-Entwicklung im großen Maßstab aussieht, braucht Daten. Viele Daten. Das [GitHub Archive](https://www.gharchive.org/) stellt jedes öffentliche GitHub-Ereignis – Commits, Pull Requests, Issues, Releases – als komprimierte JSON-Streams frei zur Verfügung. Pro Tag landet man dabei schnell bei über einem Gigabyte komprimierter Rohdaten.

Die eigentliche Frage lautet: Wie macht man daraus etwas Auswertbares?

Mit **GitHubExperiments** haben wir ein vollständiges, lokal lauffähiges Data Warehouse entwickelt, das genau diese Lücke schließt – vom rohen JSON-Archiv bis hin zu einem sauberen Star-Schema mit Slowly Changing Dimensions. Keine Cloud-Abhängigkeiten, keine externen Services, alles auf dem eigenen Rechner.

---

## Die Herausforderung: 700 Attribute, verschachtelt und variabel

GitHub-Archive-Events sind kein einfaches, flaches JSON. Je nach Event-Typ unterscheidet sich die Struktur erheblich, Felder tauchen auf oder fehlen, und verschachtelte Objekte ziehen sich tief durch das Datenmodell. Insgesamt kommen so rund **700 Attribute** zusammen – als einzelne, breite Tabelle schlicht nicht handhabbar.

Unsere Lösung: automatische **Schema Discovery**. Ein Python-Skript traversiert den vollständigen Typenbaum, den DuckDB aus dem rohen JSON ableitet, und generiert daraus direkt die SQL-Modelle für die weitere Pipeline. Structs mit `id`-Feld werden als Entitätsreferenzen erkannt und zu Dimensionen, Structs ohne `id` werden flach in die übergeordnete Tabelle eingebettet. Das Ergebnis: ein konsistentes Star-Schema, das die natürliche Struktur der Daten widerspiegelt – ohne manuelle Modellierungsarbeit.

Dabei taucht ein praktisches Problem auf: Spalten, die in der ersten eingelesenen Datei ausschließlich NULL-Werte enthalten, inferiert DuckDB als generischen `JSON`-Typ. Tauchen in späteren Dateien dann echte Werte auf, schlägt das Staging fehl. Die Lösung ist das **kanonische Sample** – eine synthetisch erzeugte JSON-Datei, die für jede Spalte mindestens einen Non-Null-Wert enthält. So ist die Typinferenz von Anfang an stabil, unabhängig davon, welche Archive danach geladen werden.

---

## Der Stack: dbt-duckdb, lokal und schnell

Das Herzstück ist [dbt-duckdb](https://github.com/duckdb/dbt-duckdb): dbt als Transformations-Framework, DuckDB als In-Process-Analysedatenbank. Was in der Cloud eine aufwändige Infrastruktur erfordern würde, läuft hier auf einem einzelnen Laptop – und das überraschend schnell.

Die Pipeline ist in klare Schichten aufgeteilt:

- **Staging** liest jede `.json.gz`-Datei gemeinsam mit dem kanonischen Sample über `read_json_auto` ein – das Sample stellt korrekte Typinferenz sicher, wird aber per `where`-Klausel aus dem Ergebnis herausgefiltert. `union_by_name` vereinheitlicht die variablen Schemata der verschiedenen Event-Typen.
- **Dimensions** bilden den aktuellen Zustand jeder Entität ab – User, Repository, Organisation, Issue und mehr. Standardmäßig per SCD1 (einfach und idempotent), optional per SCD2 mit vollständiger Änderungshistorie.
- **Facts** enthält eine Zeile pro GitHub-Event mit skalaren Attributen und Fremdschlüsselreferenzen in die Dimensionstabellen.
- **Marts** aggregieren die Faktdaten für typische Analysen: Aktivität nach Tag oder Tageszeit, aufgeschlüsselt nach Organisation, Repository, Event-Typ und Autor.

Die inkrementelle Verarbeitung sorgt dafür, dass bereits verarbeitete Dateien nicht erneut eingelesen werden – neue Archive-Dateien werden einfach dazugefügt.

---

## Slow Changing Dimensions – pragmatisch umgesetzt

Dimensionsdaten ändern sich: Repositories werden umbenannt, Nutzerprofile aktualisiert, Organisationen restrukturiert. SCD-Strategien entscheiden, wie mit solchen Änderungen umgegangen wird.

In GitHubExperiments ist **SCD1 der Standard**: Die Dimension spiegelt stets den zuletzt beobachteten Zustand wider – einfach, idempotent, ohne Überraschungen beim Reimport. Wer die vollständige Änderungshistorie braucht, kann einzelne Dimensionen auf **SCD2** umstellen: dbt Snapshots legen dann für jede Zustandsänderung eine neue Zeile an, mit `dbt_valid_from` und `dbt_valid_to` als Gültigkeitszeitraum.

Ein wichtiges Detail: Die Dimensionen repräsentieren den *beobachteten* Zustand – also das, was aus den Events hervorgeht. Stille Änderungen zwischen zwei Events werden nicht erfasst. Das ist kein Bug, sondern eine bewusste Entscheidung: Das System modelliert das, was die Daten zeigen.

---

## Einstieg in Minuten

Das Projekt ist auf schnelle Reproduzierbarkeit ausgelegt. Nach dem Klonen des Repositories genügt `uv sync`, um alle Abhängigkeiten zu installieren. Dann eine Handvoll Archive-Dateien herunterladen und mit `--canonical-schema` den ersten Lauf starten – das generiert die dbt-Modelle auf Basis eines kanonischen Samples und legt damit das Schema für alle weiteren Läufe fest.

```bash
git clone https://github.com/idesis-gmbh/githubexperiments.git
cd githubexperiments
uv sync
wget -P data/gharchive/ https://data.gharchive.org/2026-03-01-{0..23}.json.gz
uv run main.py --canonical-schema
uv run main.py
```

Das kanonische Sample und die generierten SQL-Modelle sind ins Repository eingecheckt – `--canonical-schema` muss nur nach einem Datenbank-Reset oder bei Schema-Änderungen im GitHub Archive erneut ausgeführt werden. Wer das Sample aus echten Daten erzeugen möchte, kann den zweistufigen Weg über `--infer-schema` gefolgt von `--canonical-sample` nehmen.

Eine Stunde GitHub-Daten: ~50 MB komprimiert, ~100 MB in DuckDB. Ein voller Tag: ~1 GB komprimiert, ~2 GB in DuckDB. Die Verarbeitung läuft dabei überraschend flott – pro Stunde Archivdaten dauert ein vollständiger Pipeline-Durchlauf unter einer Minute. Für erste Analysen reicht eine einzelne Stunde.

---

## Was lässt sich damit herausfinden?

Sechs mitgelieferte Beispielanalysen zeigen, wohin die Reise gehen kann: Event-Typ-Verteilung, aktivste Repositories, aktivste Bots und User, aktivste Organisationen, stündliche Aktivitätsmuster und die Aufteilung zwischen Organisations- und persönlichen Repos. Alle Abfragen lassen sich direkt gegen die DuckDB-Datenbank ausführen – mit dem DuckDB-CLI, einem SQL-Client oder einem Notebook.

---

## Sieben Tage GitHub – ein Blick in die Daten

Um zu zeigen, was das System in der Praxis leistet, haben wir die Daten vom 1. bis 7. März 2026 verarbeitet – knapp **9,9 Millionen Events** aus dem öffentlichen GitHub-Archiv.

**Push-Events dominieren klar.** Über 55 % aller Events sind `PushEvent`, gefolgt von `CreateEvent` (15,5 %) und `PullRequestEvent` (7,9 %). Das Verhältnis spiegelt wider, wie GitHub-Entwicklung tatsächlich aussieht: viel direktes Schreiben von Code, deutlich weniger formaler Review-Prozess.

**Persönliche Repos machen 80 % der Aktivität aus.** Nur 20 % der Events stammen aus Organisations-Repositories – ein Hinweis darauf, dass GitHub nach wie vor eine stark von Einzelpersonen geprägte Plattform ist, auch wenn Organisationen in der öffentlichen Wahrnehmung dominieren.

**Bots sind nicht zu übersehen.** Mit über einer Million Events führt `github-actions[bot]` die Bot-Rangliste mit weitem Abstand an, gefolgt von `dependabot[bot]` und `renovate[bot]`. Auffällig in den Top 20: `Copilot`, `chatgpt-codex-connector[bot]` und `gemini-code-assist[bot]` – KI-gestützte Entwicklungswerkzeuge haben sich innerhalb kürzester Zeit als feste Größe im GitHub-Ökosystem etabliert.

**Die Top-Repositories verraten den Zeitgeist.** Unter den aktivsten Repos der Woche finden sich prominent KI-bezogene Projekte: `anthropics/claude-code`, `openai/symphony`, `affaan-m/everything-claude-code`. Solche Rankings sind naturgemäß ein Schnappschuss – welche Repositories gerade oben stehen, verschiebt sich von Woche zu Woche je nach Launches, viralen Momenten und Community-Aktivität. Genau das macht sie zu einem interessanten Signal: Wer regelmäßig nachschaut, bekommt ein Gefühl dafür, was die Entwickler-Community gerade beschäftigt.

---

## Fazit

GitHubExperiments demonstriert, wie weit man mit modernem Open-Source-Tooling bei der lokalen Datenverarbeitung kommt. dbt und DuckDB nehmen gemeinsam die Komplexität eines klassischen Data-Warehouse-Stacks auf sich – ohne Cloud, ohne Infrastruktur, ohne Overhead.

Der vollständige Quellcode ist auf GitHub verfügbar: [idesis-gmbh/githubexperiments](https://github.com/idesis-gmbh/githubexperiments)

---

*Weiterführende Ressourcen:*
- [GitHub Archive](https://www.gharchive.org/)
- [dbt guide to dimensional modeling](https://www.getdbt.com/blog/guide-to-dimensional-modeling)
- [dbt snapshots documentation](https://docs.getdbt.com/docs/build/snapshots)