# Let's create files

use std assert


let db_path = $"(pwd)/opml.kuzudb"

main setup-db

import_into Document $.node.document.0
import_into Sentence $.node.sentences
import_into Body $.rel.body
import_into Subs $.rel.subs

def "main setup-db" [ ] : nothing -> nothing {
   rm --force --recursive $db_path
   open ./drummer_land_document_schema.cypher | db_query

}

def import_into [node:string, json_cell_path:cell-path] {
    # pre_conditions:
    # source.json is a file that comforms to dave winners drummer.land
    # get_node_and_rel_jsonata returns a json object so that json_cell_path is inside
    # node existis in the kuzudb database inside $db_path

    let nodes_and_rels = (cat source.json
    | jfq --query-file ./get_node_and_rel.jsonata
    | from json
    )

    let $tmp_file = (mktemp -t --suffix $".($node).json")
    print $tmp_file

    $nodes_and_rels | get $json_cell_path | to json | save --force $tmp_file
    $"COPY ($node) FROM '($tmp_file)';" | db_query
}

def db_query [ ] : string -> string {
    $in | kuzu $db_path --init install_json.cypher --mode jsonlines --no_stats  --no_progress_bar | tail --lines +7
}
