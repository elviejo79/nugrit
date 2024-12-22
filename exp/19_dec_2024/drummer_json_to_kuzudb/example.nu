# This is a literate file that you can execut with prysk
#
# ``` bash
# $ prysk --shell nu --shell-opts "--stdin"  --indent=4 ./main_example.prysk.md
# ```
#
## Let's import an original json
#
#I took source.json from one of dave winners posts.
#Is the structure of a jsont that was exportde from OPML.
#And that works with many of his tools.

let db_path = './example.kuzudb'

## clean the database

rm --recursive --force $db_path

## Create the original tables

let head_struct = "head struct(
    title STRING,
    dateCreated TIMESTAMP,
    ownerTwitterScreenName STRING,
    ownerName STRING,
    ownerId STRING,
    urlUpdateSocket STRING,
    dateModified TIMESTAMP,
    expansionState STRING,
    lastCursor STRING)"

$"CREATE NODE TABLE Document \(dateCreated TIMESTAMP, ($head_struct), primary key \(dateCreated\)\);"
| db_query

let sentence_struct = "text STRING,
created TIMESTAMP,
title STRING
"


$"CREATE NODE TABLE Sentence \( ($sentence_struct) , primary key \(created\)\);" | db_query

"CREATE REL TABLE Body (
From Document to Sentence,
position serial,
ONE_MANY
);"
| db_query

"CREATE REL TABLE subs (
From Sentence to Sentence,
position serial,
ONE_MANY
);"
| db_query

# let's see if it can read the json structure
let load_with_headers = $"load with headers \(
       dateCreated TIMESTAMP,
       ($head_struct)"


$load_with_headers |$"($in) \) from 'source.json' return *;" | db_query

"COPY Document FROM 'source.json';" | db_query

"MATCH (d:Document) return d.*;" | db_query

# let's load the sentence from body

let body_struct = $"body struct \( ($sentence_struct) \)[]"

$"COPY Sentence FROM \(
($load_with_headers),
($body_struct)
\) from 'source.json'
UNWIND body as s
return distinct s.* \);"
| db_query

let subs = $"subs struct\( ($sentence_struct)\)[]"
let subs_subs = $"subs struct\( ($subs) \)[]"
let subs_subs_subs = $"subs struct\( ($subs_subs) \)[]"
let body_struct_sss = $"body struct\( ($subs) \)"


let unwind = 'unwind body as s'

mut current_import = $body_struct
mut current_unwind = $unwind

mut current_load_sentences = $"load with headers \(($current_import)\) ($current_unwind) return return distinct s.*"

$current_load_sentences | db_query


let unwind_s = 'unwind body as b unwinds b.subs as s'
let unwind_ss = 'unwind body as b unwinds b.subs as ss unwind ss.subs as s'
let unwind_sss = 'unwind body as b unwinds b.subs as ss unwind ss.subs as ss unwind ss.subs as s'


def db_query [] :string -> string {
 $in | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7
}
