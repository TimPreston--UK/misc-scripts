CREATE TABLE stats (
    id INTEGER PRIMARY KEY,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    key VARCHAR,
    value VARCHAR
);
