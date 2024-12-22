? what did you learn yesterday?
    * By using jsonata to do the Extraction, and Transformation of the source.json
        It was so much easier than the load with headers from KuzuDB.
    * Then it was easy to do some queries in Kuzudb
    * Now I'm stuck in the output.
      ? What is the current problem?
          * In kuzudb generating the nested structure of the document back, is difficult.
            ? why?
              * because it seems that in order to use array_to_json, the *NESTED* nature dosen't help with recursive queries.
? what do you want to do today?
  * try to generate a nested document, from KuzuDB
  * make a better input data, like include Hash in the text, and then use jsonata to extract the tags, and build
