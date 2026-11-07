CREATE TABLE IF NOT EXISTS `users` (
	`user_id` BIGINT AUTO_INCREMENT,
	`username` VARCHAR(100) NOT NULL,
	`email` VARCHAR(255) NOT NULL UNIQUE,
	`password_hash` VARCHAR(255) NOT NULL,
	`created_at` DATETIME,
	`updated_at` DATETIME,
	PRIMARY KEY(`user_id`)
);


CREATE TABLE IF NOT EXISTS `user_sessions` (
	`session_id` BIGINT AUTO_INCREMENT,
	`user_id` BIGINT NOT NULL,
	`token_hash` VARCHAR(255) NOT NULL UNIQUE,
	`expires_at` DATETIME NOT NULL,
	`created_at` DATETIME,
	PRIMARY KEY(`session_id`)
);


CREATE TABLE IF NOT EXISTS `poems` (
	`poem_id` VARCHAR(50),
	`poem_name` VARCHAR(255) NOT NULL,
	`file_path` VARCHAR(255) NOT NULL,
	`created_at` DATETIME,
	PRIMARY KEY(`poem_id`)
);


CREATE TABLE IF NOT EXISTS `audio_records` (
	`audio_id` BIGINT AUTO_INCREMENT,
	`user_id` BIGINT NOT NULL,
	`poem_id` VARCHAR(50) NOT NULL,
	`file_path` VARCHAR(255) NOT NULL,
	`duration` INTEGER,
	`created_at` DATETIME,
	PRIMARY KEY(`audio_id`)
);


CREATE TABLE IF NOT EXISTS `analysis_jobs` (
	`job_id` BIGINT AUTO_INCREMENT,
	`audio_id` BIGINT NOT NULL,
	`status` ENUM('Pending', 'Processing', 'Completed', 'Failed') NOT NULL DEFAULT 'Pending',
	`error_message` TEXT,
	`attempt_count` INTEGER DEFAULT 0,
	`created_at` DATETIME,
	`started_at` DATETIME,
	`completed_at` DATETIME,
	PRIMARY KEY(`job_id`)
);


CREATE TABLE IF NOT EXISTS `analysis_results` (
	`result_id` BIGINT AUTO_INCREMENT,
	`job_id` BIGINT NOT NULL UNIQUE,
	`overall_score` DECIMAL(6,2),
	`pitch_score` DECIMAL(6,2),
	`duration_score` DECIMAL(6,2),
	`pause_score` DECIMAL(6,2),
	`raw_result` JSON,
	`created_at` DATETIME,
	PRIMARY KEY(`result_id`)
);


CREATE TABLE IF NOT EXISTS `analysis_feedback` (
	`feedback_id` BIGINT NOT NULL AUTO_INCREMENT,
	`result_id` BIGINT NOT NULL,
	`rank` INTEGER,
	`type` VARCHAR(50) NOT NULL,
	`severity` VARCHAR(20) NOT NULL,
	`syllable` VARCHAR(100),
	`stanza` INTEGER,
	`verse` INTEGER,
	`value` FLOAT,
	`threshold` FLOAT,
	`time_range` JSON,
	`message` TEXT,
	`action` TEXT,
	`syllable_index` BIGINT,
	PRIMARY KEY(`feedback_id`)
);


CREATE INDEX `analysis_feedback_index_0`
ON `analysis_feedback` (`result_id`);
ALTER TABLE `user_sessions`
ADD FOREIGN KEY(`user_id`) REFERENCES `users`(`user_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `audio_records`
ADD FOREIGN KEY(`user_id`) REFERENCES `users`(`user_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `audio_records`
ADD FOREIGN KEY(`poem_id`) REFERENCES `poems`(`poem_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `analysis_jobs`
ADD FOREIGN KEY(`audio_id`) REFERENCES `audio_records`(`audio_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `analysis_results`
ADD FOREIGN KEY(`job_id`) REFERENCES `analysis_jobs`(`job_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `analysis_feedback`
ADD FOREIGN KEY(`result_id`) REFERENCES `analysis_results`(`result_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;