CREATE TABLE IF NOT EXISTS simulation_submissions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    identifier VARCHAR(255) NULL,
    campaign_id VARCHAR(100) NULL,
    participant_id VARCHAR(100) NULL,
    landing_id VARCHAR(100) NULL,
    source VARCHAR(100) NULL,
    submitted_password TINYINT(1) NOT NULL DEFAULT 0,
    password_length SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    password_revealed TINYINT(1) NOT NULL DEFAULT 0,
    ip_hash CHAR(64) NULL,
    user_agent VARCHAR(512) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_created_at (created_at),
    INDEX idx_identifier (identifier),
    INDEX idx_campaign_id (campaign_id),
    INDEX idx_participant_id (participant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE simulation_submissions
    ADD COLUMN IF NOT EXISTS campaign_id VARCHAR(100) NULL AFTER identifier,
    ADD COLUMN IF NOT EXISTS participant_id VARCHAR(100) NULL AFTER campaign_id,
    ADD COLUMN IF NOT EXISTS landing_id VARCHAR(100) NULL AFTER participant_id,
    ADD COLUMN IF NOT EXISTS source VARCHAR(100) NULL AFTER landing_id,
    ADD COLUMN IF NOT EXISTS password_revealed TINYINT(1) NOT NULL DEFAULT 0 AFTER password_length,
    ADD INDEX IF NOT EXISTS idx_campaign_id (campaign_id),
    ADD INDEX IF NOT EXISTS idx_participant_id (participant_id);
