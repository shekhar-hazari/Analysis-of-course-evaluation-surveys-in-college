----------------- Data Normalization---------------------------
CREATE TABLE STAFFINFO AS
SELECT DISTINCT STAFFID, AGE, BEAUTY, GENDER, TENURETRACK, NONENGLISH
FROM PROFEVALUATIONS;

CREATE TABLE COURSEINFO AS
SELECT ID, DIVISION, STUDENTS, COURSEEVALUATION, STAFFID
FROM PROFEVALUATIONS;

ALTER TABLE COURSEINFO
ADD PRIMARY KEY (ID);

ALTER TABLE STAFFINFO
ADD PRIMARY KEY (STAFFID);

ALTER TABLE COURSEINFO
ADD FOREIGN KEY (STAFFID) REFERENCES STAFFINFO(STAFFID);

-----------------Summary of  Number of students in a course-----------------

SELECT 'NUMBER_OF_STUDENTS', MIN(STUDENTS) AS MINIMUM, ROUND(AVG(STUDENTS),2) AS MEAN, MAX(STUDENTS) AS MAXIMUM
FROM COURSEINFO;

----------------Analysis of number of students (course size) and Course Evaluation Score----------------------
    
SELECT
	CASE
		WHEN STUDENTS <= 18 THEN '18 OR LESS'
		WHEN STUDENTS >= 19 AND STUDENTS <= 28 THEN '19 - 28'
		WHEN STUDENTS >= 29 AND STUDENTS <= 60 THEN '29 - 60'
		WHEN STUDENTS >= 61 THEN '61 OR MORE'
	END AS "COURSE SIZE",
	COUNT(COURSEEVALUATION) "NUMBER OF COURSES IN GROUP",
	MIN(COURSEEVALUATION) "MINIMUM COURSE EVALUATION SCORE",
	ROUND(AVG(COURSEEVALUATION),2) "MEAN COURSE EVALUATION SCORE",
	MAX(COURSEEVALUATION) "MAXIMUM COURSE EVALUATION SCORE"
FROM COURSEINFO
GROUP BY
	CASE
		WHEN STUDENTS <= 18 THEN '18 OR LESS'
		WHEN STUDENTS >= 19 AND STUDENTS <= 28 THEN '19 - 28'
		WHEN STUDENTS >= 29 AND STUDENTS <= 60 THEN '29 - 60'
		WHEN STUDENTS >= 61 THEN '61 OR MORE'
	END
ORDER BY
	CASE
		WHEN STUDENTS <= 18 THEN '18 OR LESS'
		WHEN STUDENTS >= 19 AND STUDENTS <= 28 THEN '19 - 28'
		WHEN STUDENTS >= 29 AND STUDENTS <= 60 THEN '29 - 60'
		WHEN STUDENTS >= 61 THEN '61 OR MORE'
	END;

--------------------Analysis of number of courses by division and their course evaluation score-------------------------------
SELECT DIVISION, COUNT(ID) "NO. COURSES IN GROUP", MIN(COURSEEVALUATION) "MINIMUM", ROUND(AVG(COURSEEVALUATION),2) "MEAN", MAX(COURSEEVALUATION) "MAXIMUM"
FROM COURSEINFO
GROUP BY DIVISION;

-------------------- Analysis of gender of course instructors and course evaluation scores-------------------------------
SELECT STAFFINFO.GENDER, COUNT(COURSEINFO.ID) "NO. COURSES IN GROUP", MIN(COURSEINFO.COURSEEVALUATION) "MINIMUM", ROUND(AVG(COURSEINFO.COURSEEVALUATION),2) "MEAN", MAX(COURSEINFO.COURSEEVALUATION) "MAXIMUM"
FROM STAFFINFO, COURSEINFO
WHERE STAFFINFO.STAFFID = COURSEINFO.STAFFID
GROUP BY STAFFINFO.GENDER;

-------------------- Analysis of beauty score of instructors and course evaluation score -----------------------------
SELECT
	GENDER,
	COUNT(STAFFID) "NO. ACADEMICS IN GROUP",
	ROUND(MIN(BEAUTY),2) "MINIMUM",
	ROUND(AVG(BEAUTY),2) "MEAN",
	ROUND(MAX(BEAUTY),2) "MAXIMUM"
FROM STAFFINFO
GROUP BY GENDER;

-------------------- Analysis of tenure track of instructors and course evaluation scores-------------------------------
SELECT
	STAFFINFO.TENURETRACK,
	COUNT(DISTINCT STAFFINFO.STAFFID) "NO. ACADEMICS IN GROUP",
	ROUND(MIN(COURSEINFO.COURSEEVALUATION),2) "MINIMUM",
	ROUND(AVG(COURSEINFO.COURSEEVALUATION),2) "MEAN",
	ROUND(MAX(COURSEINFO.COURSEEVALUATION),2) "MAXIMUM"
FROM STAFFINFO, COURSEINFO
WHERE STAFFINFO.STAFFID = COURSEINFO.STAFFID
GROUP BY STAFFINFO.TENURETRACK;

-------------------- Analysis of education background of instructors and course evaluation scores-------------------------------
SELECT
	STAFFINFO.NONENGLISH,
	COUNT(DISTINCT STAFFINFO.STAFFID) "NO. ACADEMICS IN GROUP",
	ROUND(MIN(COURSEINFO.COURSEEVALUATION),2) "MINIMUM",
	ROUND(AVG(COURSEINFO.COURSEEVALUATION),2) "MEAN",
	ROUND(MAX(COURSEINFO.COURSEEVALUATION),2) "MAXIMUM"
FROM STAFFINFO, COURSEINFO
WHERE STAFFINFO.STAFFID = COURSEINFO.STAFFID
GROUP BY STAFFINFO.NONENGLISH;

------------------- Analysis of Interactions between Tenure Track, Gender and Education Background --------------------------------
SELECT
	STAFFINFO.TENURETRACK "TENURE TRACK",
	STAFFINFO.GENDER "GENDER",
	STAFFINFO.NONENGLISH "EDUCATION",
	COUNT(DISTINCT STAFFINFO.STAFFID) "NO. ACADEMICS IN GROUP",
	ROUND(AVG(COURSEINFO.COURSEEVALUATION),2) "MEAN"
FROM STAFFINFO, COURSEINFO
WHERE STAFFINFO.STAFFID = COURSEINFO.STAFFID
GROUP BY
	STAFFINFO.TENURETRACK,
	STAFFINFO.GENDER,
	STAFFINFO.NONENGLISH;
----------------------------------------------------------------Correlation-----------------------------------------------------
-----------------------------------------------------Course Evaluation and correlation------------------------------------------
CREATE VIEW PART1 AS
	SELECT
		'CORRELATION COEFFICIENT' AS "CORRELATION COEFFICIENT",
		ROUND(CORR_S(COURSEEVALUATION, STUDENTS),5) AS "COURSE EVALUATION SCORE AND COURSE SIZE"
	FROM COURSEINFO
	UNION
	SELECT
		'TWO-SIDED SIGNIFICANCE' AS "TWO-SIDED SIGNIFICANCE",
		ROUND(CORR_S(COURSEEVALUATION, STUDENTS, 'TWO_SIDED_SIG'),5) AS "COURSE EVALUATION SCORE AND COURSE SIZE"
	FROM COURSEINFO;

--------------------------------------------------------Age and Beauty----------------------------------------------------------
CREATE VIEW PART2 AS
	SELECT
		'CORRELATION COEFFICIENT' AS "CORRELATION COEFFICIENT",
		ROUND(CORR_S(AGE, BEAUTY),5) AS "STAFF AGE AND BEAUTY"
	FROM STAFFINFO
	UNION
	SELECT
		'TWO-SIDED SIGNIFICANCE' AS "TWO-SIDED SIGNIFICANCE",
		ROUND(CORR_S(AGE, BEAUTY, 'TWO_SIDED_SIG'),5) AS "STAFF AGE AND BEAUTY"
	FROM STAFFINFO;

-------------------------------------------------------Age and Average course evaluation score----------------------------------

DROP VIEW TEMP;

CREATE VIEW TEMP AS
	SELECT
		STAFFINFO.AGE AS STAFF_AGE,
		AVG(COURSEEVALUATION) AS AVG_COURSE_EVALUATION
	FROM STAFFINFO, COURSEINFO
	WHERE STAFFINFO.STAFFID = COURSEINFO.STAFFID
	GROUP BY STAFFINFO.AGE;

CREATE VIEW PART3 AS
	SELECT
		'CORRELATION COEFFICIENT' AS "CORRELATION COEFFICIENT",
		ROUND(CORR_S(STAFF_AGE, AVG_COURSE_EVALUATION),5) AS "STAFF AGE AND MEAN COURSE EVALUATION SCORE"
	FROM TEMP
	UNION
	SELECT
		'TWO-SIDED SIGNIFICANCE' AS "TWO-SIDED SIGNIFICANCE",
		ROUND(CORR_S(STAFF_AGE, AVG_COURSE_EVALUATION, 'TWO_SIDED_SIG'),5) AS "STAFF AGE AND MEAN COURSE EVALUATION SCORE"
	FROM TEMP;
--------------------------------------------Beauty and Average course evaluation score------------------------------------------

DROP VIEW TEMP2;

CREATE VIEW TEMP2 AS
	SELECT
		STAFFINFO.BEAUTY AS STAFF_BEAUTY,
		AVG(COURSEEVALUATION) AS AVG_COURSE_EVALUATION
	FROM STAFFINFO, COURSEINFO
	WHERE STAFFINFO.STAFFID = COURSEINFO.STAFFID
	GROUP BY STAFFINFO.BEAUTY;

CREATE VIEW PART4 AS
	SELECT
		'CORRELATION COEFFICIENT' AS "CORRELATION COEFFICIENT",
		ROUND(CORR_S(STAFF_BEAUTY, AVG_COURSE_EVALUATION),5) AS "STAFF BEAUTY AND MEAN COURSE EVALUATION SCORE"
	FROM TEMP2
	UNION
	SELECT
		'TWO-SIDED SIGNIFICANCE' AS "TWO-SIDED SIGNIFICANCE",
	ROUND(CORR_S(STAFF_BEAUTY, AVG_COURSE_EVALUATION, 'TWO_SIDED_SIG'),5) AS "STAFF BEAUTY AND MEAN COURSE EVALUATION SCORE"
	FROM TEMP2;

/*Bringing all parts together*/
SELECT *
FROM (PART1 NATURAL JOIN PART2) NATURAL JOIN (PART3 NATURAL JOIN PART4);