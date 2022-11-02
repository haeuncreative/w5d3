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


    FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
    FOREIGN KEY (question_id) REFERENCES questions(id)
    FOREIGN KEY (author_id) REFERENCES user(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    users_id INTEGER,

    FOREIGN KEY (question_id) REFERENCES questions(id)
    FOREIGN KEY (users_id) REFERENCES user(id)
);

INSERT INTO 
    users (fname, lname)
VALUES
    ('Ligma', 'Nuts'),
    ('Suggon', 'Deez'),
    ('Dragon', 'Deezballs'),
    ('Innocent', 'Bystander');

INSERT INTO 
    questions (title, body, author_id)
VALUES
    ('What is?', 'I dont know what ligma means.', (SELECT id FROM users WHERE fname = 'Innocent')),
    ('How to?', 'Drag deez nuts on your face?', (SELECT id FROM users WHERE fname = 'Dragon'));

INSERT INTO
    replies (reply_body, question_id, author_id)
VALUES
    ('Hi, you fell for it lol',(SELECT id FROM questions WHERE title = 'How to?'),
     (SELECT id FROM users WHERE fname = 'Ligma'));

INSERT INTO
    question_likes (question_id, users_id)
VALUES
    ((SELECT id FROM questions WHERE title = 'How to?'), (SELECT id FROM users WHERE lname = 'Deez'));




