**TodoFS**

TodoFs is my idea of a Todo list that can be used as a linux filesystem.
Inspired by Grit and the MultiTree datastructure.
Built on top a Graph Database (KuzuDB).

This is a literate document that works as an automatic test.
In order to execute the tests run this command:

It's the name of 

``` bash
prysk --shell /bin/bash --indent=4 --interactive --color never ./README.md
```

# Initialize the state
h
    $ cd ~/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/treefs
    $ ./todo initialize_db

# Create a todo task

    $ ./todo task Take out the trash
    ╭──────┬───────────────────────────────────────────────────────────────────────╮
    │ id   │ 4809015                                                               │
    │ path │ /home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/treefs/ │
    │      │ db/tasks/take_out_the_trash                                           │
    ╰──────┴───────────────────────────────────────────────────────────────────────╯ (no-eol)
    $ ./todo tree
    /home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/treefs/db
    |-- by_date
    |   `-- 2024-12-19
    |       `-- take_out_the_trash -> ../../tasks/take_out_the_trash
    |-- by_id
    |   `-- 4809015 -> ../tasks/take_out_the_trash  [recursive, not followed]
    `-- tasks
        `-- take_out_the_trash
    
    7 directories, 0 files

The output should include tasks and by_date

# Add more tasks

    $ ./todo task Call dad
    ╭──────┬───────────────────────────────────────────────────────────────────────╮
    │ id   │ 4809019                                                               │
    │ path │ /home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/treefs/ │
    │      │ db/tasks/call_dad                                                     │
    ╰──────┴───────────────────────────────────────────────────────────────────────╯ (no-eol)
    $ ./todo task Do the laundry
    ╭──────┬───────────────────────────────────────────────────────────────────────╮
    │ id   │ 4809020                                                               │
    │ path │ /home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/treefs/ │
    │      │ db/tasks/do_the_laundry                                               │
    ╰──────┴───────────────────────────────────────────────────────────────────────╯ (no-eol)
    $ ./todo tree
    /home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/treefs/db
    |-- by_date
    |   `-- 2024-12-19
    |       |-- call_dad -> ../../tasks/call_dad
    |       |-- do_the_laundry -> ../../tasks/do_the_laundry
    |       `-- take_out_the_trash -> ../../tasks/take_out_the_trash
    |-- by_id
    |   |-- 4809015 -> ../tasks/take_out_the_trash  [recursive, not followed]
    |   |-- 4809019 -> ../tasks/call_dad  [recursive, not followed]
    |   `-- 4809020 -> ../tasks/do_the_laundry  [recursive, not followed]
    `-- tasks
        |-- call_dad
        |-- do_the_laundry
        `-- take_out_the_trash
    
    13 directories, 0 files

# Subtasks

Let's add another task

    $ ./todo task Get groceries
    ╭──────┬───────────────────────────────────────────────────────────────────────╮
    │ id   │ 4809021                                                               │
    │ path │ /home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/treefs/ │
    │      │ db/tasks/get_groceries                                                │
    ╰──────┴───────────────────────────────────────────────────────────────────────╯ (no-eol)
    $ ./todo tree
    /home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/treefs/db
    |-- by_date
    |   `-- 2024-12-19
    |       |-- call_dad -> ../../tasks/call_dad
    |       |-- do_the_laundry -> ../../tasks/do_the_laundry
    |       |-- get_groceries -> ../../tasks/get_groceries
    |       `-- take_out_the_trash -> ../../tasks/take_out_the_trash
    |-- by_id
    |   |-- 4809015 -> ../tasks/take_out_the_trash  [recursive, not followed]
    |   |-- 4809019 -> ../tasks/call_dad  [recursive, not followed]
    |   |-- 4809020 -> ../tasks/do_the_laundry  [recursive, not followed]
    |   `-- 4809021 -> ../tasks/get_groceries  [recursive, not followed]
    `-- tasks
        |-- call_dad
        |-- do_the_laundry
        |-- get_groceries
        `-- take_out_the_trash
    
    16 directories, 0 files

## Create an alias
Let's create an alias

    $ ./todo alias 4809021 shoping
    $ ./todo tree
    /home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/treefs/db
    |-- by_alias
    |   `-- shoping -> ../tasks/get_groceries
    |-- by_date
    |   `-- 2024-12-19
    |       |-- call_dad -> ../../tasks/call_dad
    |       |-- do_the_laundry -> ../../tasks/do_the_laundry
    |       |-- get_groceries -> ../../tasks/get_groceries  [recursive, not followed]
    |       `-- take_out_the_trash -> ../../tasks/take_out_the_trash
    |-- by_id
    |   |-- 4809015 -> ../tasks/take_out_the_trash  [recursive, not followed]
    |   |-- 4809019 -> ../tasks/call_dad  [recursive, not followed]
    |   |-- 4809020 -> ../tasks/do_the_laundry  [recursive, not followed]
    |   `-- 4809021 -> ../tasks/get_groceries  [recursive, not followed]
    `-- tasks
        |-- call_dad
        |-- do_the_laundry
        |-- get_groceries
        `-- take_out_the_trash
    
    18 directories, 0 files


To divide it into subtasks, we have to specify the parent (when no parent is given, `add` defaults to the current date node):

## add subtasks

    $ ./todo add by_alias/shoping/ Bread
    ╭──────┬───────────────────────────────────────────────────────────────────────╮
    │ id   │ 4809024                                                               │
    │ path │ /home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/treefs/ │
    │      │ db/tasks/bread                                                        │
    ╰──────┴───────────────────────────────────────────────────────────────────────╯
    $ ./todo add by_alias/shoping/ Milk
    ╭──────┬───────────────────────────────────────────────────────────────────────╮
    │ id   │ 4809026                                                               │
    │ path │ /home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/treefs/ │
    │      │ db/tasks/milk                                                         │
    ╰──────┴───────────────────────────────────────────────────────────────────────╯
    $ ./todo add by_alias/shoping/ Eggs
    ╭──────┬───────────────────────────────────────────────────────────────────────╮
    │ id   │ 4809027                                                               │
    │ path │ /home/agarciafdz/r/gh/elv79/deleteme_beeminder_10klocs/nugrit/treefs/ │
    │      │ db/tasks/eggs                                                         │
    ╰──────┴───────────────────────────────────────────────────────────────────────╯
