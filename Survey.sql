DROP DATABASE IF EXISTS survey;
CREATE DATABASE survey;

USE survey;

-- tables
-- Table: users

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id int  NOT NULL auto_increment,
    user_password varchar(100)  NOT NULL,
    first_name varchar(100)  NOT NULL,
    last_name varchar(100)  NOT NULL,
    email varchar(254)  NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    created datetime  NOT NULL,
    CONSTRAINT user_pk PRIMARY KEY (id)
);


-- Table statusID
DROP TABLE IF EXISTS statuses;
CREATE TABLE statuses (
	id int NOT NULL,
	name varchar(100) NOT NULL,
	created datetime NOT NULL,
	CONSTRAINT statuses_pk PRIMARY KEY (id)
    
);

-- Table: surveys
DROP TABLE IF EXISTS surveys;
CREATE TABLE surveys (
    id int  NOT NULL,
    name varchar(100)  NOT NULL,
    description varchar(1000)  NULL,
    opening_time datetime  NOT NULL,
    closing_time datetime  NOT NULL,
    users_id int  NOT NULL,
	statusID int NOT NULL,
	created datetime NOT NULL,
    CONSTRAINT survey_pk PRIMARY KEY (id),
    CONSTRAINT user_id_fk FOREIGN KEY (users_id) REFERENCES users(id),
	CONSTRAINT sruvey_status_id FOREIGN KEY (statusID) REFERENCES statuses(id)
    
);

-- Table: question_type
DROP TABLE IF EXISTS question_type;
CREATE TABLE question_type (
    id int  NOT NULL,
    name varchar(30)  NOT NULL,
	created datetime NOT NULL,
    CONSTRAINT question_type_pk PRIMARY KEY (id)
);

DROP TABLE IF EXISTS question;
CREATE TABLE question (
    id int  NOT NULL,
    text varchar(1000)  NOT NULL,
    description varchar(1000),
    question_type_id int  NOT NULL,
    created datetime NOT NULL,
    CONSTRAINT question_pk PRIMARY KEY (id),
    CONSTRAINT question_type_id_fk FOREIGN KEY(question_type_id) REFERENCES question_type(id)
);

-- Table: response_choice
DROP TABLE IF EXISTS response_choice;
CREATE TABLE response_choice (
    id int  NOT NULL,
    question_id int  NOT NULL,
    text varchar(1000)  NOT NULL,
	created datetime NOT NULL,
    CONSTRAINT response_choice_pk PRIMARY KEY (id),
    CONSTRAINT question_id_fk FOREIGN KEY (question_id) REFERENCES question(id)
);

-- Table: question_order
DROP TABLE IF EXISTS question_order;
CREATE TABLE question_order (
    id int  NOT NULL,
    question_id int  NOT NULL,
    survey_id int  NOT NULL,
    CONSTRAINT question_order_pk PRIMARY KEY (id),
    CONSTRAINT question_order_question_id_fk FOREIGN KEY (question_id) REFERENCES question(id),
    CONSTRAINT question_order_survey_id_fk FOREIGN KEY (survey_id) REFERENCES surveys(id)
);


-- Table: respondent
DROP TABLE IF EXISTS respondent;
CREATE TABLE respondent (
    id int  NOT NULL,
    first_name varchar(100)  NULL,
    last_name varchar(100)  NULL,
    email varchar(254)  NULL,
    created datetime  NOT NULL,
    CONSTRAINT respondent_pk PRIMARY KEY (id)
);

-- Table: survey_response
DROP TABLE IF EXISTS survey_response;
CREATE TABLE survey_response (
    id int  NOT NULL,
    survey_id int  NOT NULL,
    respondent_id int  NOT NULL,
	created datetime NOT NULL,
    CONSTRAINT survey_response_pk PRIMARY KEY (id),
    CONSTRAINT survey_id_fk FOREIGN KEY (survey_id) REFERENCES surveys(id),
    CONSTRAINT respondent_id_fk FOREIGN KEY (respondent_id) REFERENCES respondent(id)
);

-- Table: response
DROP TABLE IF EXISTS response;
CREATE TABLE response (
    survey_response_id INT NOT NULL,
    question_id INT NOT NULL,
    respondent_id INT NOT NULL,
    answer VARCHAR(1000) NOT NULL,
	created datetime NOT NULL,
    CONSTRAINT response_pk PRIMARY KEY (survey_response_id , question_id , respondent_id),
    CONSTRAINT survey_response_id_fk FOREIGN KEY (survey_response_id) REFERENCES survey_response (id),
    CONSTRAINT survey_response_question_id_fk FOREIGN KEY (question_id) REFERENCES question (id),
    CONSTRAINT survey_response_respondent_fk FOREIGN KEY (respondent_id) REFERENCES respondent (id)
);

-- End of Database setup

-- Start Create views
-- Create a VIEW with the first name, last name, email, and phone number of all users who create more than ten surveys.
CREATE VIEW users_gt10 AS 
	SELECT
		u.first_name,
		u.last_name,
		u.email,
		u.phone_number
	FROM
		users u
		INNER JOIN surveys s ON u.id = s.users_id
	GROUP BY
		u.id,
		u.first_name,
		u.last_name,
		u.email,
		u.phone_number
	HAVING
		COUNT(s.id) > 10;

-- Create a VIEW showing all the surveys with more than ten responses.
CREATE VIEW surveys_gt10_responses AS
	SELECT
		s.id AS survey_id,
		s.name AS survey_name,
		s.description AS survey_description,
		COUNT(sr.id) AS response_count
	FROM
		surveys s
		INNER JOIN survey_response sr ON s.id = sr.survey_id
	GROUP BY
		s.id,
		s.name,
		s.description
	HAVING
		COUNT(sr.id) > 10;
-- Create view for more than 10 questions
CREATE VIEW surveys_gt10_questions AS
SELECT s.*
FROM surveys s
JOIN (
    SELECT survey_id, COUNT(question_id) as question_count
    FROM question_order
    GROUP BY survey_id
) qo ON s.id = qo.survey_id
WHERE qo.question_count > 10;

-- Insert removed and deleted statuses
INSERT INTO statuses (id, name, created)
VALUES (4, 'Removed', '2022-01-01 00:00:00'),
       (5, 'Deleted', '2022-01-01 00:00:00');

-- Create view for removed or deleted surveys
CREATE VIEW removed_deleted_surveys AS
SELECT *
FROM surveys
WHERE statusID IN (4, 5);

-- End Create Views
-- Inserting dummy data

INSERT INTO users (id, user_password, first_name, last_name, email, phone_number, created)
VALUES (1, 'password123', 'John', 'Doe', 'john.doe@example.com', '123-456-7890', '2022-01-01 00:00:00');

INSERT INTO statuses (id, name, created)
VALUES (1, 'Draft', '2022-01-01 00:00:00');

INSERT INTO surveys (id, name, description, opening_time, closing_time, users_id, statusID, created)
VALUES (1, 'Sample Survey', 'This is a sample survey.', '2022-01-10 00:00:00', '2022-01-20 23:59:59', 1, 1, '2022-01-01 00:00:00');

INSERT INTO question_type (id, name, created)
VALUES (1, 'Single Choice', '2022-01-01 00:00:00');

INSERT INTO question (id, text, question_type_id, created)
VALUES (1, 'What is your favorite color?', 1, '2022-01-01 00:00:00');

INSERT INTO response_choice (id, question_id, text, created)
VALUES (1, 1, 'Red', '2022-01-01 00:00:00');

INSERT INTO question_order (id, question_id, survey_id)
VALUES (1, 1, 1);

INSERT INTO respondent (id, first_name, last_name, email, created)
VALUES (1, 'Jane', 'Doe', 'jane.doe@example.com', '2022-01-10 00:00:00');

INSERT INTO survey_response (id, survey_id, respondent_id, created)
VALUES (1, 1, 1, '2022-01-10 00:00:00');

INSERT INTO response (survey_response_id, question_id, respondent_id, answer, created)
VALUES (1, 1, 1, 'Red', '2022-01-10 00:00:00');

INSERT INTO users (id, user_password, first_name, last_name, email, phone_number, created)
VALUES (2, 'password456', 'Alice', 'Smith', 'alice.smith@example.com', '234-567-8901', '2022-02-01 00:00:00');

INSERT INTO statuses (id, name, created)
VALUES (2, 'Published', '2022-02-01 00:00:00');

INSERT INTO surveys (id, name, description, opening_time, closing_time, users_id, statusID, created)
VALUES (2, 'Another Survey', 'This is another sample survey.', '2022-02-10 00:00:00', '2022-02-20 23:59:59', 2, 2, '2022-02-01 00:00:00');

INSERT INTO question_type (id, name, created)
VALUES (2, 'Multiple Choice', '2022-02-01 00:00:00');

INSERT INTO question (id, text, question_type_id, created)
VALUES (2, 'Which of the following fruits do you like?', 2, '2022-02-01 00:00:00');

INSERT INTO response_choice (id, question_id, text, created)
VALUES (2, 2, 'Apple', '2022-02-01 00:00:00');

INSERT INTO question_order (id, question_id, survey_id)
VALUES (2, 2, 2);

INSERT INTO respondent (id, first_name, last_name, email, created)
VALUES (2, 'Bob', 'Johnson', 'bob.johnson@example.com', '2022-02-10 00:00:00');

INSERT INTO survey_response (id, survey_id, respondent_id, created)
VALUES (2, 2, 2, '2022-02-10 00:00:00');

INSERT INTO response (survey_response_id, question_id, respondent_id, answer, created)
VALUES (2, 2, 2, 'Apple', '2022-02-10 00:00:00');

INSERT INTO users (id, user_password, first_name, last_name, email, phone_number, created)
VALUES (3, 'password789', 'Charlie', 'Brown', 'charlie.brown@example.com', '345-678-9012', '2022-03-01 00:00:00');

INSERT INTO statuses (id, name, created)
VALUES (3, 'Closed', '2022-03-01 00:00:00');

INSERT INTO surveys (id, name, description, opening_time, closing_time, users_id, statusID, created)
VALUES (3, 'Third Survey', 'This is a third sample survey.', '2022-03-10 00:00:00', '2022-03-20 23:59:59', 3, 3, '2022-03-01 00:00:00');

INSERT INTO question_type (id, name, created)
VALUES (3, 'Open-ended', '2022-03-01 00:00:00');

INSERT INTO question (id, text, question_type_id, created)
VALUES (3, 'What is your favorite hobby?', 3, '2022-03-01 00:00:00');

INSERT INTO response_choice (id, question_id, text, created)
VALUES (3, 3, 'Not applicable for open-ended questions', '2022-03-01 00:00:00');

INSERT INTO question_order (id, question_id, survey_id)
VALUES (3, 3, 3);

INSERT INTO respondent (id, first_name, last_name, email, created)
VALUES (3, 'Lucy', 'Van Pelt', 'lucy.vanpelt@example.com', '2022-03-10 00:00:00');

INSERT INTO survey_response (id, survey_id, respondent_id, created)
VALUES (3, 3, 3, '2022-03-10 00:00:00');

INSERT INTO response (survey_response_id, question_id, respondent_id, answer, created)
VALUES (3, 3, 3, 'Reading books', '2022-03-10 00:00:00');

-- End of insertion
-- Adding multiple question answers to question type
INSERT INTO question_type (id, name, created)
VALUES (4, 'Multiple Answers', '2022-01-01 00:00:00'),
       (5, 'Multiple Choice', '2022-01-01 00:00:00'),
       (6, 'Yes/No', '2022-01-01 00:00:00'),
       (7, 'Essay', '2022-01-01 00:00:00');
-- End of question adding
-- End of file.

