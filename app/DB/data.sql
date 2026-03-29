CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    content VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO messages (content) VALUES ('Hello from Docker');
INSERT INTO messages (content) VALUES ('This is going to be great b*tches!');
INSERT INTO messages (content) VALUES ('I love DevOps');
INSERT INTO messages (content) VALUES ('Hola Mundo!');
