CREATE TABLE IF NOT EXISTS simulation_submissions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    identifier VARCHAR(255) NULL,
    submitted_password TINYINT(1) NOT NULL DEFAULT 0,
    password_length SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    password_revealed TINYINT(1) NOT NULL DEFAULT 0,
    browser_agent VARCHAR(512) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_created_at (created_at),
    INDEX idx_identifier (identifier)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE simulation_submissions
    ADD COLUMN IF NOT EXISTS password_revealed TINYINT(1) NOT NULL DEFAULT 0 AFTER password_length,
    ADD COLUMN IF NOT EXISTS browser_agent VARCHAR(512) NULL AFTER password_revealed;

ALTER TABLE simulation_submissions
    DROP INDEX IF EXISTS idx_campaign_id,
    DROP INDEX IF EXISTS idx_participant_id,
    DROP COLUMN IF EXISTS campaign_id,
    DROP COLUMN IF EXISTS participant_id,
    DROP COLUMN IF EXISTS landing_id,
    DROP COLUMN IF EXISTS source,
    DROP COLUMN IF EXISTS ip_hash,
    DROP COLUMN IF EXISTS user_agent;
