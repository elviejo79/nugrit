CREATE NODE TABLE Document (
      created TIMESTAMP,
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
      primary key (created)
      );

CREATE NODE TABLE Sentence (
       text STRING,
created TIMESTAMP,
      title STRING,
      primary key (created)
      );

CREATE REL TABLE Body (
       From Document to Sentence,
       position INT16,
       ONE_MANY
       );

CREATE REL TABLE subs (
       From Sentence to Sentence,
       position INT16
       );
