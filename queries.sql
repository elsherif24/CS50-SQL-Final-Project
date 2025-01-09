-- Inserting Data
-- filling access enum
INSERT INTO "access" ("status")
VALUES ('private'),
       ('public'),
       ('following');

-- filling set_type enum
INSERT INTO "set_type" ("type")
VALUES ('regular'),
       ('drop_set'),
       ('failure'),
       ('warm_up');

-- insert some equipments
INSERT INTO "equipments" ("name")
VALUES ('barbell'),
       ('dumbbell'),
       ('rubber band'),
       ('pec deck machine'),
       ('leg press machine'),
       ('leg extension machine');

-- insert new muscles
INSERT INTO "muscles" ("name")
VALUES ('chest'),
       ('shoulders'),
       ('biceps'),
       ('triceps'),
       ('traps'),
       ('quads');

-- inserting new exercise
INSERT INTO "exercises" ("name", "equipment_id", "url", "photo_path", "description")
VALUES ( 'flat bench press', 1, 'e1.com'
       , '/assets/Barbell-Bench-Press.gif', '1- press. 2- hold.');

-- inserting the muscles of the previous exercise
INSERT INTO "muscles_of_exercise" ("exercise_id", "muscle_id")
VALUES (1, 1),
       (1, 2),
       (1, 4);

-- Add new user
INSERT INTO "users" ("username", "password", "height", "weight", "birth_date")
VALUES ('tito', 'password', 185, 60.2, '2000-12-30'),
       ('hema', 'hemaPassword', 170, 70.2, '2003-10-05');
-- Add new sets
INSERT INTO "sets" ("exercise_id", "type_id", "repetition", "weight", "rest")
VALUES (1, 4, 15, 2.5, 60),
       (1, 1, 12, 5, 120),
       (1, 3, 8, 7.5, 120);

-- Add new Routine
INSERT INTO "routines" ("user_id", "name")
VALUES (1, 'Chest workout #A');

-- Add sets to routine
INSERT INTO "routine_set" ("routine_id", "set_id", "order")
VALUES (1, 1, 1),
       (1, 2, 2),
       (1, 3, 3);

-- Add log
INSERT INTO "logs" (user_id, name, access_id, started_time, finished_time)
VALUES (1, 'Chest workout 01-08-2025', 2, '2025-01-08 08:00:00', '2025-01-08 10:00:00');

-- add sets to log
INSERT INTO "log_set" (log_id, set_id, "order")
VALUES (1, 1, 1),
       (1, 2, 2),
       (1, 3, 3);

-- add like to a log
INSERT INTO "likes" (user_id, log_id)
VALUES (1, 1),
       (2, 1);

-- add follow relation
INSERT INTO "follows" (user1_id, user2_id)
VALUES (2, 1);

-- Querying

-- Getting exercises by name
EXPLAIN QUERY PLAN
SELECT *
FROM "exercises"
WHERE "name" = 'bench press';


-- Getting exercises by muscle
SELECT *
FROM "exercises"
WHERE "exercises"."ROWID" IN (SELECT "exercise_id"
                              FROM "muscles_of_exercise"
                              WHERE "muscle_id" = (SELECT "muscles"."ROWID"
                                                   FROM muscles
                                                   WHERE "muscles"."name" = 'chest'));

-- Getting exercise by equipment
SELECT *
FROM "exercises"
WHERE "equipment_id" = (SELECT "equipments"."ROWID"
                        FROM "equipments"
                        WHERE "equipments"."name" = 'barbell');

-- filter exercise library by both muscle name and equipment
SELECT *
FROM "exercises"
WHERE "exercises"."ROWID" IN (SELECT "exercise_id"
                              FROM "muscles_of_exercise"
                              WHERE "muscle_id" = (SELECT "muscles"."ROWID"
                                                   FROM muscles
                                                   WHERE "muscles"."name" = 'chest'))
  AND "equipment_id" = (SELECT "equipments"."ROWID"
                        FROM "equipments"
                        WHERE "equipments"."name" = 'barbell');

-- get targeted muscles by exercise
SELECT "muscles"."name"
FROM "muscles"
         JOIN "muscles_of_exercise" ON muscles.ROWID = muscles_of_exercise.muscle_id
WHERE exercise_id = 1;


-- Get routines by user
SELECT *
FROM "routines"
WHERE "user_id" = 1;

-- Get specific routine sets
SELECT "order",
       "repetition",
       "weight",
       "rest",
       "set_type"."type",
       "exercises"."name" AS 'name',
       "equipments"."name"
                          AS 'equipment'
FROM "routine_set"
         JOIN "routines" ON "routine_set"."routine_id" = "routines"."ROWID"
         JOIN "sets" ON "sets"."ROWID" = "set_id"
         JOIN "exercises" ON "sets"."exercise_id" = "exercises"."ROWID"
         JOIN "set_type" ON "sets"."type_id" = "set_type"."ROWID"
         JOIN "equipments" ON "exercises"."equipment_id" = "equipments"."ROWID"
WHERE "routines"."ROWID" = 1
ORDER BY "order";

-- GET logs by user
SELECT *
FROM "logs"
WHERE "user_id" = 1;

-- Get specific log sets
SELECT "order",
       "repetition",
       "weight",
       "rest",
       "set_type"."type",
       "exercises"."name" AS 'name',
       "equipments"."name"
                          AS 'equipment'
FROM "log_set"
         JOIN "logs" ON "log_set"."log_id" = "logs"."ROWID"
         JOIN "sets" ON "log_set"."set_id" = "sets"."ROWID"
         JOIN "exercises" ON "sets"."exercise_id" = "exercises"."ROWID"
         JOIN "set_type" ON "sets"."type_id" = "set_type"."ROWID"
         JOIN "equipments" ON "exercises"."equipment_id" = "equipments"."ROWID"
WHERE "logs"."ROWID" = 1
ORDER BY "order";

-- Get log likes
SELECT COUNT("ROWID") AS 'Number of likes'
FROM "likes"
WHERE "log_id" = 1;

-- Get followers usernames
SELECT "users"."username"
FROM "users"
WHERE "users"."ROWID" IN (SELECT "follows"."user1_id"
                          FROM "follows"
                          WHERE "user2_id" = 1);

-- Get followers count
SELECT COUNT("follows"."user1_id") AS 'Number of followers'
FROM "follows"
WHERE "user2_id" = 1;
