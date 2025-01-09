-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- users table
-- password can be hashed
CREATE TABLE "users"
(
    "username"  TEXT    NOT NULL UNIQUE,
    "password"  TEXT    NOT NULL,
    "height"    INT     NOT NULL CHECK ("height" > 0),
    "weight"    REAL    NOT NULL CHECK ("weight" > 0),
    "birthdate" NUMERIC NOT NULL
);

-- user1 follows user2 one direction.
-- user can't follow himself
CREATE TABLE "follows"
(
    "user1_id" INT,
    "user2_id" INT,
    FOREIGN KEY ("user1_id") REFERENCES "users" ("ROWID"),
    FOREIGN KEY ("user2_id") REFERENCES "users" ("ROWID"),
    UNIQUE ("user1_id", "user2_id"),
    CHECK ( "user1_id" != "user2_id" )
);

-- equipments names are unique
CREATE TABLE "equipments"
(
    "name" TEXT NOT NULL UNIQUE
);

-- muscles names are unique
CREATE TABLE "muscles"
(
    "name" TEXT NOT NULL UNIQUE
);

-- url for video tutorial
CREATE TABLE "exercises"
(
    "name"         TEXT NOT NULL,
    "equipment_id" INT,
    "url"          TEXT NOT NULL UNIQUE,
    "photo_url"    TEXT NOT NULL,
    "description"  TEXT NOT NULL,
    FOREIGN KEY ("equipment_id") REFERENCES "equipments" ("ROWID"),
    UNIQUE ("name", "equipment_id")
);

-- exercises can target multiple muscles and can use only one equipment
CREATE TABLE "muscles_of_exercise"
(
    "exercise_id" INT,
    "muscle_id"   INT,
    FOREIGN KEY ("exercise_id") REFERENCES "exercises" ("ROWID"),
    FOREIGN KEY ("muscle_id") REFERENCES "muscles" ("ROWID")
);

-- enum table for who can access a log or routine
CREATE TABLE "access"
(
    "status" TEXT NOT NULL UNIQUE CHECK ("status" IN ('private', 'public', 'following')) DEFAULT 'private'
);

-- routine names are unique within users routines
CREATE TABLE "routines"
(
    "user_id"      INT,
    "name"         TEXT    NOT NULL,
    "access_id"    INT     NOT NULL DEFAULT 'private',
    "created_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_updated" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("user_id") REFERENCES "users" ("ROWID"),
    FOREIGN KEY ("access_id") REFERENCES "access" ("ROWID"),
    UNIQUE ("user_id", "name")

);

-- logs can have an optional photo with them.
CREATE TABLE "logs"
(
    "user_id"       INT,
    "name"          TEXT    NOT NULL,
    "access_id"     INT     NOT NULL DEFAULT 'private',
    "created_date"  NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_updated"  NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "started_time"  NUMERIC NOT NULL,
    "finished_time" NUMERIC NOT NULL,
    "photo_url"     TEXT,
    FOREIGN KEY ("user_id") REFERENCES "users" ("ROWID"),
    FOREIGN KEY ("access_id") REFERENCES "access" ("ROWID"),
    UNIQUE ("user_id", "name")
);

-- users can like their logs and others
CREATE TABLE "likes"
(
    "user_id" INT,
    "log_id"  INT,
    "time"    NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("user_id") REFERENCES "users" ("ROWID"),
    FOREIGN KEY ("log_id") REFERENCES "logs" ("ROWID")
);

-- ever set must have a type
CREATE TABLE "set_type"
(
    "type" TEXT NOT NULL UNIQUE DEFAULT 'regular' CHECK ("type" IN ('regular', 'failure', 'drop_set', 'warm_up'))
);

-- rest time in seconds, weight in kg and can be zero for empty bar or body weight
-- every set have one exercise only
CREATE TABLE "sets"
(
    "exercise_id" INT,
    "type_id"     INT,
    "repetition"  INT  NOT NULL CHECK ( "repetition" > 0),
    "weight"      REAL NOT NULL CHECK ( "weight" >= 0 ),
    "rest"        INT  NOT NULL CHECK ( "rest" > 0 ),
    FOREIGN KEY ("exercise_id") REFERENCES "exercises" ("ROWID"),
    FOREIGN KEY ("type_id") REFERENCES "set_type" ("ROWID")
);

-- join table between logs and sets.
-- set's order is unique within a log
CREATE TABLE "log_set"
(
    "log_id" INT,
    "set_id" INT,
    "order"  INT NOT NULL,
    FOREIGN KEY ("log_id") REFERENCES "logs" ("ROWID"),
    FOREIGN KEY ("set_id") REFERENCES "sets" ("ROWID"),
    UNIQUE ("order", "log_id")
);

-- join table between routines and sets.
-- set's order is unique within a routine.
-- these are suggested data.
CREATE TABLE "routine_set"
(
    "routine_id" INT,
    "set_id"     INT,
    "order"      INT NOT NULL,
    FOREIGN KEY ("routine_id") REFERENCES "routines" ("ROWID"),
    FOREIGN KEY ("set_id") REFERENCES "sets" ("ROWID"),
    UNIQUE ("order", "routine_id")
);

-- CREATE index on muscles_of_exercise for search exercise by muscles
CREATE INDEX "muscles_of_exercise_index" ON "muscles_of_exercise" ("muscle_id");
-- CREATE index on exercises for search exercise by equipment
CREATE INDEX "exercises_equipment_index" ON "exercises" ("equipment_id");
-- CREATE index on muscles_of_exercise for search by exercise_id
CREATE INDEX "muscles_of_exercise_exercise_index" ON "muscles_of_exercise" ("exercise_id");
-- CREATE index on follows for search by followers
CREATE INDEX "follows_index" ON "follows" ("user2_id");
-- Create index on likes for search likes by log_id
CREATE INDEX "likes_index" ON "likes" ("log_id");
