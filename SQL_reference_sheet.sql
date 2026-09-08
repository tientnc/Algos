/*
===============================================================================
SQL REFERENCE / CHEAT SHEET
===============================================================================

Purpose:
    A practical "look this up whenever needed" SQL file.

Dialect:
    Mostly standard SQL, with some PostgreSQL-flavored examples.
    MySQL / SQLite / SQL Server differ slightly in a few places
    (AUTO_INCREMENT, LIMIT/TOP, date functions, UPSERT syntax, etc.).

Mental model:
    SQL usually works with TABLES (sets of rows), not arrays.

Common operation analogy:
    Create data structure  -> CREATE TABLE
    Add element            -> INSERT
    Find/search            -> SELECT ... WHERE
    Modify element         -> UPDATE
    Remove element         -> DELETE
    Copy                    -> CREATE TABLE ... AS SELECT
    Sort                    -> ORDER BY
    Filter                  -> WHERE / HAVING
    Combine structures      -> JOIN / UNION
    Aggregate               -> GROUP BY + COUNT/SUM/AVG/...
===============================================================================
*/


-- ============================================================================
-- 0. OPTIONAL: CLEAN START
-- ============================================================================

DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;


-- ============================================================================
-- 1. CREATE TABLES
-- ============================================================================

CREATE TABLE students (
    student_id      INTEGER PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(200) UNIQUE,
    age             INTEGER CHECK (age >= 0),
    major           VARCHAR(100),
    gpa             DECIMAL(3, 2) CHECK (gpa BETWEEN 0 AND 4),
    active          BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE courses (
    course_id       INTEGER PRIMARY KEY,
    course_name     VARCHAR(200) NOT NULL,
    department      VARCHAR(50),
    credits         INTEGER DEFAULT 3 CHECK (credits > 0)
);

CREATE TABLE enrollments (
    student_id      INTEGER,
    course_id       INTEGER,
    semester        VARCHAR(20),
    grade           VARCHAR(2),

    PRIMARY KEY (student_id, course_id, semester),

    FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON DELETE CASCADE,

    FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE CASCADE
);


-- ============================================================================
-- 2. INSERT / ADD DATA
-- ============================================================================

-- Insert one row
INSERT INTO students (student_id, name, email, age, major, gpa)
VALUES (1, 'Alice', 'alice@example.com', 20, 'Computer Science', 3.90);

-- Insert several rows
INSERT INTO students (student_id, name, email, age, major, gpa, active)
VALUES
    (2, 'Bob',   'bob@example.com',   21, 'Economics',        3.50, TRUE),
    (3, 'Carol', 'carol@example.com', 19, 'Mathematics',      3.80, TRUE),
    (4, 'David', 'david@example.com', 22, 'Computer Science', 2.95, FALSE),
    (5, 'Eve',   NULL,                20, NULL,               NULL, TRUE);

INSERT INTO courses (course_id, course_name, department, credits)
VALUES
    (101, 'Algorithms', 'CS', 4),
    (102, 'Databases', 'CS', 4),
    (201, 'Microeconomics', 'ECON', 3),
    (301, 'Linear Algebra', 'MATH', 3);

INSERT INTO enrollments (student_id, course_id, semester, grade)
VALUES
    (1, 101, 'Fall 2026', 'A'),
    (1, 102, 'Fall 2026', 'A'),
    (2, 201, 'Fall 2026', 'B'),
    (3, 301, 'Fall 2026', 'A');


-- ============================================================================
-- 3. SELECT / FIND DATA
-- ============================================================================

-- Everything
SELECT *
FROM students;

-- Specific columns
SELECT name, major, gpa
FROM students;

-- Rename output columns
SELECT
    name AS student_name,
    gpa AS grade_point_average
FROM students;

-- Remove duplicate values
SELECT DISTINCT major
FROM students;


-- ============================================================================
-- 4. WHERE: CONDITIONS / COMPARISONS
-- ============================================================================

-- Equal
SELECT *
FROM students
WHERE major = 'Computer Science';

-- Not equal
SELECT *
FROM students
WHERE major <> 'Computer Science';

-- Many databases also accept:
-- WHERE major != 'Computer Science';

-- Numeric comparisons
SELECT *
FROM students
WHERE gpa > 3.5;

SELECT *
FROM students
WHERE age >= 20;

SELECT *
FROM students
WHERE age < 21;

SELECT *
FROM students
WHERE gpa <= 3.8;


-- ============================================================================
-- 5. BOOLEAN CONDITIONS: AND / OR / NOT
-- ============================================================================

SELECT *
FROM students
WHERE major = 'Computer Science'
  AND gpa >= 3.5;

SELECT *
FROM students
WHERE major = 'Computer Science'
   OR major = 'Mathematics';

SELECT *
FROM students
WHERE NOT active;

-- Parentheses matter
SELECT *
FROM students
WHERE active = TRUE
  AND (major = 'Computer Science' OR major = 'Mathematics');


-- ============================================================================
-- 6. BETWEEN / IN / LIKE
-- ============================================================================

-- Inclusive range
SELECT *
FROM students
WHERE gpa BETWEEN 3.0 AND 4.0;

-- Equivalent:
SELECT *
FROM students
WHERE gpa >= 3.0
  AND gpa <= 4.0;

-- Match one of several values
SELECT *
FROM students
WHERE major IN ('Computer Science', 'Mathematics', 'Economics');

-- Not in
SELECT *
FROM students
WHERE major NOT IN ('Computer Science', 'Mathematics');

-- Pattern matching
-- % = any number of characters
-- _ = exactly one character

SELECT *
FROM students
WHERE name LIKE 'A%';        -- begins with A

SELECT *
FROM students
WHERE name LIKE '%a%';       -- contains a

SELECT *
FROM students
WHERE name LIKE '_o%';       -- second character is o

-- PostgreSQL case-insensitive version:
-- WHERE name ILIKE '%alice%';


-- ============================================================================
-- 7. NULL
-- ============================================================================

-- WRONG:
-- WHERE email = NULL

-- Correct
SELECT *
FROM students
WHERE email IS NULL;

SELECT *
FROM students
WHERE email IS NOT NULL;

-- Replace NULL in output
SELECT
    name,
    COALESCE(major, 'Undeclared') AS major
FROM students;


-- ============================================================================
-- 8. SORTING: ORDER BY
-- ============================================================================

SELECT *
FROM students
ORDER BY gpa ASC;

SELECT *
FROM students
ORDER BY gpa DESC;

-- Multiple sorting keys
SELECT *
FROM students
ORDER BY major ASC, gpa DESC;

-- Stable tie-breaking is often useful
SELECT *
FROM students
ORDER BY gpa DESC, student_id ASC;


-- ============================================================================
-- 9. LIMIT / OFFSET
-- ============================================================================

-- First 3 rows after sorting
SELECT *
FROM students
ORDER BY gpa DESC
LIMIT 3;

-- Pagination-style
SELECT *
FROM students
ORDER BY student_id
LIMIT 10 OFFSET 20;

-- SQL Server uses TOP / OFFSET-FETCH instead of LIMIT.


-- ============================================================================
-- 10. UPDATE / MODIFY DATA
-- ============================================================================

-- Update one row
UPDATE students
SET gpa = 4.00
WHERE student_id = 1;

-- Update multiple columns
UPDATE students
SET
    major = 'Data Science',
    active = TRUE
WHERE student_id = 4;

-- Increment / calculate from old value
UPDATE students
SET age = age + 1
WHERE student_id = 2;

-- IMPORTANT:
-- UPDATE without WHERE updates EVERY row.


-- ============================================================================
-- 11. DELETE / REMOVE DATA
-- ============================================================================

-- Delete selected rows
DELETE FROM students
WHERE student_id = 5;

-- Delete rows satisfying condition
DELETE FROM students
WHERE active = FALSE
  AND gpa < 2.0;

-- Remove ALL rows but keep table structure
-- TRUNCATE TABLE students;

-- Remove table entirely
-- DROP TABLE students;


-- ============================================================================
-- 12. ALTER TABLE
-- ============================================================================

-- Add column
ALTER TABLE students
ADD COLUMN graduation_year INTEGER;

-- Rename column (supported by PostgreSQL and many modern DBs)
ALTER TABLE students
RENAME COLUMN graduation_year TO grad_year;

-- Drop column
ALTER TABLE students
DROP COLUMN grad_year;

-- Some ALTER syntax varies substantially by database.


-- ============================================================================
-- 13. COPY / CLONE TABLE DATA
-- ============================================================================

-- Copy table data into a new table
CREATE TABLE cs_students AS
SELECT *
FROM students
WHERE major = 'Computer Science';

-- Copy structure + rows using a condition
CREATE TABLE high_gpa_students AS
SELECT *
FROM students
WHERE gpa >= 3.5;

-- Copy only structure, no rows
CREATE TABLE students_empty_copy AS
SELECT *
FROM students
WHERE 1 = 0;

DROP TABLE cs_students;
DROP TABLE high_gpa_students;
DROP TABLE students_empty_copy;


-- ============================================================================
-- 14. BASIC CALCULATIONS
-- ============================================================================

SELECT
    name,
    gpa,
    gpa * 25 AS approximate_percentage
FROM students;

SELECT
    course_name,
    credits,
    credits * 10 AS workload_units
FROM courses;

-- Arithmetic:
-- + addition
-- - subtraction
-- * multiplication
-- / division
-- % modulo (supported by many DBs)

SELECT
    10 + 5 AS addition,
    10 - 5 AS subtraction,
    10 * 5 AS multiplication,
    10 / 5 AS division,
    10 % 3 AS remainder;


-- ============================================================================
-- 15. AGGREGATE FUNCTIONS
-- ============================================================================

SELECT COUNT(*) AS number_of_students
FROM students;

SELECT COUNT(email) AS students_with_email
FROM students;
-- COUNT(column) ignores NULL.

SELECT AVG(gpa) AS average_gpa
FROM students;

SELECT SUM(credits) AS total_course_credits
FROM courses;

SELECT MIN(gpa) AS minimum_gpa
FROM students;

SELECT MAX(gpa) AS maximum_gpa
FROM students;


-- ============================================================================
-- 16. GROUP BY
-- ============================================================================

SELECT
    major,
    COUNT(*) AS student_count
FROM students
GROUP BY major;

SELECT
    major,
    AVG(gpa) AS average_gpa
FROM students
GROUP BY major;

SELECT
    major,
    COUNT(*) AS student_count,
    AVG(gpa) AS average_gpa,
    MIN(gpa) AS minimum_gpa,
    MAX(gpa) AS maximum_gpa
FROM students
GROUP BY major;


-- ============================================================================
-- 17. HAVING
-- ============================================================================

-- WHERE filters rows BEFORE grouping.
-- HAVING filters groups AFTER grouping.

SELECT
    major,
    AVG(gpa) AS average_gpa
FROM students
WHERE active = TRUE
GROUP BY major
HAVING AVG(gpa) >= 3.5;


-- ============================================================================
-- 18. CASE: IF / ELSE LOGIC
-- ============================================================================

SELECT
    name,
    gpa,
    CASE
        WHEN gpa >= 3.7 THEN 'Excellent'
        WHEN gpa >= 3.0 THEN 'Good'
        WHEN gpa IS NULL THEN 'No GPA'
        ELSE 'Needs Improvement'
    END AS performance
FROM students;

-- CASE can also be used in calculations
SELECT
    name,
    CASE
        WHEN active THEN 1
        ELSE 0
    END AS active_as_integer
FROM students;


-- ============================================================================
-- 19. STRING FUNCTIONS
-- ============================================================================

SELECT
    name,
    UPPER(name) AS uppercase_name,
    LOWER(name) AS lowercase_name,
    LENGTH(name) AS name_length
FROM students;

-- Concatenation: PostgreSQL / SQLite
SELECT
    name || ' - ' || COALESCE(major, 'Undeclared') AS description
FROM students;

-- MySQL commonly uses:
-- CONCAT(name, ' - ', COALESCE(major, 'Undeclared'))


-- ============================================================================
-- 20. NUMERIC FUNCTIONS
-- ============================================================================

SELECT
    gpa,
    ROUND(gpa, 1) AS rounded_gpa
FROM students;

-- Common:
-- ABS(x)
-- ROUND(x, decimals)
-- CEIL(x) / CEILING(x)
-- FLOOR(x)
-- POWER(x, y)
-- SQRT(x)


-- ============================================================================
-- 21. DATE / TIME
-- ============================================================================

SELECT CURRENT_DATE;
SELECT CURRENT_TIME;
SELECT CURRENT_TIMESTAMP;

SELECT
    name,
    created_at
FROM students
WHERE created_at <= CURRENT_TIMESTAMP;

-- Date functions vary a lot by database.
-- PostgreSQL example:
--
-- SELECT created_at + INTERVAL '7 days'
-- FROM students;


-- ============================================================================
-- 22. INNER JOIN
-- ============================================================================

-- Return only matching rows from both tables
SELECT
    s.name,
    c.course_name,
    e.semester,
    e.grade
FROM enrollments e
JOIN students s
    ON e.student_id = s.student_id
JOIN courses c
    ON e.course_id = c.course_id;


-- ============================================================================
-- 23. LEFT JOIN
-- ============================================================================

-- Keep ALL students, even those with no enrollment
SELECT
    s.name,
    c.course_name
FROM students s
LEFT JOIN enrollments e
    ON s.student_id = e.student_id
LEFT JOIN courses c
    ON e.course_id = c.course_id;


-- ============================================================================
-- 24. RIGHT JOIN / FULL OUTER JOIN
-- ============================================================================

-- RIGHT JOIN:
-- Keep every row from the right table.

-- FULL OUTER JOIN:
-- Keep rows from both sides, matched where possible.

-- Example:
--
-- SELECT *
-- FROM students s
-- FULL OUTER JOIN enrollments e
--     ON s.student_id = e.student_id;
--
-- Note: SQLite does not support every join type natively.


-- ============================================================================
-- 25. SELF JOIN
-- ============================================================================

-- Compare rows in the same table.
-- Example: find students with the same major.

SELECT
    a.name AS student_1,
    b.name AS student_2,
    a.major
FROM students a
JOIN students b
    ON a.major = b.major
   AND a.student_id < b.student_id;


-- ============================================================================
-- 26. SUBQUERIES
-- ============================================================================

-- Students above average GPA
SELECT *
FROM students
WHERE gpa > (
    SELECT AVG(gpa)
    FROM students
);

-- IN with subquery
SELECT *
FROM students
WHERE student_id IN (
    SELECT student_id
    FROM enrollments
    WHERE course_id = 101
);


-- ============================================================================
-- 27. EXISTS
-- ============================================================================

-- Students who are enrolled in at least one course
SELECT *
FROM students s
WHERE EXISTS (
    SELECT 1
    FROM enrollments e
    WHERE e.student_id = s.student_id
);

-- Students enrolled in no courses
SELECT *
FROM students s
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments e
    WHERE e.student_id = s.student_id
);


-- ============================================================================
-- 28. CTE: WITH
-- ============================================================================

WITH active_students AS (
    SELECT *
    FROM students
    WHERE active = TRUE
)
SELECT *
FROM active_students
WHERE gpa >= 3.5;


-- Multiple CTEs
WITH
cs_students AS (
    SELECT *
    FROM students
    WHERE major = 'Computer Science'
),
strong_cs_students AS (
    SELECT *
    FROM cs_students
    WHERE gpa >= 3.5
)
SELECT *
FROM strong_cs_students;


-- ============================================================================
-- 29. UNION / UNION ALL / INTERSECT / EXCEPT
-- ============================================================================

-- UNION combines results and removes duplicates.
SELECT name
FROM students
WHERE major = 'Computer Science'

UNION

SELECT name
FROM students
WHERE major = 'Mathematics';


-- UNION ALL keeps duplicates.
SELECT name
FROM students
WHERE active = TRUE

UNION ALL

SELECT name
FROM students
WHERE gpa >= 3.5;


-- INTERSECT = rows appearing in both results
SELECT name
FROM students
WHERE active = TRUE

INTERSECT

SELECT name
FROM students
WHERE gpa >= 3.5;


-- EXCEPT = rows in first query but not second
SELECT name
FROM students

EXCEPT

SELECT name
FROM students
WHERE active = TRUE;


-- ============================================================================
-- 30. WINDOW FUNCTIONS
-- ============================================================================

-- Window functions calculate across related rows WITHOUT collapsing them.

-- Ranking
SELECT
    name,
    major,
    gpa,
    ROW_NUMBER() OVER (
        ORDER BY gpa DESC
    ) AS row_number
FROM students;

SELECT
    name,
    major,
    gpa,
    RANK() OVER (
        ORDER BY gpa DESC
    ) AS gpa_rank
FROM students;

SELECT
    name,
    major,
    gpa,
    DENSE_RANK() OVER (
        ORDER BY gpa DESC
    ) AS dense_gpa_rank
FROM students;


-- Rank inside each major
SELECT
    name,
    major,
    gpa,
    RANK() OVER (
        PARTITION BY major
        ORDER BY gpa DESC
    ) AS rank_within_major
FROM students;


-- Compare with previous / next row
SELECT
    name,
    gpa,
    LAG(gpa) OVER (ORDER BY gpa) AS previous_gpa,
    LEAD(gpa) OVER (ORDER BY gpa) AS next_gpa
FROM students;


-- Running total
SELECT
    course_id,
    credits,
    SUM(credits) OVER (
        ORDER BY course_id
    ) AS running_credits
FROM courses;


-- ============================================================================
-- 31. TOP-N PER GROUP
-- ============================================================================

-- Highest-GPA student in each major

WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY major
            ORDER BY gpa DESC, student_id
        ) AS rn
    FROM students
)
SELECT *
FROM ranked
WHERE rn = 1;


-- ============================================================================
-- 32. CONDITIONAL AGGREGATION
-- ============================================================================

SELECT
    COUNT(*) AS total_students,

    SUM(
        CASE WHEN active = TRUE THEN 1 ELSE 0 END
    ) AS active_students,

    SUM(
        CASE WHEN gpa >= 3.5 THEN 1 ELSE 0 END
    ) AS high_gpa_students
FROM students;


-- ============================================================================
-- 33. CREATE VIEW
-- ============================================================================

CREATE VIEW active_student_summary AS
SELECT
    student_id,
    name,
    major,
    gpa
FROM students
WHERE active = TRUE;

SELECT *
FROM active_student_summary;

DROP VIEW active_student_summary;


-- ============================================================================
-- 34. INDEXES
-- ============================================================================

-- Indexes can speed up searching / filtering / joins,
-- at the cost of extra storage and slower writes.

CREATE INDEX idx_students_major
ON students(major);

CREATE INDEX idx_students_major_gpa
ON students(major, gpa);

DROP INDEX idx_students_major;
DROP INDEX idx_students_major_gpa;


-- ============================================================================
-- 35. CONSTRAINTS
-- ============================================================================

/*
Common constraints:

PRIMARY KEY
    Uniquely identifies a row.

FOREIGN KEY
    Requires a value to reference another table.

UNIQUE
    No duplicate values.

NOT NULL
    Value must exist.

CHECK
    Value must satisfy a condition.

DEFAULT
    Value used when INSERT does not specify one.
*/


-- ============================================================================
-- 36. TRANSACTIONS
-- ============================================================================

-- A transaction lets several operations act as one unit.

BEGIN;

UPDATE students
SET gpa = 3.60
WHERE student_id = 2;

UPDATE students
SET gpa = 3.90
WHERE student_id = 3;

-- Keep changes:
COMMIT;

-- Or cancel:
-- ROLLBACK;


-- ============================================================================
-- 37. INSERT FROM SELECT
-- ============================================================================

CREATE TABLE honors_students AS
SELECT *
FROM students
WHERE 1 = 0;

INSERT INTO honors_students
SELECT *
FROM students
WHERE gpa >= 3.7;

DROP TABLE honors_students;


-- ============================================================================
-- 38. UPSERT
-- ============================================================================

-- PostgreSQL:
--
-- INSERT INTO students (student_id, name, gpa)
-- VALUES (1, 'Alice', 3.95)
-- ON CONFLICT (student_id)
-- DO UPDATE
-- SET
--     name = EXCLUDED.name,
--     gpa = EXCLUDED.gpa;
--
-- MySQL uses INSERT ... ON DUPLICATE KEY UPDATE.
-- SQLite also supports ON CONFLICT.


-- ============================================================================
-- 39. DELETE USING A SUBQUERY
-- ============================================================================

-- Example:
-- DELETE FROM students
-- WHERE student_id IN (
--     SELECT student_id
--     FROM some_inactive_students_table
-- );


-- ============================================================================
-- 40. FIND DUPLICATES
-- ============================================================================

SELECT
    email,
    COUNT(*) AS occurrences
FROM students
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;


-- ============================================================================
-- 41. REMOVE DUPLICATES: GENERAL PATTERN
-- ============================================================================

/*
Usually:
1. Decide what makes rows duplicates.
2. Rank duplicates with ROW_NUMBER().
3. Keep rn = 1, remove rn > 1.

Example PostgreSQL-style idea:

WITH ranked AS (
    SELECT
        student_id,
        ROW_NUMBER() OVER (
            PARTITION BY email
            ORDER BY student_id
        ) AS rn
    FROM students
)
DELETE FROM students
WHERE student_id IN (
    SELECT student_id
    FROM ranked
    WHERE rn > 1
);
*/


-- ============================================================================
-- 42. NULL-SAFE CALCULATIONS
-- ============================================================================

-- NULL propagates:
-- NULL + 10 = NULL

SELECT
    name,
    COALESCE(gpa, 0) * 25 AS percentage
FROM students;


-- ============================================================================
-- 43. COUNTING CORRECTLY
-- ============================================================================

-- All rows
SELECT COUNT(*)
FROM students;

-- Non-NULL GPA values only
SELECT COUNT(gpa)
FROM students;

-- Unique non-NULL majors
SELECT COUNT(DISTINCT major)
FROM students;


-- ============================================================================
-- 44. JOIN + GROUP BY
-- ============================================================================

-- Number of courses each student takes
SELECT
    s.student_id,
    s.name,
    COUNT(e.course_id) AS course_count
FROM students s
LEFT JOIN enrollments e
    ON s.student_id = e.student_id
GROUP BY
    s.student_id,
    s.name
ORDER BY course_count DESC;


-- ============================================================================
-- 45. FILTER AFTER JOIN
-- ============================================================================

-- Students enrolled in CS courses
SELECT DISTINCT
    s.student_id,
    s.name
FROM students s
JOIN enrollments e
    ON s.student_id = e.student_id
JOIN courses c
    ON e.course_id = c.course_id
WHERE c.department = 'CS';


-- ============================================================================
-- 46. ANTI-JOIN: FIND "MISSING" RELATIONSHIPS
-- ============================================================================

-- Students with no enrollment
SELECT
    s.*
FROM students s
LEFT JOIN enrollments e
    ON s.student_id = e.student_id
WHERE e.student_id IS NULL;

-- Often NOT EXISTS is cleaner:
SELECT *
FROM students s
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments e
    WHERE e.student_id = s.student_id
);


-- ============================================================================
-- 47. ALL / ANY
-- ============================================================================

-- PostgreSQL / standard-style examples

-- GPA higher than ALL Math students
SELECT *
FROM students
WHERE gpa > ALL (
    SELECT gpa
    FROM students
    WHERE major = 'Mathematics'
      AND gpa IS NOT NULL
);

-- GPA higher than ANY Math student
SELECT *
FROM students
WHERE gpa > ANY (
    SELECT gpa
    FROM students
    WHERE major = 'Mathematics'
      AND gpa IS NOT NULL
);


-- ============================================================================
-- 48. COMMON QUERY EXECUTION ORDER
-- ============================================================================

/*
Conceptually, SQL roughly evaluates:

    FROM / JOIN --> WHERE --> GROUP BY --> HAVING --> SELECT --> DISTINCT --> ORDER BY --> LIMIT / OFFSET

This explains things like:

    SELECT gpa * 25 AS pct
    FROM students
    WHERE pct > 90;   <-- often INVALID

because WHERE runs before SELECT aliases are created.

Instead:

    SELECT gpa * 25 AS pct
    FROM students
    WHERE gpa * 25 > 90;
*/


-- ============================================================================
-- 49. IMPORTANT NULL LOGIC
-- ============================================================================

/*
SQL uses THREE-VALUED LOGIC:

    TRUE
    FALSE
    UNKNOWN

NULL means "unknown / missing", not zero and not empty string.

Examples:

    NULL = NULL         -> UNKNOWN
    NULL <> 5           -> UNKNOWN
    10 > NULL           -> UNKNOWN

Use:

    IS NULL
    IS NOT NULL
    COALESCE(...)
*/


-- ============================================================================
-- 50. COMMON MISTAKES
-- ============================================================================

/*
1. Forgetting WHERE:

    DELETE FROM students;
    UPDATE students SET gpa = 4.0;

   Both affect every row.


2. Using = NULL:

    WRONG:   email = NULL
    RIGHT:   email IS NULL


3. Mixing WHERE and HAVING:

    WHERE   -> filter rows
    HAVING  -> filter aggregated groups


4. Forgetting JOIN condition:

    SELECT *
    FROM students, courses;

   This creates a Cartesian product.


5. Using INNER JOIN when unmatched rows should survive:

    Use LEFT JOIN.


6. Assuming result order:

    SQL does NOT guarantee ordering unless ORDER BY is used.


7. NOT IN + NULL surprise:

    If the subquery/list contains NULL, NOT IN can behave unexpectedly.
    NOT EXISTS is often safer.


8. SELECT * everywhere:

    Fine for exploration.
    In production code, selecting explicit columns is often clearer
    and more stable.
*/


-- ============================================================================
-- 51. "ARRAY / COLLECTION" ANALOGIES
-- ============================================================================

/*
Typical programming idea          SQL equivalent
-----------------------------------------------------------------------
Create collection                 CREATE TABLE
Append/add item                   INSERT
Find item                         SELECT ... WHERE
Find first N                      SELECT ... LIMIT N
Filter                            WHERE
Map/transform                     SELECT expression
Sort                              ORDER BY
Count                             COUNT
Min / max                         MIN / MAX
Sum                               SUM
Average                           AVG
Group                             GROUP BY
Remove item                       DELETE
Modify item                       UPDATE
Copy                              CREATE TABLE ... AS SELECT
Unique values                     DISTINCT
Contains                          IN / EXISTS
Combine collections               UNION
Match related collections         JOIN
Conditional mapping               CASE
Prefix-style/running calc         window functions
*/


-- ============================================================================
-- 52. MINI REFERENCE: MOST COMMON QUERY TEMPLATE
-- ============================================================================

SELECT
    major,
    COUNT(*) AS student_count,
    AVG(gpa) AS average_gpa
FROM students
WHERE
    active = TRUE
    AND age >= 18
    AND major IS NOT NULL
GROUP BY
    major
HAVING
    COUNT(*) >= 1
ORDER BY
    average_gpa DESC
LIMIT 10;


-- ============================================================================
-- 53. MINI REFERENCE: MOST COMMON JOIN TEMPLATE
-- ============================================================================

SELECT
    s.name,
    c.course_name,
    e.grade
FROM students s
JOIN enrollments e
    ON s.student_id = e.student_id
JOIN courses c
    ON e.course_id = c.course_id
WHERE
    e.semester = 'Fall 2026'
ORDER BY
    s.name,
    c.course_name;


-- ============================================================================
-- 54. MINI REFERENCE: ANALYTICS TEMPLATE
-- ============================================================================

WITH stats AS (
    SELECT
        major,
        COUNT(*) AS n,
        AVG(gpa) AS avg_gpa
    FROM students
    WHERE gpa IS NOT NULL
    GROUP BY major
)
SELECT
    *,
    RANK() OVER (
        ORDER BY avg_gpa DESC
    ) AS major_rank
FROM stats
ORDER BY major_rank;


-- ============================================================================
-- 55. PRACTICAL SQL LEARNING ORDER
-- ============================================================================

/*
Learn these first:

Tier 1 - Everyday SQL
    SELECT
    FROM
    WHERE
    AND / OR / NOT
    ORDER BY
    LIMIT
    INSERT
    UPDATE
    DELETE

Tier 2 - Data analysis
    DISTINCT
    COUNT / SUM / AVG / MIN / MAX
    GROUP BY
    HAVING
    CASE
    NULL / COALESCE

Tier 3 - Relational SQL
    PRIMARY KEY
    FOREIGN KEY
    JOIN
    LEFT JOIN
    EXISTS
    subqueries

Tier 4 - Powerful SQL
    CTEs (WITH)
    UNION / INTERSECT / EXCEPT
    window functions
    transactions
    indexes
    views

Tier 5 - Database-specific / production
    UPSERT
    stored procedures
    triggers
    JSON
    arrays
    recursive CTEs
    query plans / EXPLAIN
    isolation levels
    locks
    permissions
*/


-- ============================================================================
-- END
-- ============================================================================
