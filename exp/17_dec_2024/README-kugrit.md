# KuGrit

KuGrit is my attempt to clone `grit` the multitree todo list manager
Using KuzuDB and NuShell.
Because I want an easy way to benchmark graph databases.

# Literate test
This readme file is also a Literate Programming tutorial
using the `prysk` project to execute the commands.

So my first task was to have an automated version of running the grit test case.

In order to execute this test readme file execute

``` bash
~/r/gh/elv79/deleteme_beeminder_10klocs/nugrit> prysk --shell /bin/bash --indent=4 ./README-kugrit.md
```

# Setup
Lets create a new database (TODO: I wish the original grit had a configurable database file)

    $ cd ~/r/gh/elv79/deleteme_beeminder_10klocs/nugrit
    $ ./kugrit initialize_db
    {"result":"Table Task has been created."}
    {"result":"Table Calendar has been created."}
    {"result":"Table agenda has been created."}
    {"result":"Table children has been created."}
    {"result":"Table parent has been created."}

## Practical guide ##

### Basic usage ###

Let's add a few things we want to do today:

    $ ./kugrit add Take out the trash
    c.day: 2024-12-17
    t.id: '0'
    

    $ ./kugrit add Do the laundry
    c.day: 2024-12-17
    t.id: '1'
    

    $ ./kugrit add Call Dad
    c.day: 2024-12-17
    t.id: '2'
    

Run `grit` without arguments to display the current date tree:

    $ ./kugrit
    c.day: 2024-12-17
    day_plan:
    - id: 0
      name: Take out the trash
      completed_at: null
    - id: 1
      name: Do the laundry
      completed_at: null
    - id: 2
      name: Call Dad
      completed_at: null
    

So far it looks like an old-fashioned to-do list. We can `check` a task to mark it as completed:

    $ ./kugrit check 2
    
    $ ./kugrit
    c.day: 2024-12-17
    day_plan:
    - id: 0
      name: Take out the trash
      completed_at: null
    - id: 1
      name: Do the laundry
      completed_at: null
    - id: 2
      name: Call Dad
      completed_at: null
    

The change is automatically propagated through the graph. We can see that the status of the parent task (the date node) has changed to _in progress_.

### Subtasks ###

Let's add another task:

    $ ./kugrit add Get groceries
    c.day: 2024-12-17
    t.id: '3'
    

To divide it into subtasks, we have to specify the parent (when no parent is given, `add` defaults to the current date node):

    $ ./kugrit add_to 3 Bread
    c.day: 2024-12-17
    t.id: '4'
    

    $ ./kugrit add_to 3 Milk
    c.day: 2024-12-17
    t.id: '5'
    

    $ ./kugrit add_to 3 Eggs
    c.day: 2024-12-17
    t.id: '6'
    

Task 5 is now pointing to subtasks 6, 7 and 8. We can create infinitely many levels, if needed.

    $ ./kugrit
    c.day: 2024-12-17
    day_plan:
    - id: 0
      name: Take out the trash
      completed_at: null
    - id: 1
      name: Do the laundry
      completed_at: null
    - id: 2
      name: Call Dad
      completed_at: null
    - id: 3
      name: Get groceries
      completed_at: null
    - id: 4
      name: Bread
      completed_at: null
    - id: 5
      name: Milk
      completed_at: null
    - id: 6
      name: Eggs
      completed_at: null
    

Check the entire branch:

    $ ./kugrit check 3
    
    $ ./kugrit tree 3
    - p.id: '3'
      t.id: '4'
      t.completed_at: 2024-12-17 20:38:07.007
    - p.id: '3'
      t.id: '5'
      t.completed_at: 2024-12-17 20:38:07.007
    - p.id: '3'
      t.id: '6'
      t.completed_at: 2024-12-17 20:38:07.007
    

The `tree` command prints out a tree rooted at the given node. When running `grit` without arguments, `tree` is invoked implicitly, defaulting to the current date node.

### Check the database

Now we have enough info, to see how the database looks

since I cannot execute nushell in prysk all just hard code it here

``` nushell
open ~/.config/grit/graph.db                                            1 14/12/24 18:23:37
╭───────┬───────────────────────────────────────────────────────────────────────────────────╮
│       │ ╭───┬─────────┬────────────────────┬────────────┬──────────────┬────────────────╮ │
│ nodes │ │ # │ node_id │     node_name      │ node_alias │ node_created │ node_completed │ │
│       │ ├───┼─────────┼────────────────────┼────────────┼──────────────┼────────────────┤ │
│       │ │ 0 │       1 │ 2024-12-15         │            │   1734221073 │                │ │
│       │ │ 1 │       2 │ Take out the trash │            │   1734221073 │     1734221073 │ │
│       │ │ 2 │       3 │ Do the laundry     │            │   1734221073 │                │ │
│       │ │ 3 │       4 │ Call Dad           │            │   1734221073 │                │ │
│       │ │ 4 │       5 │ Get groceries      │            │   1734221073 │     1734221073 │ │
│       │ │ 5 │       6 │ Bread              │            │   1734221073 │     1734221073 │ │
│       │ │ 6 │       7 │ Milk               │            │   1734221073 │     1734221073 │ │
│       │ │ 7 │       8 │ Eggs               │            │   1734221073 │     1734221073 │ │
│       │ ╰───┴─────────┴────────────────────┴────────────┴──────────────┴────────────────╯ │
│       │ ╭───┬─────────┬───────────┬─────────╮                                             │
│ links │ │ # │ link_id │ origin_id │ dest_id │                                             │
│       │ ├───┼─────────┼───────────┼─────────┤                                             │
│       │ │ 0 │       1 │         1 │       2 │                                             │
│       │ │ 1 │       2 │         1 │       3 │                                             │
│       │ │ 2 │       3 │         1 │       4 │                                             │
│       │ │ 3 │       4 │         1 │       5 │                                             │
│       │ │ 4 │       5 │         5 │       6 │                                             │
│       │ │ 5 │       6 │         5 │       7 │                                             │
│       │ │ 6 │       7 │         5 │       8 │                                             │
│       │ ╰───┴─────────┴───────────┴─────────╯                                             │
╰───────┴───────────────────────────────────────────────────────────────────────────────────╯

```

### Roots ###

Some tasks are big—they can't realistically be completed in one day, so we can't associate them with a single date node. The trick is to add it as a root task and break it up into smaller subtasks. Then we can associate the subtasks with specific dates.

To create a root, run `add` with the `-r` flag:

    $ ./kugrit add_project Work through Higher Algebra - Henry S. Hall
    t.id: '7'
    

It's useful to assign aliases to frequently used nodes. An alias is an alternative identifier that can be used in place of a numeric one.

    $ ./kugrit alias 7 textbook
    p.id: '7'
    p.name: Work through Higher Algebra - Henry S. Hall
    p.alias: textbook
    p.created_at: 2024-12-17 20:38:08.911
    p.completed_at: ''
    

The book contains 35 chapters—adding each of them individually would be very laborious. We can use a Bash loop to make the job easier (a feature like this will probably be added in a future release):

    $ for i in {1..35}; do ./kugrit add_to_alias textbook Chapter $i; done
    {"c.day":"2024-12-17","t.id":"8"}
    {"c.day":"2024-12-17","t.id":"9"}
    {"c.day":"2024-12-17","t.id":"10"}
    {"c.day":"2024-12-17","t.id":"11"}
    {"c.day":"2024-12-17","t.id":"12"}
    {"c.day":"2024-12-17","t.id":"13"}
    {"c.day":"2024-12-17","t.id":"14"}
    {"c.day":"2024-12-17","t.id":"15"}
    {"c.day":"2024-12-17","t.id":"16"}
    {"c.day":"2024-12-17","t.id":"17"}
    {"c.day":"2024-12-17","t.id":"18"}
    {"c.day":"2024-12-17","t.id":"19"}
    {"c.day":"2024-12-17","t.id":"20"}
    {"c.day":"2024-12-17","t.id":"21"}
    {"c.day":"2024-12-17","t.id":"22"}
    {"c.day":"2024-12-17","t.id":"23"}
    {"c.day":"2024-12-17","t.id":"24"}
    {"c.day":"2024-12-17","t.id":"25"}
    {"c.day":"2024-12-17","t.id":"26"}
    {"c.day":"2024-12-17","t.id":"27"}
    {"c.day":"2024-12-17","t.id":"28"}
    {"c.day":"2024-12-17","t.id":"29"}
    {"c.day":"2024-12-17","t.id":"30"}
    {"c.day":"2024-12-17","t.id":"31"}
    {"c.day":"2024-12-17","t.id":"32"}
    {"c.day":"2024-12-17","t.id":"33"}
    {"c.day":"2024-12-17","t.id":"34"}
    {"c.day":"2024-12-17","t.id":"35"}
    {"c.day":"2024-12-17","t.id":"36"}
    {"c.day":"2024-12-17","t.id":"37"}
    {"c.day":"2024-12-17","t.id":"38"}
    {"c.day":"2024-12-17","t.id":"39"}
    {"c.day":"2024-12-17","t.id":"40"}
    {"c.day":"2024-12-17","t.id":"41"}
    {"c.day":"2024-12-17","t.id":"42"}

Working through a chapter involves reading it and solving all the exercise problems included at the end. Chapter 1 has 28 exercises.

    $ ./kugrit add_to 10 Read the chaptery
    c.day: 2024-12-17
    t.id: '43'
    

    $ ./kugrit add_to 10 Solve the exercises
    c.day: 2024-12-17
    t.id: '44'
    

    $ for i in {1..28}; do ./kugrit add_to 46 Solve ex. $i; done
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]

Our tree so far:

    $ ./kugrit tree textbook
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:11] (esc)
     \x1b[2m1\x1b[0m │ main tree textbook (esc)
       · \x1b[35;1m          ────┬───\x1b[0m (esc)
       ·               \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]



We can do this for each chapter, or leave it for later, building our tree as we go along. In any case, we are ready to use this tree to schedule our day.

Before we proceed, let's run `stat` to see some more information about the node:

    $ ./kugrit stat textbook
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:11] (esc)
     \x1b[2m1\x1b[0m │ main stat textbook (esc)
       · \x1b[35;1m          ────┬───\x1b[0m (esc)
       ·               \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]


We can confirm that the node is a root—it has no parents. There's a little map showing the node's parents and children. Progress is also displayed, calculated by counting all the leaves reachable from the node.

### Links ###

Say we want to read the first chapter of our Algebra book, and solve a few exercises today. Let's add a new task to the current date node:

    $ ./kugrit add Work on ch. 1 of the Algebra textbook
    c.day: 2024-12-17
    t.id: '45'
    

Create cross links from this node to the relevant `textbook` nodes (the first argument to `link` is the origin, the ones following it are targets):

    $ ./kugrit link 75 45 47 48 49
    Error: \x1b[31mnu::parser::extra_positional\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Extra positional argument. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:6] (esc)
     \x1b[2m1\x1b[0m │ main link 75 45 47 48 49 (esc)
       · \x1b[35;1m     ──┬─\x1b[0m (esc)
       ·        \x1b[35;1m╰── \x1b[35;1mextra positional argument\x1b[0m\x1b[0m (esc)
       ╰────
    \x1b[36m  help: \x1b[0mUsage: main (esc)
    
    [1]































    $ ./kugrit
    c.day: 2024-12-17
    day_plan:
    - id: 0
      name: Take out the trash
      completed_at: null
    - id: 1
      name: Do the laundry
      completed_at: null
    - id: 2
      name: Call Dad
      completed_at: null
    - id: 3
      name: Get groceries
      completed_at: 2024-12-17 20:38:07.007
    - id: 4
      name: Bread
      completed_at: 2024-12-17 20:38:07.007
    - id: 5
      name: Milk
      completed_at: 2024-12-17 20:38:07.007
    - id: 6
      name: Eggs
      completed_at: 2024-12-17 20:38:07.007
    - id: 8
      name: Chapter 1
      completed_at: null
    - id: 9
      name: Chapter 2
      completed_at: null
    - id: 10
      name: Chapter 3
      completed_at: null
    - id: 11
      name: Chapter 4
      completed_at: null
    - id: 12
      name: Chapter 5
      completed_at: null
    - id: 13
      name: Chapter 6
      completed_at: null
    - id: 14
      name: Chapter 7
      completed_at: null
    - id: 15
      name: Chapter 8
      completed_at: null
    - id: 16
      name: Chapter 9
      completed_at: null
    - id: 17
      name: Chapter 10
      completed_at: null
    - id: 18
      name: Chapter 11
      completed_at: null
    - id: 19
      name: Chapter 12
      completed_at: null
    - id: 20
      name: Chapter 13
      completed_at: null
    - id: 21
      name: Chapter 14
      completed_at: null
    - id: 22
      name: Chapter 15
      completed_at: null
    - id: 23
      name: Chapter 16
      completed_at: null
    - id: 24
      name: Chapter 17
      completed_at: null
    - id: 25
      name: Chapter 18
      completed_at: null
    - id: 26
      name: Chapter 19
      completed_at: null
    - id: 27
      name: Chapter 20
      completed_at: null
    - id: 28
      name: Chapter 21
      completed_at: null
    - id: 29
      name: Chapter 22
      completed_at: null
    - id: 30
      name: Chapter 23
      completed_at: null
    - id: 31
      name: Chapter 24
      completed_at: null
    - id: 32
      name: Chapter 25
      completed_at: null
    - id: 33
      name: Chapter 26
      completed_at: null
    - id: 34
      name: Chapter 27
      completed_at: null
    - id: 35
      name: Chapter 28
      completed_at: null
    - id: 36
      name: Chapter 29
      completed_at: null
    - id: 37
      name: Chapter 30
      completed_at: null
    - id: 38
      name: Chapter 31
      completed_at: null
    - id: 39
      name: Chapter 32
      completed_at: null
    - id: 40
      name: Chapter 33
      completed_at: null
    - id: 41
      name: Chapter 34
      completed_at: null
    - id: 42
      name: Chapter 35
      completed_at: null
    - id: 43
      name: Read the chaptery
      completed_at: null
    - id: 44
      name: Solve the exercises
      completed_at: null
    - id: 45
      name: Work on ch. 1 of the Algebra textbook
      completed_at: null
    












The dotted lines indicate that the node has multiple parents. We can confirm this by taking a closer look at one of them using `stat`:

    $ ./kugrit stat 45
    []
    




































If we wanted to draw an accurate representation of the entire multitree at this point, it might look something like this:

<p align="center">
  <img src="docs/assets/fig2.png" width="750" />
</p>

This looks somewhat readable, but attempts to draw a complete representation of a structure even slightly more complex than this typically result in a tangled mess. Because of this, kugrit only gives us glimpses of the digraph, one `tree` (or `ls`) at a time. Beyond that it relies on the user to fill in the gaps.

We can check the nodes and see how the changes propagate through the graph:

    $ ./kugrit check 75
    







    $ ./kugrit
    c.day: 2024-12-17
    day_plan:
    - id: 0
      name: Take out the trash
      completed_at: null
    - id: 1
      name: Do the laundry
      completed_at: null
    - id: 2
      name: Call Dad
      completed_at: null
    - id: 3
      name: Get groceries
      completed_at: 2024-12-17 20:38:07.007
    - id: 4
      name: Bread
      completed_at: 2024-12-17 20:38:07.007
    - id: 5
      name: Milk
      completed_at: 2024-12-17 20:38:07.007
    - id: 6
      name: Eggs
      completed_at: 2024-12-17 20:38:07.007
    - id: 8
      name: Chapter 1
      completed_at: null
    - id: 9
      name: Chapter 2
      completed_at: null
    - id: 10
      name: Chapter 3
      completed_at: null
    - id: 11
      name: Chapter 4
      completed_at: null
    - id: 12
      name: Chapter 5
      completed_at: null
    - id: 13
      name: Chapter 6
      completed_at: null
    - id: 14
      name: Chapter 7
      completed_at: null
    - id: 15
      name: Chapter 8
      completed_at: null
    - id: 16
      name: Chapter 9
      completed_at: null
    - id: 17
      name: Chapter 10
      completed_at: null
    - id: 18
      name: Chapter 11
      completed_at: null
    - id: 19
      name: Chapter 12
      completed_at: null
    - id: 20
      name: Chapter 13
      completed_at: null
    - id: 21
      name: Chapter 14
      completed_at: null
    - id: 22
      name: Chapter 15
      completed_at: null
    - id: 23
      name: Chapter 16
      completed_at: null
    - id: 24
      name: Chapter 17
      completed_at: null
    - id: 25
      name: Chapter 18
      completed_at: null
    - id: 26
      name: Chapter 19
      completed_at: null
    - id: 27
      name: Chapter 20
      completed_at: null
    - id: 28
      name: Chapter 21
      completed_at: null
    - id: 29
      name: Chapter 22
      completed_at: null
    - id: 30
      name: Chapter 23
      completed_at: null
    - id: 31
      name: Chapter 24
      completed_at: null
    - id: 32
      name: Chapter 25
      completed_at: null
    - id: 33
      name: Chapter 26
      completed_at: null
    - id: 34
      name: Chapter 27
      completed_at: null
    - id: 35
      name: Chapter 28
      completed_at: null
    - id: 36
      name: Chapter 29
      completed_at: null
    - id: 37
      name: Chapter 30
      completed_at: null
    - id: 38
      name: Chapter 31
      completed_at: null
    - id: 39
      name: Chapter 32
      completed_at: null
    - id: 40
      name: Chapter 33
      completed_at: null
    - id: 41
      name: Chapter 34
      completed_at: null
    - id: 42
      name: Chapter 35
      completed_at: null
    - id: 43
      name: Read the chaptery
      completed_at: null
    - id: 44
      name: Solve the exercises
      completed_at: null
    - id: 45
      name: Work on ch. 1 of the Algebra textbook
      completed_at: null
    












The nodes are the same, so the change is visible in the textbook tree as well as the date tree:

    $ ./kugrit tree textbook
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:11] (esc)
     \x1b[2m1\x1b[0m │ main tree textbook (esc)
       · \x1b[35;1m          ────┬───\x1b[0m (esc)
       ·               \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]































We've completed all the tasks for the day, but there's still work to be done under `textbook`. We can schedule more work for tomorrow:

    $ TOMORROW=$(date -d "tomorrow" +"%Y-%m-%d")
    $ ./kugrit add_to $TOMORROW Work on the algebra textbook
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to 2024-12-18 Work on the algebra textbook (esc)
       · \x1b[35;1m            ─────┬────\x1b[0m (esc)
       ·                  \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]






























    $ ./kugrit add_to 77 Solve exercises from ch. 1
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]






















    $ ./kugrit link 78 50 51 52 53 54
    Error: \x1b[31mnu::parser::extra_positional\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Extra positional argument. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:6] (esc)
     \x1b[2m1\x1b[0m │ main link 78 50 51 52 53 54 (esc)
       · \x1b[35;1m     ──┬─\x1b[0m (esc)
       ·        \x1b[35;1m╰── \x1b[35;1mextra positional argument\x1b[0m\x1b[0m (esc)
       ╰────
    \x1b[36m  help: \x1b[0mUsage: main (esc)
    
    [1]






























    $ ./kugrit add_to 77 Work on ch. 2
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]






















    $ ./kugrit link 79 45 47 48 49
    Error: \x1b[31mnu::parser::extra_positional\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Extra positional argument. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:6] (esc)
     \x1b[2m1\x1b[0m │ main link 79 45 47 48 49 (esc)
       · \x1b[35;1m     ──┬─\x1b[0m (esc)
       ·        \x1b[35;1m╰── \x1b[35;1mextra positional argument\x1b[0m\x1b[0m (esc)
       ╰────
    \x1b[36m  help: \x1b[0mUsage: main (esc)
    
    [1]






























    $ ./kugrit tree $TOMORROW
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:11] (esc)
     \x1b[2m1\x1b[0m │ main tree 2024-12-18 (esc)
       · \x1b[35;1m          ─────┬────\x1b[0m (esc)
       ·                \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]
































### Pointers ###

We can define a *pointer* as a non-task node whose purpose is to link to other nodes. Pointers can be used to classify tasks, or as placeholders for tasks expected to be added in the future.

#### Organizing tasks ####

One aspect where kugrit differs from other productivity tools is the lack of tags. This is by choice—Grit is an experiment, and the idea is to solve problems by utilizing the multitree as much as possible.

How do we organize tasks without tags, then? As we add more and more nodes at the root level, things start to get messy. Running `grit ls` may result in a long list of assorted nodes. The kugrit way to solve this is to make pointers.

For example, if our algebra textbook was just one of many textbooks, we could create a node named "Textbooks" and point it at them:

    $ ./kugrit add Calculus - Michael Spivak
    c.day: 2024-12-17
    t.id: '46'
    











    $ ./kugrit add Higher Algebra - Henry S. Hall
    c.day: 2024-12-17
    t.id: '47'
    











    $ ./kugrit add Linear Algebra - Jim Hefferon
    c.day: 2024-12-17
    t.id: '48'
    











    $ ./kugrit add -r Textbooks
    Error: \x1b[31mnu::parser::unknown_flag\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m The `main add` command doesn't have flag `-r`. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:11] (esc)
     \x1b[2m1\x1b[0m │ main add -r Textbooks (esc)
       · \x1b[35;1m          ┬\x1b[0m (esc)
       ·           \x1b[35;1m╰── \x1b[35;1munknown flag\x1b[0m\x1b[0m (esc)
       ╰────
    \x1b[36m  help: \x1b[0mAvailable flags: --help(-h). Use `--help` for more information. (esc)
    
    [1]






























    $ ./kugrit alias 83 textbooks
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]






























    $ ./kugrit link textbooks 80 81 82
    Error: \x1b[31mnu::parser::extra_positional\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Extra positional argument. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:6] (esc)
     \x1b[2m1\x1b[0m │ main link textbooks 80 81 82 (esc)
       · \x1b[35;1m     ──┬─\x1b[0m (esc)
       ·        \x1b[35;1m╰── \x1b[35;1mextra positional argument\x1b[0m\x1b[0m (esc)
       ╰────
    \x1b[36m  help: \x1b[0mUsage: main (esc)
    
    [1]




























    $ ./kugrit ls textbooks
    Error: \x1b[31mnu::parser::extra_positional\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Extra positional argument. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:6] (esc)
     \x1b[2m1\x1b[0m │ main ls textbooks (esc)
       · \x1b[35;1m     ─┬\x1b[0m (esc)
       ·       \x1b[35;1m╰── \x1b[35;1mextra positional argument\x1b[0m\x1b[0m (esc)
       ╰────
    \x1b[36m  help: \x1b[0mUsage: main (esc)
    
    [1]
































This gives them a parent, so they no longer appear at the root level.

Note that the same node can be pointed to by an infinite number of nodes, allowing us to create overlapping categories, e.g. the same node may be reachable from "Books to read" and "Preparation for the upcoming talk", etc.


#### Reading challenge ####

A challenge can be a good motivational tool:

    $ ./kugrit add -r Read 24 books in the year
    Error: \x1b[31mnu::parser::unknown_flag\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m The `main add` command doesn't have flag `-r`. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:11] (esc)
     \x1b[2m1\x1b[0m │ main add -r Read 24 books in the year (esc)
       · \x1b[35;1m          ┬\x1b[0m (esc)
       ·           \x1b[35;1m╰── \x1b[35;1munknown flag\x1b[0m\x1b[0m (esc)
       ╰────
    \x1b[36m  help: \x1b[0mAvailable flags: --help(-h). Use `--help` for more information. (esc)
    
    [1]






























    $ ./kugrit alias 84 reading_challenge
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
         ╭─[\x1b[36;1;4m/home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/kugrit\x1b[0m:129:102] (esc)
     \x1b[2m128\x1b[0m │ def db_query [qry:string ]: nothing -> any { (esc)
     \x1b[2m129\x1b[0m │     $qry | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7 (esc)
         · \x1b[35;1m                                                                                                     ──┬─\x1b[0m (esc)
         ·                                                                                                        \x1b[35;1m╰── \x1b[35;1merror parsing JSON text\x1b[0m\x1b[0m (esc)
     \x1b[2m130\x1b[0m │ } (esc)
         ╰────
    
    Error:   \x1b[31m×\x1b[0m Error while parsing JSON text (esc)
       ╭────
     \x1b[2m1\x1b[0m │  (esc)
       · \x1b[35;1m▲\x1b[0m (esc)
       · \x1b[35;1m╰── \x1b[35;1m"EOF while parsing a value" at line 2 column 0\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]































We could simply add books to it as we go, but this wouldn't give us a nice way to track our progress. Let's go a step further and create a pointer (or "slot") for each of the 24 books.

    $ for i in {1..24}; do ./kugrit add_to reading_challenge "Book $i"; done
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 1" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 2" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 3" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 4" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 5" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 6" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 7" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 8" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 9" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 10" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 11" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 12" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 13" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 14" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 15" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 16" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 17" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 18" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 19" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 20" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 21" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 22" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 23" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:13] (esc)
     \x1b[2m1\x1b[0m │ main add_to reading_challenge "Book 24" (esc)
       · \x1b[35;1m            ────────┬────────\x1b[0m (esc)
       ·                     \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]
















































































































































































































































































































































































































































































































































    $ ./kugrit tree reading_challenge
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:11] (esc)
     \x1b[2m1\x1b[0m │ main tree reading_challenge (esc)
       · \x1b[35;1m          ────────┬────────\x1b[0m (esc)
       ·                   \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]































Now, whenever we decide what book we want to read next, we can simply create a new task and link the pointer to it:

    $ ./kugrit add 1984 - George Orwell
    c.day: 2024-12-17
    t.id: '49'
    











    $ ./kugrit link 85 109
    Error: \x1b[31mnu::parser::extra_positional\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Extra positional argument. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:6] (esc)
     \x1b[2m1\x1b[0m │ main link 85 109 (esc)
       · \x1b[35;1m     ──┬─\x1b[0m (esc)
       ·        \x1b[35;1m╰── \x1b[35;1mextra positional argument\x1b[0m\x1b[0m (esc)
       ╰────
    \x1b[36m  help: \x1b[0mUsage: main (esc)
    
    [1]




























    $ ./kugrit check 109
    







    $ ./kugrit tree reading_challenge
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:11] (esc)
     \x1b[2m1\x1b[0m │ main tree reading_challenge (esc)
       · \x1b[35;1m          ────────┬────────\x1b[0m (esc)
       ·                   \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]































The number of leaves remains the same, so `stat` will correctly display our progress:

    $ ./kugrit stat reading_challenge
    Error: \x1b[31mnu::parser::parse_mismatch\x1b[0m (esc)
    
      \x1b[31m×\x1b[0m Parse mismatch during operation. (esc)
       ╭─[\x1b[36;1;4m<commandline>\x1b[0m:1:11] (esc)
     \x1b[2m1\x1b[0m │ main stat reading_challenge (esc)
       · \x1b[35;1m          ────────┬────────\x1b[0m (esc)
       ·                   \x1b[35;1m╰── \x1b[35;1mexpected int\x1b[0m\x1b[0m (esc)
       ╰────
    
    [1]
