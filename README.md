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
~/r/gh/elv79/deleteme_beeminder_10klocs/nugrit> prysk --shell /bin/bash --indent=4 ./README.md
```

# Setup
Lets create a new database (TODO: I wish the original grit had a configurable database file)

    $ rm --force ~/.config/grit/graph.db

## Practical guide ##

### Basic usage ###

Let's add a few things we want to do today:

    $ grit add Take out the trash
    (1) -> (2)
    $ grit add Do the laundry
    (1) -> (3)
    $ grit add Call Dad
    (1) -> (4)

Run `grit` without arguments to display the current date tree:

    $ grit
    [ ] ????-??-?? (1) (glob)
     ├──[ ] Call Dad (4)
     ├──[ ] Do the laundry (3)
     └──[ ] Take out the trash (2)


So far it looks like an old-fashioned to-do list. We can `check` a task to mark it as completed:

    $ grit check 2
    $ grit
    [~] ????-??-?? (1) (glob)
     ├──[ ] Call Dad (4)
     ├──[ ] Do the laundry (3)
     └──[*] Take out the trash (2)

The change is automatically propagated through the graph. We can see that the status of the parent task (the date node) has changed to _in progress_.

### Subtasks ###

Let's add another task:

    $ grit add Get groceries
    (1) -> (5)

To divide it into subtasks, we have to specify the parent (when no parent is given, `add` defaults to the current date node):

    $ grit add -p 5 Bread
    (5) -> (6)
    $ grit add -p 5 Milk
    (5) -> (7)
    $ grit add -p 5 Eggs
    (5) -> (8)

Task 5 is now pointing to subtasks 6, 7 and 8. We can create infinitely many levels, if needed.

    $ grit
    [~] ????-??-?? (1) (glob)
     ├──[ ] Call Dad (4)
     ├──[ ] Do the laundry (3)
     ├──[ ] Get groceries (5)
     │   ├──[ ] Bread (6)
     │   ├──[ ] Eggs (8)
     │   └──[ ] Milk (7)
     └──[*] Take out the trash (2)


Check the entire branch:

    $ grit check 5
    $ grit tree 5
    [x] Get groceries (5)
     ├──[x] Bread (6)
     ├──[x] Eggs (8)
     └──[x] Milk (7)

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

    $ grit add -r Work through Higher Algebra - Henry S. Hall
    (9)

It's useful to assign aliases to frequently used nodes. An alias is an alternative identifier that can be used in place of a numeric one.

    $ grit alias 9 textbook

The book contains 35 chapters—adding each of them individually would be very laborious. We can use a Bash loop to make the job easier (a feature like this will probably be added in a future release):


    $ for i in {1..35}; do grit add -p textbook "Chapter $i"; done
    (9) -> (10)
    (9) -> (11)
    (9) -> (12)
    (9) -> (13)
    (9) -> (14)
    (9) -> (15)
    (9) -> (16)
    (9) -> (17)
    (9) -> (18)
    (9) -> (19)
    (9) -> (20)
    (9) -> (21)
    (9) -> (22)
    (9) -> (23)
    (9) -> (24)
    (9) -> (25)
    (9) -> (26)
    (9) -> (27)
    (9) -> (28)
    (9) -> (29)
    (9) -> (30)
    (9) -> (31)
    (9) -> (32)
    (9) -> (33)
    (9) -> (34)
    (9) -> (35)
    (9) -> (36)
    (9) -> (37)
    (9) -> (38)
    (9) -> (39)
    (9) -> (40)
    (9) -> (41)
    (9) -> (42)
    (9) -> (43)
    (9) -> (44)

Working through a chapter involves reading it and solving all the exercise problems included at the end. Chapter 1 has 28 exercises.

    $ grit add -p 10 Read the chapter
    (10) -> (45)
    $ grit add -p 10 Solve the exercises
    (10) -> (46)
    $ for i in {1..28}; do grit add -p 46 "Solve ex. $i"; done
    (46) -> (47)
    (46) -> (48)
    (46) -> (49)
    (46) -> (50)
    (46) -> (51)
    (46) -> (52)
    (46) -> (53)
    (46) -> (54)
    (46) -> (55)
    (46) -> (56)
    (46) -> (57)
    (46) -> (58)
    (46) -> (59)
    (46) -> (60)
    (46) -> (61)
    (46) -> (62)
    (46) -> (63)
    (46) -> (64)
    (46) -> (65)
    (46) -> (66)
    (46) -> (67)
    (46) -> (68)
    (46) -> (69)
    (46) -> (70)
    (46) -> (71)
    (46) -> (72)
    (46) -> (73)
    (46) -> (74)

Our tree so far:

    $ grit tree textbook
    [ ] Work through Higher Algebra - Henry S. Hall (9:textbook)
     ├──[ ] Chapter 1 (10)
     │   ├──[ ] Read the chapter (45)
     │   └──[ ] Solve the exercises (46)
     │       ├──[ ] Solve ex. 1 (47)
     │       ├──[ ] Solve ex. 2 (48)
     │       ├──[ ] Solve ex. 3 (49)
     │       ├──[ ] Solve ex. 4 (50)
     │       ├──[ ] Solve ex. 5 (51)
     │       ├──[ ] Solve ex. 6 (52)
     │       ├──[ ] Solve ex. 7 (53)
     │       ├──[ ] Solve ex. 8 (54)
     │       ├──[ ] Solve ex. 9 (55)
     │       ├──[ ] Solve ex. 10 (56)
     │       ├──[ ] Solve ex. 11 (57)
     │       ├──[ ] Solve ex. 12 (58)
     │       ├──[ ] Solve ex. 13 (59)
     │       ├──[ ] Solve ex. 14 (60)
     │       ├──[ ] Solve ex. 15 (61)
     │       ├──[ ] Solve ex. 16 (62)
     │       ├──[ ] Solve ex. 17 (63)
     │       ├──[ ] Solve ex. 18 (64)
     │       ├──[ ] Solve ex. 19 (65)
     │       ├──[ ] Solve ex. 20 (66)
     │       ├──[ ] Solve ex. 21 (67)
     │       ├──[ ] Solve ex. 22 (68)
     │       ├──[ ] Solve ex. 23 (69)
     │       ├──[ ] Solve ex. 24 (70)
     │       ├──[ ] Solve ex. 25 (71)
     │       ├──[ ] Solve ex. 26 (72)
     │       ├──[ ] Solve ex. 27 (73)
     │       └──[ ] Solve ex. 28 (74)
     ├──[ ] Chapter 2 (11)
     ├──[ ] Chapter 3 (12)
     ├──[ ] Chapter 4 (13)
     ├──[ ] Chapter 5 (14)
     ├──[ ] Chapter 6 (15)
     ├──[ ] Chapter 7 (16)
     ├──[ ] Chapter 8 (17)
     ├──[ ] Chapter 9 (18)
     ├──[ ] Chapter 10 (19)
     ├──[ ] Chapter 11 (20)
     ├──[ ] Chapter 12 (21)
     ├──[ ] Chapter 13 (22)
     ├──[ ] Chapter 14 (23)
     ├──[ ] Chapter 15 (24)
     ├──[ ] Chapter 16 (25)
     ├──[ ] Chapter 17 (26)
     ├──[ ] Chapter 18 (27)
     ├──[ ] Chapter 19 (28)
     ├──[ ] Chapter 20 (29)
     ├──[ ] Chapter 21 (30)
     ├──[ ] Chapter 22 (31)
     ├──[ ] Chapter 23 (32)
     ├──[ ] Chapter 24 (33)
     ├──[ ] Chapter 25 (34)
     ├──[ ] Chapter 26 (35)
     ├──[ ] Chapter 27 (36)
     ├──[ ] Chapter 28 (37)
     ├──[ ] Chapter 29 (38)
     ├──[ ] Chapter 30 (39)
     ├──[ ] Chapter 31 (40)
     ├──[ ] Chapter 32 (41)
     ├──[ ] Chapter 33 (42)
     ├──[ ] Chapter 34 (43)
     └──[ ] Chapter 35 (44)


We can do this for each chapter, or leave it for later, building our tree as we go along. In any case, we are ready to use this tree to schedule our day.

Before we proceed, let's run `stat` to see some more information about the node:

    $ grit stat textbook
    (9) ───┬─── (10)
           ├─── (11)
           ├─── (12)
           ├─── (13)
           ├─── (14)
           ├─── (15)
           ├─── (16)
           ├─── (17)
           ├─── (18)
           ├─── (19)
           ├─── (20)
           ├─── (21)
           ├─── (22)
           ├─── (23)
           ├─── (24)
           ├─── (25)
           ├─── (26)
           ├─── (27)
           ├─── (28)
           ├─── (29)
           ├─── (30)
           ├─── (31)
           ├─── (32)
           ├─── (33)
           ├─── (34)
           ├─── (35)
           ├─── (36)
           ├─── (37)
           ├─── (38)
           ├─── (39)
           ├─── (40)
           ├─── (41)
           ├─── (42)
           ├─── (43)
           └─── (44)

    ID: 9
    Name: Work through Higher Algebra - Henry S. Hall
    Status: inactive (0/63)
    Parents: 0
    Children: 35
    Alias: textbook
    Created: ????-??-?? ??:??:?? (glob)




We can confirm that the node is a root—it has no parents. There's a little map showing the node's parents and children. Progress is also displayed, calculated by counting all the leaves reachable from the node.

### Links ###

Say we want to read the first chapter of our Algebra book, and solve a few exercises today. Let's add a new task to the current date node:

    $ grit add Work on ch. 1 of the Algebra textbook
    (1) -> (75)

Create cross links from this node to the relevant `textbook` nodes (the first argument to `link` is the origin, the ones following it are targets):

    $ grit link 75 45 47 48 49
    $ grit
    [~] ????-??-?? (1) (glob)
     ├──[ ] Call Dad (4)
     ├──[ ] Do the laundry (3)
     ├──[*] Get groceries (5)
     │   ├──[*] Bread (6)
     │   ├──[*] Eggs (8)
     │   └──[*] Milk (7)
     ├──[*] Take out the trash (2)
     └──[ ] Work on ch. 1 of the Algebra textbook (75)
         ├··[ ] Read the chapter (45)
         ├··[ ] Solve ex. 1 (47)
         ├··[ ] Solve ex. 2 (48)
         └··[ ] Solve ex. 3 (49)

The dotted lines indicate that the node has multiple parents. We can confirm this by taking a closer look at one of them using `stat`:

    $ grit stat 45
    (10) ───┐
    (75) ───┴─── (45)

    ID: 45
    Name: Read the chapter
    Status: inactive (0/1)
    Parents: 2
    Children: 0
    Created: ????-??-?? ??:??:?? (glob)





If we wanted to draw an accurate representation of the entire multitree at this point, it might look something like this:

<p align="center">
  <img src="docs/assets/fig2.png" width="750" />
</p>

This looks somewhat readable, but attempts to draw a complete representation of a structure even slightly more complex than this typically result in a tangled mess. Because of this, Grit only gives us glimpses of the digraph, one `tree` (or `ls`) at a time. Beyond that it relies on the user to fill in the gaps.

We can check the nodes and see how the changes propagate through the graph:

    $ grit check 75
    $ grit
    [~] ????-??-?? (1) (glob)
     ├──[ ] Call Dad (4)
     ├──[ ] Do the laundry (3)
     ├──[*] Get groceries (5)
     │   ├──[*] Bread (6)
     │   ├──[*] Eggs (8)
     │   └──[*] Milk (7)
     ├──[*] Take out the trash (2)
     └──[*] Work on ch. 1 of the Algebra textbook (75)
         ├··[*] Read the chapter (45)
         ├··[*] Solve ex. 1 (47)
         ├··[*] Solve ex. 2 (48)
         └··[*] Solve ex. 3 (49)

The nodes are the same, so the change is visible in the textbook tree as well as the date tree:

    $ grit tree textbook
    [~] Work through Higher Algebra - Henry S. Hall (9:textbook)
     ├──[~] Chapter 1 (10)
     │   ├··[x] Read the chapter (45)
     │   └──[~] Solve the exercises (46)
     │       ├··[x] Solve ex. 1 (47)
     │       ├··[x] Solve ex. 2 (48)
     │       ├··[x] Solve ex. 3 (49)
     │       ├──[ ] Solve ex. 4 (50)
     │       ├──[ ] Solve ex. 5 (51)
     │       ├──[ ] Solve ex. 6 (52)
     │       ├──[ ] Solve ex. 7 (53)
     │       ├──[ ] Solve ex. 8 (54)
     │       ├──[ ] Solve ex. 9 (55)
     │       ├──[ ] Solve ex. 10 (56)
     │       ├──[ ] Solve ex. 11 (57)
     │       ├──[ ] Solve ex. 12 (58)
     │       ├──[ ] Solve ex. 13 (59)
     │       ├──[ ] Solve ex. 14 (60)
     │       ├──[ ] Solve ex. 15 (61)
     │       ├──[ ] Solve ex. 16 (62)
     │       ├──[ ] Solve ex. 17 (63)
     │       ├──[ ] Solve ex. 18 (64)
     │       ├──[ ] Solve ex. 19 (65)
     │       ├──[ ] Solve ex. 20 (66)
     │       ├──[ ] Solve ex. 21 (67)
     │       ├──[ ] Solve ex. 22 (68)
     │       ├──[ ] Solve ex. 23 (69)
     │       ├──[ ] Solve ex. 24 (70)
     │       ├──[ ] Solve ex. 25 (71)
     │       ├──[ ] Solve ex. 26 (72)
     │       ├──[ ] Solve ex. 27 (73)
     │       └──[ ] Solve ex. 28 (74)
     ├──[ ] Chapter 2 (11)
     ├──[ ] Chapter 3 (12)
     ├──[ ] Chapter 4 (13)
     ├──[ ] Chapter 5 (14)
     ├──[ ] Chapter 6 (15)
     ├──[ ] Chapter 7 (16)
     ├──[ ] Chapter 8 (17)
     ├──[ ] Chapter 9 (18)
     ├──[ ] Chapter 10 (19)
     ├──[ ] Chapter 11 (20)
     ├──[ ] Chapter 12 (21)
     ├──[ ] Chapter 13 (22)
     ├──[ ] Chapter 14 (23)
     ├──[ ] Chapter 15 (24)
     ├──[ ] Chapter 16 (25)
     ├──[ ] Chapter 17 (26)
     ├──[ ] Chapter 18 (27)
     ├──[ ] Chapter 19 (28)
     ├──[ ] Chapter 20 (29)
     ├──[ ] Chapter 21 (30)
     ├──[ ] Chapter 22 (31)
     ├──[ ] Chapter 23 (32)
     ├──[ ] Chapter 24 (33)
     ├──[ ] Chapter 25 (34)
     ├──[ ] Chapter 26 (35)
     ├──[ ] Chapter 27 (36)
     ├──[ ] Chapter 28 (37)
     ├──[ ] Chapter 29 (38)
     ├──[ ] Chapter 30 (39)
     ├──[ ] Chapter 31 (40)
     ├──[ ] Chapter 32 (41)
     ├──[ ] Chapter 33 (42)
     ├──[ ] Chapter 34 (43)
     └──[ ] Chapter 35 (44)

We've completed all the tasks for the day, but there's still work to be done under `textbook`. We can schedule more work for tomorrow:

    $ TOMORROW=$(date -d "tomorrow" +"%Y-%m-%d")
    $ grit add -p $TOMORROW Work on the algebra textbook
    (76) -> (77)
    $ grit add -p 77 Solve exercises from ch. 1
    (77) -> (78)
    $ grit link 78 50 51 52 53 54
    $ grit add -p 77 Work on ch. 2
    (77) -> (79)
    $ grit link 79 45 47 48 49
    $ grit tree $TOMORROW
    [~] ????-??-?? (76) (glob)
     └──[~] Work on the algebra textbook (77)
         ├──[ ] Solve exercises from ch. 1 (78)
         │   ├··[ ] Solve ex. 4 (50)
         │   ├··[ ] Solve ex. 5 (51)
         │   ├··[ ] Solve ex. 6 (52)
         │   ├··[ ] Solve ex. 7 (53)
         │   └··[ ] Solve ex. 8 (54)
         └──[*] Work on ch. 2 (79)
             ├··[*] Read the chapter (45)
             ├··[*] Solve ex. 1 (47)
             ├··[*] Solve ex. 2 (48)
             └··[*] Solve ex. 3 (49)


### Pointers ###

We can define a *pointer* as a non-task node whose purpose is to link to other nodes. Pointers can be used to classify tasks, or as placeholders for tasks expected to be added in the future.

#### Organizing tasks ####

One aspect where Grit differs from other productivity tools is the lack of tags. This is by choice—Grit is an experiment, and the idea is to solve problems by utilizing the multitree as much as possible.

How do we organize tasks without tags, then? As we add more and more nodes at the root level, things start to get messy. Running `grit ls` may result in a long list of assorted nodes. The Grit way to solve this is to make pointers.

For example, if our algebra textbook was just one of many textbooks, we could create a node named "Textbooks" and point it at them:

    $ grit add Calculus - Michael Spivak
    (1) -> (80)
    $ grit add Higher Algebra - Henry S. Hall
    (1) -> (81)
    $ grit add Linear Algebra - Jim Hefferon
    (1) -> (82)
    $ grit add -r Textbooks
    (83)
    $ grit alias 83 textbooks
    $ grit link textbooks 80 81 82
    $ grit ls textbooks
    [ ] Calculus - Michael Spivak (80)
    [ ] Higher Algebra - Henry S. Hall (81)
    [ ] Linear Algebra - Jim Hefferon (82)


This gives them a parent, so they no longer appear at the root level.

Note that the same node can be pointed to by an infinite number of nodes, allowing us to create overlapping categories, e.g. the same node may be reachable from "Books to read" and "Preparation for the upcoming talk", etc.


#### Reading challenge ####

A challenge can be a good motivational tool:

    $ grit add -r Read 24 books in the year
    (84)
    $ grit alias 84 reading_challenge

We could simply add books to it as we go, but this wouldn't give us a nice way to track our progress. Let's go a step further and create a pointer (or "slot") for each of the 24 books.

    $ for i in {1..24}; do grit add -p reading_challenge "Book $i"; done
    (84) -> (85)
    (84) -> (86)
    (84) -> (87)
    (84) -> (88)
    (84) -> (89)
    (84) -> (90)
    (84) -> (91)
    (84) -> (92)
    (84) -> (93)
    (84) -> (94)
    (84) -> (95)
    (84) -> (96)
    (84) -> (97)
    (84) -> (98)
    (84) -> (99)
    (84) -> (100)
    (84) -> (101)
    (84) -> (102)
    (84) -> (103)
    (84) -> (104)
    (84) -> (105)
    (84) -> (106)
    (84) -> (107)
    (84) -> (108)
    $ grit tree reading_challenge
    [ ] Read 24 books in the year (84:reading_challenge)
     ├──[ ] Book 1 (85)
     ├──[ ] Book 2 (86)
     ├──[ ] Book 3 (87)
     ├──[ ] Book 4 (88)
     ├──[ ] Book 5 (89)
     ├──[ ] Book 6 (90)
     ├──[ ] Book 7 (91)
     ├──[ ] Book 8 (92)
     ├──[ ] Book 9 (93)
     ├──[ ] Book 10 (94)
     ├──[ ] Book 11 (95)
     ├──[ ] Book 12 (96)
     ├──[ ] Book 13 (97)
     ├──[ ] Book 14 (98)
     ├──[ ] Book 15 (99)
     ├──[ ] Book 16 (100)
     ├──[ ] Book 17 (101)
     ├──[ ] Book 18 (102)
     ├──[ ] Book 19 (103)
     ├──[ ] Book 20 (104)
     ├──[ ] Book 21 (105)
     ├──[ ] Book 22 (106)
     ├──[ ] Book 23 (107)
     └──[ ] Book 24 (108)

Now, whenever we decide what book we want to read next, we can simply create a new task and link the pointer to it:

    $ grit add 1984 - George Orwell
    (1) -> (109)
    $ grit link 85 109
    $ grit check 109
    $ grit tree reading_challenge
    [~] Read 24 books in the year (84:reading_challenge)
     ├──[x] Book 1 (85)
     │   └··[x] 1984 - George Orwell (109)
     ├──[ ] Book 2 (86)
     ├──[ ] Book 3 (87)
     ├──[ ] Book 4 (88)
     ├──[ ] Book 5 (89)
     ├──[ ] Book 6 (90)
     ├──[ ] Book 7 (91)
     ├──[ ] Book 8 (92)
     ├──[ ] Book 9 (93)
     ├──[ ] Book 10 (94)
     ├──[ ] Book 11 (95)
     ├──[ ] Book 12 (96)
     ├──[ ] Book 13 (97)
     ├──[ ] Book 14 (98)
     ├──[ ] Book 15 (99)
     ├──[ ] Book 16 (100)
     ├──[ ] Book 17 (101)
     ├──[ ] Book 18 (102)
     ├──[ ] Book 19 (103)
     ├──[ ] Book 20 (104)
     ├──[ ] Book 21 (105)
     ├──[ ] Book 22 (106)
     ├──[ ] Book 23 (107)
     └──[ ] Book 24 (108)

The number of leaves remains the same, so `stat` will correctly display our progress:

    $ grit stat reading_challenge
    (84) ───┬─── (85)
            ├─── (86)
            ├─── (87)
            ├─── (88)
            ├─── (89)
            ├─── (90)
            ├─── (91)
            ├─── (92)
            ├─── (93)
            ├─── (94)
            ├─── (95)
            ├─── (96)
            ├─── (97)
            ├─── (98)
            ├─── (99)
            ├─── (100)
            ├─── (101)
            ├─── (102)
            ├─── (103)
            ├─── (104)
            ├─── (105)
            ├─── (106)
            ├─── (107)
            └─── (108)

    ID: 84
    Name: Read 24 books in the year
    Status: in progress (1/24)
    Parents: 0
    Children: 24
    Alias: reading_challenge
    Created: ????-??-?? ??:??:?? (glob)
