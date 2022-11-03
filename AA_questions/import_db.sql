PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS users;

CREATE TABLE users(
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions(
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    author_id INTEGER NOT NULL,

    FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows(
    id INTEGER PRIMARY KEY,
    follower_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (follower_id) REFERENCES users(id)
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;
 
CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    parent_reply_id INTEGER,
    question_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL,
    reply_body TEXT NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id)
    FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    users_id INTEGER,

    FOREIGN KEY (question_id) REFERENCES questions(id)
    FOREIGN KEY (users_id) REFERENCES users(id)
);

INSERT INTO 
    users (fname, lname)
VALUES
    ('Ligma', 'Nuts'),
    ('Suggon', 'Deez'),
    ('Dragon', 'Deezballs'),
    ('Innocent', 'Bystander'),
    ('Natty', 'Kwon'),
    ('Rex', 'Kho');

INSERT INTO 
    questions (title, body, author_id)
VALUES
    ('What is?', 'I dont know what ligma means.', (SELECT id FROM users WHERE fname = 'Innocent')),
    ('How to?', 'Drag deez nuts on your face?', (SELECT id FROM users WHERE fname = 'Dragon')),
    ('Risotto?', 'How to make risotto?', (SELECT id FROM users WHERE fname = 'Natty')),
    ('Pork Belly?', 'Pls help me make pork belly?', (SELECT id FROM users WHERE fname = 'Natty'));

INSERT INTO
    replies (reply_body, question_id, author_id, parent_reply_id)
VALUES
    ('Hi, you fell for it lol', (SELECT id FROM questions WHERE title = 'How to?'), (SELECT id FROM users WHERE fname = 'Ligma'), NULL),
    ('First you cook onion and mushrooms.', (SELECT id FROM questions WHERE title = 'Risotto?'), (SELECT id FROM users WHERE fname = 'Rex'), NULL);

INSERT INTO
    replies (reply_body, question_id, author_id, parent_reply_id)
VALUES
    ('Then you cover mixture with rice.', (SELECT id FROM questions WHERE title = 'Risotto?'), (SELECT id FROM users WHERE fname = 'Ligma'), (SELECT id FROM replies WHERE id = 2));

INSERT INTO
    replies (reply_body, question_id, author_id, parent_reply_id)
VALUES
    ('Then pour wine to cook rice.', (SELECT id FROM questions WHERE title = 'Risotto?'), (SELECT id FROM users WHERE fname = 'Rex'), (SELECT id FROM replies WHERE id = 3));

INSERT INTO
    replies (reply_body, question_id, author_id, parent_reply_id)
VALUES
    ('Grate parmesan and mix.', (SELECT id FROM questions WHERE title = 'Risotto?'), (SELECT id FROM users WHERE fname = 'Innocent'), (SELECT id FROM replies WHERE id = 4));
    
INSERT INTO
    question_likes (question_id, users_id)
VALUES
    ((SELECT id FROM questions WHERE title = 'How to?'), (SELECT id FROM users WHERE lname = 'Deez')),
    ((SELECT id FROM questions WHERE title = 'How to?'), (SELECT id FROM users WHERE lname = 'Nuts')),
    ((SELECT id FROM questions WHERE title = 'How to?'), (SELECT id FROM users WHERE lname = 'Deezballs')),
    ((SELECT id FROM questions WHERE title = 'How to?'), (SELECT id FROM users WHERE lname = 'Kwon')),
    ((SELECT id FROM questions WHERE title = 'How to?'), (SELECT id FROM users WHERE lname = 'Kho'));

INSERT INTO
    question_follows (follower_id, question_id)
VALUES
    ((SELECT id FROM users WHERE fname = 'Ligma'), (SELECT id FROM questions WHERE id = 2)),
    ((SELECT id FROM users WHERE fname = 'Suggon'), (SELECT id FROM questions WHERE id = 2)),
    ((SELECT id FROM users WHERE fname = 'Dragon'), (SELECT id FROM questions WHERE id = 2)),
    ((SELECT id FROM users WHERE fname = 'Natty'), (SELECT id FROM questions WHERE id = 2)),
    ((SELECT id FROM users WHERE fname = 'Rex'), (SELECT id FROM questions WHERE id = 2));




