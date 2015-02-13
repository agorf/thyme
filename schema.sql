CREATE TABLE `sets` (
  `id` integer NOT NULL PRIMARY KEY,
  `thumb_photo_id` integer UNIQUE REFERENCES `photos`,
  `name` varchar(4096) NOT NULL UNIQUE,
  `photos_count` integer,
  `taken_at` datetime
);

CREATE INDEX `sets_thumb_photo_id_index` ON `sets` (`thumb_photo_id`);

CREATE TABLE `photos` (
  `id` integer NOT NULL PRIMARY KEY,
  `set_id` integer NOT NULL REFERENCES `sets`,
  `prev_photo_id` integer UNIQUE REFERENCES `photos`,
  `next_photo_id` integer UNIQUE REFERENCES `photos`,
  `path` varchar(4096) NOT NULL UNIQUE,
  `identifier` char(32) NOT NULL UNIQUE,
  `size` integer NOT NULL,
  `width` integer NOT NULL,
  `height` integer NOT NULL,
  `aperture` decimal(2, 1),
  `camera` varchar(1000),
  `exposure_comp` integer,
  `exposure_time` decimal(9, 5),
  `flash` varchar(51),
  `focal_length` decimal(3, 1),
  `focal_length_35` integer,
  `iso` integer,
  `lat` decimal(9, 6),
  `lens` varchar(1000),
  `lng` decimal(9, 6),
  `taken_at` datetime
);

CREATE INDEX `photos_set_id_index` ON `photos` (`set_id`);
CREATE INDEX `photos_prev_photo_id_index` ON `photos` (`prev_photo_id`);
CREATE INDEX `photos_next_photo_id_index` ON `photos` (`next_photo_id`);
