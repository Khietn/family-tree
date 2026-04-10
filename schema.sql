-- ============================================================
-- Family Tree Database Schema
-- Compatible with: SQLite / MySQL / PostgreSQL
-- ============================================================

-- -----------------------------------------------------------
-- PERSONS: Core table storing every individual in the tree
-- -----------------------------------------------------------
CREATE TABLE persons (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name      VARCHAR(100)  NOT NULL,
    last_name       VARCHAR(100)  NOT NULL,
    maiden_name     VARCHAR(100),
    gender          VARCHAR(10)   CHECK (gender IN ('male', 'female', 'other')),
    date_of_birth   DATE,
    place_of_birth  VARCHAR(255),
    date_of_death   DATE,
    place_of_death  VARCHAR(255),
    bio             TEXT,
    photo_url       VARCHAR(500),
    created_at      DATETIME      DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------
-- RELATIONSHIPS: Junction table linking two persons
--   type = 'parent_child' → person1_id is the PARENT, person2_id is the CHILD
--   type = 'spouse'       → person1_id & person2_id are married/partners
-- -----------------------------------------------------------
CREATE TABLE relationships (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    person1_id      INTEGER       NOT NULL,
    person2_id      INTEGER       NOT NULL,
    relationship_type VARCHAR(20) NOT NULL
                    CHECK (relationship_type IN ('parent_child', 'spouse', 'sibling', 'adopted')),
    start_date      DATE,
    end_date        DATE,
    notes           TEXT,
    created_at      DATETIME      DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (person1_id) REFERENCES persons(id) ON DELETE CASCADE,
    FOREIGN KEY (person2_id) REFERENCES persons(id) ON DELETE CASCADE,
    UNIQUE (person1_id, person2_id, relationship_type)
);

-- -----------------------------------------------------------
-- EVENTS: Life events tied to one or more persons
-- -----------------------------------------------------------
CREATE TABLE events (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    person_id       INTEGER       NOT NULL,
    event_type      VARCHAR(50)   NOT NULL
                    CHECK (event_type IN ('birth', 'death', 'marriage', 'divorce',
                                          'graduation', 'immigration', 'other')),
    event_date      DATE,
    event_place     VARCHAR(255),
    description     TEXT,
    created_at      DATETIME      DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE
);

-- -----------------------------------------------------------
-- MEDIA: Photos, documents, and files attached to persons
-- -----------------------------------------------------------
CREATE TABLE media (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    person_id       INTEGER       NOT NULL,
    media_type      VARCHAR(20)   NOT NULL
                    CHECK (media_type IN ('photo', 'document', 'video', 'audio')),
    file_url        VARCHAR(500)  NOT NULL,
    title           VARCHAR(255),
    description     TEXT,
    date_taken      DATE,
    created_at      DATETIME      DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE
);

-- ============================================================
-- INDEXES for query performance
-- ============================================================
CREATE INDEX idx_persons_name       ON persons (last_name, first_name);
CREATE INDEX idx_rel_person1        ON relationships (person1_id);
CREATE INDEX idx_rel_person2        ON relationships (person2_id);
CREATE INDEX idx_rel_type           ON relationships (relationship_type);
CREATE INDEX idx_events_person      ON events (person_id);
CREATE INDEX idx_events_type        ON events (event_type);
CREATE INDEX idx_media_person       ON media (person_id);

-- ============================================================
-- SAMPLE DATA: A 3-generation family
-- ============================================================

-- Generation 1 (Grandparents)
INSERT INTO persons (id, first_name, last_name, gender, date_of_birth, place_of_birth, date_of_death)
VALUES
  (1, 'James',    'Smith', 'male',   '1940-03-15', 'London, UK',    '2015-11-20'),
  (2, 'Margaret', 'Smith', 'female', '1942-07-22', 'Edinburgh, UK', NULL);

INSERT INTO relationships (person1_id, person2_id, relationship_type, start_date)
VALUES (1, 2, 'spouse', '1963-06-10');

-- Generation 2 (Parents & Siblings)
INSERT INTO persons (id, first_name, last_name, gender, date_of_birth, place_of_birth)
VALUES
  (3, 'Robert',   'Smith',   'male',   '1965-01-10', 'London, UK'),
  (4, 'Susan',    'Smith',   'female', '1968-09-05', 'Manchester, UK'),
  (5, 'Linda',    'Johnson', 'female', '1967-04-18', 'Bristol, UK');

-- Parents → Children
INSERT INTO relationships (person1_id, person2_id, relationship_type) VALUES
  (1, 3, 'parent_child'),
  (2, 3, 'parent_child'),
  (1, 4, 'parent_child'),
  (2, 4, 'parent_child');

-- Robert & Linda married
INSERT INTO relationships (person1_id, person2_id, relationship_type, start_date)
VALUES (3, 5, 'spouse', '1990-08-25');

-- Generation 3 (Grandchildren)
INSERT INTO persons (id, first_name, last_name, gender, date_of_birth, place_of_birth)
VALUES
  (6, 'Emily',   'Smith', 'female', '1993-12-01', 'London, UK'),
  (7, 'Michael', 'Smith', 'male',   '1996-06-15', 'London, UK');

INSERT INTO relationships (person1_id, person2_id, relationship_type) VALUES
  (3, 6, 'parent_child'),
  (5, 6, 'parent_child'),
  (3, 7, 'parent_child'),
  (5, 7, 'parent_child');

-- Sample events
INSERT INTO events (person_id, event_type, event_date, event_place, description) VALUES
  (1, 'birth',      '1940-03-15', 'London, UK',      'Born at St Thomas Hospital'),
  (1, 'marriage',   '1963-06-10', 'London, UK',      'Married Margaret at Westminster'),
  (1, 'death',      '2015-11-20', 'London, UK',      'Passed away peacefully'),
  (3, 'birth',      '1965-01-10', 'London, UK',      'Born at Royal London Hospital'),
  (3, 'marriage',   '1990-08-25', 'Bristol, UK',     'Married Linda'),
  (6, 'birth',      '1993-12-01', 'London, UK',      'Born at UCH'),
  (6, 'graduation', '2015-07-10', 'Cambridge, UK',   'Graduated from Cambridge University');
