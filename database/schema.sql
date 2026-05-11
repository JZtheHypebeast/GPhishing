CREATE TABLE IF NOT EXISTS simulation_submissions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    identifier VARCHAR(255) NULL,
    submitted_password TINYINT(1) NOT NULL DEFAULT 0,
    password_length SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    ip_hash CHAR(64) NULL,
    user_agent VARCHAR(512) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_created_at (created_at),
    INDEX idx_identifier (identifier)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
