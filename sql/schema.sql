CREATE TABLE IF NOT EXISTS `ban` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `serverip` varchar(32) NOT NULL,
  `bantype` varchar(32) NOT NULL,
  `reason` mediumtext NOT NULL,
  `job` varchar(32) DEFAULT NULL,
  `duration` int(11) NOT NULL,
  `rounds` int(11) DEFAULT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `ip` varchar(32) NOT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `a_ip` varchar(32) NOT NULL,
  `who` mediumtext NOT NULL,
  `adminwho` mediumtext NOT NULL,
  `edits` mediumtext DEFAULT NULL,
  `unbanned` tinyint(1) DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_ip` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`),
  KEY `computerid` (`computerid`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `budget` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  `ckey` varchar(32) DEFAULT NULL,
  `amount` int(10) unsigned NOT NULL,
  `source` varchar(32) NOT NULL,
  `date_start` datetime NOT NULL DEFAULT current_timestamp(),
  `date_end` datetime DEFAULT (current_timestamp() + interval 1 month),
  `is_valid` tinyint(1) NOT NULL DEFAULT 1,
  `discord_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ckey_whitelist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  `ckey` varchar(32) NOT NULL,
  `adminwho` varchar(32) NOT NULL,
  `port` int(5) unsigned NOT NULL,
  `date_start` datetime NOT NULL DEFAULT current_timestamp(),
  `date_end` datetime DEFAULT NULL,
  `is_valid` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `erro_admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `rank` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Administrator',
  `level` int(2) NOT NULL DEFAULT 0,
  `flags` int(16) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `ckey` (`ckey`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `erro_admin_tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assignee` text DEFAULT NULL,
  `ckey` varchar(32) NOT NULL,
  `text` text DEFAULT NULL,
  `status` enum('OPEN','CLOSED','SOLVED','TIMED_OUT') NOT NULL,
  `round` varchar(32) DEFAULT NULL,
  `inround_id` int(11) DEFAULT NULL,
  `open_date` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `erro_connection_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime DEFAULT NULL,
  `serverip` text DEFAULT NULL,
  `server_port` int(5) unsigned NOT NULL,
  `ckey` text DEFAULT NULL,
  `ip` text DEFAULT NULL,
  `computerid` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`(768))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `erro_player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` text NOT NULL,
  `firstseen` datetime DEFAULT NULL,
  `lastseen` datetime DEFAULT NULL,
  `ip` text DEFAULT NULL,
  `computerid` text DEFAULT NULL,
  `lastadminrank` text DEFAULT NULL,
  `staffwarn` text DEFAULT NULL,
  `discord_id` varchar(32) DEFAULT NULL,
  `discord_name` varchar(32) DEFAULT NULL,
  `exp` text DEFAULT NULL,
  `species_exp` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`(768)),
  KEY `ckey_2` (`ckey`(768)),
  KEY `ip` (`ip`(768)),
  KEY `computerid` (`computerid`(768))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `erro_playtime_history` (
  `ckey` varchar(32) NOT NULL,
  `date` date NOT NULL,
  `time_living` int(32) NOT NULL DEFAULT 0,
  `time_ghost` int(32) NOT NULL DEFAULT 0,
  PRIMARY KEY (`ckey`,`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `library` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` text DEFAULT NULL,
  `title` text DEFAULT NULL,
  `author` text DEFAULT NULL,
  `content` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `title` (`title`(768)),
  KEY `author` (`author`(768)),
  KEY `category` (`category`(768))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `whitelist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` text NOT NULL,
  `race` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`(768)),
  KEY `race` (`race`(768))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
