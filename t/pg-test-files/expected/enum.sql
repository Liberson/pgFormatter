--
-- Enum tests
--

CREATE TYPE rainbow AS ENUM (
    'red',
    'orange',
    'yellow',
    'green',
    'blue',
    'purple'
);

--
-- Did it create the right number of rows?
--

SELECT
    COUNT(*)
FROM
    pg_enum
WHERE
    enumtypid = 'rainbow'::regtype;

--
-- I/O functions
--

SELECT
    'red'::rainbow;

SELECT
    'mauve'::rainbow;

--
-- adding new values
--

CREATE TYPE planets AS ENUM (
    'venus',
    'earth',
    'mars'
);

SELECT
    enumlabel,
    enumsortorder
FROM
    pg_enum
WHERE
    enumtypid = 'planets'::regtype
ORDER BY
    2;

ALTER TYPE planets
    ADD VALUE 'uranus';

SELECT
    enumlabel,
    enumsortorder
FROM
    pg_enum
WHERE
    enumtypid = 'planets'::regtype
ORDER BY
    2;

ALTER TYPE planets
    ADD VALUE 'mercury' BEFORE 'venus';

ALTER TYPE planets
    ADD VALUE 'saturn' BEFORE 'uranus';

ALTER TYPE planets
    ADD VALUE 'jupiter' AFTER 'mars';

ALTER TYPE planets
    ADD VALUE 'neptune' AFTER 'uranus';

SELECT
    enumlabel,
    enumsortorder
FROM
    pg_enum
WHERE
    enumtypid = 'planets'::regtype
ORDER BY
    2;

SELECT
    enumlabel,
    enumsortorder
FROM
    pg_enum
WHERE
    enumtypid = 'planets'::regtype
ORDER BY
    enumlabel::planets;

-- errors for adding labels
ALTER TYPE planets
    ADD VALUE 'plutoplutoplutoplutoplutoplutoplutoplutoplutoplutoplutoplutoplutopluto';

ALTER TYPE planets
    ADD VALUE 'pluto' AFTER 'zeus';

-- if not exists tests
--  existing value gives error

ALTER TYPE planets
    ADD VALUE 'mercury';

-- unless IF NOT EXISTS is specified
ALTER TYPE planets
    ADD VALUE IF NOT EXISTS 'mercury';

-- should be neptune, not mercury
SELECT
    enum_last(NULL::planets);

ALTER TYPE planets
    ADD VALUE IF NOT EXISTS 'pluto';

-- should be pluto, i.e. the new value
SELECT
    enum_last(NULL::planets);

--
-- Test inserting so many values that we have to renumber
--

CREATE TYPE insenum AS enum (
    'L1',
    'L2'
);

ALTER TYPE insenum
    ADD value 'i1' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i2' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i3' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i4' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i5' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i6' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i7' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i8' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i9' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i10' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i11' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i12' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i13' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i14' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i15' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i16' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i17' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i18' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i19' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i20' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i21' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i22' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i23' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i24' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i25' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i26' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i27' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i28' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i29' BEFORE 'L2';

ALTER TYPE insenum
    ADD value 'i30' BEFORE 'L2';

-- The exact values of enumsortorder will now depend on the local properties
-- of float4, but in any reasonable implementation we should get at least
-- 20 splits before having to renumber; so only hide values > 20.

SELECT
    enumlabel,
    CASE WHEN enumsortorder > 20 THEN
        NULL
    ELSE
        enumsortorder
    END AS so
FROM
    pg_enum
WHERE
    enumtypid = 'insenum'::regtype
ORDER BY
    enumsortorder;

--
-- Basic table creation, row selection
--

CREATE TABLE enumtest (
    col rainbow
);

INSERT INTO enumtest
    VALUES ('red'), ('orange'), ('yellow'), ('green');

SELECT
    *
FROM
    enumtest;

--
-- Operators, no index
--

SELECT
    *
FROM
    enumtest
WHERE
    col = 'orange';

SELECT
    *
FROM
    enumtest
WHERE
    col <> 'orange'
ORDER BY
    col;

SELECT
    *
FROM
    enumtest
WHERE
    col > 'yellow'
ORDER BY
    col;

SELECT
    *
FROM
    enumtest
WHERE
    col >= 'yellow'
ORDER BY
    col;

SELECT
    *
FROM
    enumtest
WHERE
    col < 'green'
ORDER BY
    col;

SELECT
    *
FROM
    enumtest
WHERE
    col <= 'green'
ORDER BY
    col;

--
-- Cast to/from text
--

SELECT
    'red'::rainbow::text || 'hithere';

SELECT
    'red'::text::rainbow = 'red'::rainbow;

--
-- Aggregates
--

SELECT
    min(col)
FROM
    enumtest;

SELECT
    max(col)
FROM
    enumtest;

SELECT
    max(col)
FROM
    enumtest
WHERE
    col < 'green';

--
-- Index tests, force use of index
--

SET enable_seqscan = OFF;

SET enable_bitmapscan = OFF;

--
-- Btree index / opclass with the various operators
--

CREATE UNIQUE INDEX enumtest_btree ON enumtest USING btree (col);

SELECT
    *
FROM
    enumtest
WHERE
    col = 'orange';

SELECT
    *
FROM
    enumtest
WHERE
    col <> 'orange'
ORDER BY
    col;

SELECT
    *
FROM
    enumtest
WHERE
    col > 'yellow'
ORDER BY
    col;

SELECT
    *
FROM
    enumtest
WHERE
    col >= 'yellow'
ORDER BY
    col;

SELECT
    *
FROM
    enumtest
WHERE
    col < 'green'
ORDER BY
    col;

SELECT
    *
FROM
    enumtest
WHERE
    col <= 'green'
ORDER BY
    col;

SELECT
    min(col)
FROM
    enumtest;

SELECT
    max(col)
FROM
    enumtest;

SELECT
    max(col)
FROM
    enumtest
WHERE
    col < 'green';

DROP INDEX enumtest_btree;

--
-- Hash index / opclass with the = operator
--

CREATE INDEX enumtest_hash ON enumtest USING HASH (col);

SELECT
    *
FROM
    enumtest
WHERE
    col = 'orange';

DROP INDEX enumtest_hash;

--
-- End index tests
--

RESET enable_seqscan;

RESET enable_bitmapscan;

--
-- Domains over enums
--

CREATE DOMAIN rgb AS rainbow CHECK (VALUE IN ('red', 'green', 'blue'));

SELECT
    'red'::rgb;

SELECT
    'purple'::rgb;

SELECT
    'purple'::rainbow::rgb;

DROP DOMAIN rgb;

--
-- Arrays
--

SELECT
    '{red,green,blue}'::rainbow[];

SELECT
    ('{red,green,blue}'::rainbow[])[2];

SELECT
    'red' = ANY ('{red,green,blue}'::rainbow[]);

SELECT
    'yellow' = ANY ('{red,green,blue}'::rainbow[]);

SELECT
    'red' = ALL ('{red,green,blue}'::rainbow[]);

SELECT
    'red' = ALL ('{red,red}'::rainbow[]);

--
-- Support functions
--

SELECT
    enum_first(NULL::rainbow);

SELECT
    enum_last('green'::rainbow);

SELECT
    enum_range(NULL::rainbow);

SELECT
    enum_range('orange'::rainbow, 'green'::rainbow);

SELECT
    enum_range(NULL, 'green'::rainbow);

SELECT
    enum_range('orange'::rainbow, NULL);

SELECT
    enum_range(NULL::rainbow, NULL);

--
-- User functions, can't test perl/python etc here since may not be compiled.
--

CREATE FUNCTION echo_me (anyenum)
    RETURNS text
    AS $$
BEGIN
    RETURN $1::text || 'omg';
END
$$
LANGUAGE plpgsql;

SELECT
    echo_me ('red'::rainbow);

--
-- Concrete function should override generic one
--

CREATE FUNCTION echo_me (rainbow)
    RETURNS text
    AS $$
BEGIN
    RETURN $1::text || 'wtf';
END
$$
LANGUAGE plpgsql;

SELECT
    echo_me ('red'::rainbow);

--
-- If we drop the original generic one, we don't have to qualify the type
-- anymore, since there's only one match
--

DROP FUNCTION echo_me (anyenum);

SELECT
    echo_me ('red');

DROP FUNCTION echo_me (rainbow);

--
-- RI triggers on enum types
--

CREATE TABLE enumtest_parent (
    id rainbow PRIMARY KEY
);

CREATE TABLE enumtest_child (
    parent rainbow REFERENCES enumtest_parent
);

INSERT INTO enumtest_parent
    VALUES ('red');

INSERT INTO enumtest_child
    VALUES ('red');

INSERT INTO enumtest_child
    VALUES ('blue');

-- fail
DELETE FROM enumtest_parent;

-- fail
--
-- cross-type RI should fail
--

CREATE TYPE bogus AS ENUM (
    'good',
    'bad',
    'ugly'
);

CREATE TABLE enumtest_bogus_child (
    parent bogus REFERENCES enumtest_parent
);

DROP TYPE bogus;

-- check renaming a value
ALTER TYPE rainbow RENAME VALUE 'red' TO 'crimson';

SELECT
    enumlabel,
    enumsortorder
FROM
    pg_enum
WHERE
    enumtypid = 'rainbow'::regtype
ORDER BY
    2;

-- check that renaming a non-existent value fails
ALTER TYPE rainbow RENAME VALUE 'red' TO 'crimson';

-- check that renaming to an existent value fails
ALTER TYPE rainbow RENAME VALUE 'blue' TO 'green';

--
-- check transactional behaviour of ALTER TYPE ... ADD VALUE
--

CREATE TYPE bogus AS ENUM (
    'good'
);

-- check that we can add new values to existing enums in a transaction
-- but we can't use them

BEGIN;
ALTER TYPE bogus
    ADD VALUE 'new';
SAVEPOINT x;
SELECT
    'new'::bogus;
-- unsafe
ROLLBACK TO x;

SELECT
    enum_first(NULL::bogus);

-- safe
SELECT
    enum_last(NULL::bogus);

-- unsafe
ROLLBACK TO x;

SELECT
    enum_range(NULL::bogus);

-- unsafe
ROLLBACK TO x;

COMMIT;

SELECT
    'new'::bogus;

-- now safe
SELECT
    enumlabel,
    enumsortorder
FROM
    pg_enum
WHERE
    enumtypid = 'bogus'::regtype
ORDER BY
    2;

-- check that we recognize the case where the enum already existed but was
-- modified in the current txn; this should not be considered safe

BEGIN;
ALTER TYPE bogus RENAME TO bogon;
ALTER TYPE bogon
    ADD VALUE 'bad';
SELECT
    'bad'::bogon;
ROLLBACK;

-- but a renamed value is safe to use later in same transaction
BEGIN;
ALTER TYPE bogus RENAME VALUE 'good' TO 'bad';
SELECT
    'bad'::bogus;
ROLLBACK;

DROP TYPE bogus;

-- check that values created during CREATE TYPE can be used in any case
BEGIN;
CREATE TYPE bogus AS ENUM (
    'good',
    'bad',
    'ugly'
);
ALTER TYPE bogus RENAME TO bogon;
SELECT
    enum_range(NULL::bogon);
ROLLBACK;

-- ideally, we'd allow this usage; but it requires keeping track of whether
-- the enum type was created in the current transaction, which is expensive

BEGIN;
CREATE TYPE bogus AS ENUM (
    'good'
);
ALTER TYPE bogus RENAME TO bogon;
ALTER TYPE bogon
    ADD VALUE 'bad';
ALTER TYPE bogon
    ADD VALUE 'ugly';
SELECT
    enum_range(NULL::bogon);
-- fails
ROLLBACK;

--
-- Cleanup
--

DROP TABLE enumtest_child;

DROP TABLE enumtest_parent;

DROP TABLE enumtest;

DROP TYPE rainbow;

--
-- Verify properly cleaned up
--

SELECT
    COUNT(*)
FROM
    pg_type
WHERE
    typname = 'rainbow';

SELECT
    *
FROM
    pg_enum
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            pg_type
        WHERE
            pg_type.oid = enumtypid);
