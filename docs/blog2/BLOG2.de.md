# Das Data Warehouse zum Leben erwecken: GitHub-Daten interaktiv erkunden mit Rill

Der erste Beitrag dieser Serie hat gezeigt, wie sich 25,8 Millionen GitHub-Events in ein sauberes Star-Schema überführen lassen – automatisch, lokal, ohne Cloud. Das Ergebnis ist ein Data Warehouse mit materialisierten Dimensions- und Faktentabellen, bereit für Analysen.

Die eigentliche Frage folgt auf dem Fuß: Wie erkundet man diese Daten, ohne für jede neue Frage eine neue SQL-Abfrage schreiben zu müssen?

Mit [Rill](https://www.rilldata.com/) lässt sich das Data Warehouse direkt als interaktives Dashboard öffnen – keine separate Infrastruktur, keine Konfigurationsdatei pro Chart, kein BI-Server. Rill liest die DuckDB-Datenbank direkt ein und erzeugt daraus eine explorative Oberfläche, die das Konzept von Cube und Drilldown greifbar macht.

---

## Cube und Drilldown – was das in der Praxis bedeutet

Ein **Cube** ist eine multidimensionale Sicht auf aggregierte Daten. Jede Achse ist eine Dimension – Zeit, Event-Typ, Repository, Actor, Organisation –, jede Zelle enthält ein Maß, hier `event_count`. Die Mart-Tabelle `activity_by_date` ist nichts anderes als ein voraggregierter Cube-Ausschnitt.

**Drilldown** bedeutet, in diesen Cube hineinzuklicken: von allen Events der Woche → gefiltert auf einen Repository-Namen → weiter auf einen Actor-Typ → schließlich auf einen einzelnen Nutzer. Jeder Klick fügt eine Filterbedingung hinzu und schränkt die Sicht ein. Was in SQL eine neue `WHERE`-Klausel wäre, passiert in Rill durch einen einzigen Klick.

---

## Die Mart-Schicht als Grundlage

Rill ist schnell, wenn es auf materialisierten, vorberechneten Tabellen arbeitet. Die entscheidende Konfiguration im dbt-Projekt:

```yaml
models:
  analytics:
    staging:
      +materialized: table
    dimensions:
      +materialized: incremental
    facts:
      +materialized: incremental
    marts:
      +materialized: table
```

Marts werden als `table` materialisiert, nicht als `view`. Der Unterschied ist entscheidend: Eine View re-evaluiert bei jedem Rill-Zugriff die vollständige Join-Kette über die Faktentabelle mit 25 Millionen Zeilen. Eine materialisierten Tabelle enthält wenige hunderttausend voraggregierte Zeilen – DuckDB scannt sie in Millisekunden.

Einen weiteren Geschwindigkeitsgewinn bringt eine kleine Ergänzung in der Schema Discovery: Die Faktentabelle bekommt zwei berechnete Spalten direkt mit auf den Weg:

```python
computed_columns = [
    'cast("created_at" as date) AS "created_date"',
    'date_trunc(\'hour\', cast("created_at" as timestamp)) AS "created_hour"',
]
```

Damit entfällt der `cast` zur Laufzeit in der Mart-Abfrage – der Join auf die Date-Dimension wird zu einem einfachen Gleichheitsvergleich, den DuckDB ohne per-row-Berechnung auflösen kann.

---

## Sich selbst in 25 Millionen Events finden

Um zu zeigen, was Drilldown in der Praxis bedeutet, lohnt ein konkretes Beispiel. Ausgangspunkt ist die globale Sicht: 25,8 Millionen Events, keine Filter.

**Schritt 1: Repository-Name.** Ein Klick auf `openclaw` in der Repo-Dimension filtert die gesamte Ansicht auf alle Events dieses Repositories – 37.600 in der Woche vom 1. bis 7. März 2026.

**Schritt 2: Actor-Typ.** Die Dimension `Actor Type` zeigt jetzt die Aufteilung innerhalb von `openclaw`: Bot (15.800), User (12.800), null (9.000). Ein Klick auf `User` schränkt weiter ein.

**Schritt 3: Actor Login.** Jetzt ist die Liste der Nutzer überschaubar. `steipete` steht oben – 876 Events in sieben Tagen.

Das Ergebnis ist im Explore-View ablesbar: 876 Events, verteilt auf mehrere Repositories (`steipete/gogcli`, `steipete/summarize`, `openclaw.ai` und weitere), dominiert von `IssueCommentEvent` (360) und `PushEvent` (324). Der Zeitverlauf zeigt einen deutlichen Aktivitätspeak um den 4. März, danach Rückgang – ein Muster, das in einer statischen Abfrage schlicht nicht sichtbar wäre.

*![GIF: Explore-Sequenz, ~13 Sekunden – Drilldown von Repo Name → Actor Type → Actor Login](explore.gif)*

---

## Der Pivot-View: Struktur auf einen Blick

Neben dem explorativen Explore-View bietet Rill einen **Pivot-View**, der Dimensionen als Zeilen- und Spaltenachsen eines klassischen Kreuztabellen-Layouts darstellt.

Im Beispiel: Zeilen nach `Repo Name`, aufgeklappt nach `Actor Type`, Maß `Total events`. Das Ergebnis zeigt auf einen Blick, was der erste Blogbeitrag bereits als Tendenz beschrieben hat: Die aktivsten Repositories der Woche sind keine bekannten Open-Source-Projekte.

`qiao-lima/TitanManife...` führt mit 60.000 Events, `escapingwork/teenag...` folgt mit 53.600. Aufgeklappt zeigt sich bei diesen Repos fast ausschließlich Bot-Aktivität – automatisierte Commits, generierte Manifeste, Datenpipelines. `openclaw` hingegen, auf Platz 5 mit 37.600 Events, weist eine echte Mischung aus Bot, User und null auf: ein aktiv entwickeltes Projekt mit menschlichen Beitragenden und CI-Automatisierung.

Der Pivot-View macht diesen Unterschied ohne eine einzige SQL-Abfrage sichtbar.

*![GIF: Pivot-Sequenz, ~16 Sekunden – Repo Name × Actor Type, openclaw aufgeklappt](pivot.gif)*

---

## Was Rill nicht ist

Rill ist kein vollständiges BI-Tool im Sinne von Looker oder Metabase. Es gibt keine persistenten Dashboards mit Zugriffsrechten, keine eingebetteten Reports, keine komplexen berechneten Felder im UI. Wer ein Reporting-System für mehrere Stakeholder aufbauen will, ist hier falsch.

Was Rill ist: ein schnelles Explorationswerkzeug für Menschen, die ihre Daten bereits kennen und schnell neue Fragen stellen wollen. Die Kombination mit dbt und DuckDB passt dabei sehr gut – das Data Warehouse liefert die strukturierten, materialisierten Tabellen, Rill macht sie navigierbar.

---

## Fazit

Das Data Warehouse aus dem ersten Beitrag ist notwendig, aber nicht hinreichend. Erst mit einer interaktiven Schicht wird aus einem Set von SQL-Abfragen ein echtes Explorationswerkzeug.

Rill fügt sich dabei ohne Aufwand in den bestehenden Stack ein: eine YAML-Datei, die auf die DuckDB-Datenbank zeigt, und der Cube ist navigierbar. Die Investition in ein sauberes Star-Schema mit materialisierten Marts zahlt sich direkt aus – als Antwortzeit unter einer Sekunde, auch bei 25 Millionen Events.

Der vollständige Quellcode ist auf GitHub verfügbar: [idesis-gmbh/githubexperiments](https://github.com/idesis-gmbh/githubexperiments)

---

*Weiterführende Ressourcen:*
- [Rill](https://www.rilldata.com/)
- [Rill Dokumentation](https://docs.rilldata.com/)
- [GitHub Archive](https://www.gharchive.org/)
- [Erster Beitrag: Von rohem JSON zum Data Warehouse](https://github.com/idesis-gmbh/githubexperiments)
