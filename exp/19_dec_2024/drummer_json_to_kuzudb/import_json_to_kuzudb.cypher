INSTALL json;
LOAD EXTENSION json;
:highlight off
:stats off



CREATE NODE TABLE Document (
          dateCreated TIMESTAMP,
          head struct (
          title STRING,                 
          dateCreated TIMESTAMP,           
          ownerTwitterScreenName STRING,
          ownerName STRING,             
          ownerId STRING,               
          urlUpdateSocket STRING,       
          dateModified TIMESTAMP,          
          expansionState STRING,        
          lastCursor STRING             
          ),
          primary key (dateCreated)
      );

CREATE NODE TABLE Sentence (
    text STRING,
    title STRING,
    created TIMESTAMP,
    primary key (created)
);

CREATE REL TABLE Body (
    From Document to Sentence,
    position serial,
    ONE_MANY
);

CREATE REL TABLE subs (
    From Sentence to Sentence,
    position serial,
    ONE_MANY
);

load with headers (
                dateCreated TIMESTAMP,
                head struct (
                title STRING,                 
                dateCreated TIMESTAMP,           
                ownerTwitterScreenName STRING,
                ownerName STRING,             
                ownerId STRING,               
                urlUpdateSocket STRING,       
                dateModified STRING,          
                expansionState STRING,        
                lastCursor STRING             
                )) from 'source.json' return *
      ;

Copy Document FROM 'source.json';

Match (d:Document) return d.*;

// lets load the sentences from body

copy sentence from (
load with headers (
                  dateCreated TIMESTAMP,
                  head struct (
                     title STRING,                 
                     dateCreated TIMESTAMP,           
                     ownerTwitterScreenName STRING,
                     ownerName STRING,             
                     ownerId STRING,               
                     urlUpdateSocket STRING,       
                     dateModified STRING,          
                     expansionState STRING,        
                     lastCursor STRING             
                     ),
                     body struct (
                         text string,                        
                         created timestamp,
                         title string                         
                     )[]
                     ) from 'source.json' 
    unwind body as s
    return distinct s.*
);

// now lets load the relationship between subs
load with headers (
                       body struct (
                               text string,
                               created timestamp,
                               title string,
                               subs struct(
                                 text string,
                                 created timestamp,
                                 title string,
                                 subs struct(
                                   text string,
                                   created timestamp,
                                   title string
                                 )[]
                               )[]
                           )[]
                           ) from 'source.json' 
          unwind body as b
          unwind b.subs as s1
          unwind s1.subs as s
          return distinct s.title as title, s.text as text, s.created as created;

//now with union

load with headers (
                       body struct (
                               text string,
                               created timestamp,
                               title string,
                               subs struct(
                                 text string,
                                 created timestamp,
                                 title string,
                                 subs struct(
                                   text string,
                                   created timestamp,
                                   title string
                                 )[]
                               )[]
                           )[]
                           ) from 'source.json' 
          unwind body as b
          unwind b.subs as s1
          unwind s1.subs as s
          return distinct s.title as title, s.text as text, s.created as created
Union all
load with headers (
                       body struct (
                               text string,
                               created timestamp,
                               title string,
                               subs struct(
                                 text string,
                                 created timestamp,
                                 title string,
                                 subs struct(
                                   text string,
                                   created timestamp,
                                   title string
                                 )[]
                               )[]
                           )[]
                           ) from 'source.json' 
          unwind body as b
          unwind b.subs as s
          return distinct s.title as title, s.text as text, s.created as created
union all
load with headers(
                       body struct (
                               text string,
                               created timestamp,
                               title string,
                               subs struct(
                                 text string,
                                 created timestamp,
                                 title string,
                                 subs struct(
                                   text string,
                                   created timestamp,
                                   title string
                                 )[]
                               )[]
                           )[]
                           ) from 'source.json' 
          unwind body as s
          return distinct s.title as title, s.text as text, s.created as created;

//now lets populate the table with this

COPY Sentence FROM ( load with headers (
                       body struct (
                               text string,
                               created timestamp,
                               title string,
                               subs struct(
                                 text string,
                                 created timestamp,
                                 title string,
                                 subs struct(
                                   text string,
                                   created timestamp,
                                   title string
                                 )[]
                               )[]
                           )[]
                           ) from 'source.json' 
          unwind body as b
          unwind b.subs as s1
          unwind s1.subs as s
          return distinct s.title as title, s.text as text, s.created as created
Union all
load with headers (
                       body struct (
                               text string,
                               created timestamp,
                               title string,
                               subs struct(
                                 text string,
                                 created timestamp,
                                 title string,
                                 subs struct(
                                   text string,
                                   created timestamp,
                                   title string
                                 )[]
                               )[]
                           )[]
                           ) from 'source.json' 
          unwind body as b
          unwind b.subs as s
          return distinct s.title as title, s.text as text, s.created as created
union all
load with headers(
                       body struct (
                               text string,
                               created timestamp,
                               title string,
                               subs struct(
                                 text string,
                                 created timestamp,
                                 title string,
                                 subs struct(
                                   text string,
                                   created timestamp,
                                   title string
                                 )[]
                               )[]
                           )[]
                           ) from 'source.json' 
          unwind body as s
          return distinct s.title as title, s.text as text, s.created as created)
;

//Finally let's try to create the relationship of a sentence to a document.

