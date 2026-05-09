CREATE DATABASE IF NOT EXISTS artconnect;
USE artconnect;

CREATE TABLE DISCIPLINE (
  name_discipline VARCHAR(50) PRIMARY KEY
);

CREATE TABLE ARTWORK_TAG (
  name_tag VARCHAR(50) PRIMARY KEY
);

CREATE TABLE ARTIST (
  id_artist    INT AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(150) NOT NULL,
  bio          TEXT,
  birthYear    INT,
  contactEmail VARCHAR(150) UNIQUE,
  phone        VARCHAR(30),
  city         VARCHAR(100),
  website      VARCHAR(255),
  socialMedia  VARCHAR(255),
  isActive     BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE ARTIST_DISCIPLINE (
  id_artist       INT NOT NULL,
  name_discipline VARCHAR(50) NOT NULL,
  PRIMARY KEY (id_artist, name_discipline),
  FOREIGN KEY (id_artist)       REFERENCES ARTIST(id_artist)         ON DELETE CASCADE,
  FOREIGN KEY (name_discipline) REFERENCES DISCIPLINE(name_discipline) ON DELETE CASCADE
);

CREATE TABLE GALLERY (
  id_gallery   INT AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(200) NOT NULL,
  address      VARCHAR(300) NOT NULL,
  ownerName    VARCHAR(150),
  openingHours VARCHAR(100),
  contactPhone VARCHAR(30),
  rating       DECIMAL(3,1),
  website      VARCHAR(255)
);

CREATE TABLE ARTWORK (
  id_artwork   INT AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(255) NOT NULL,
  creationYear INT,
  type         VARCHAR(80) NOT NULL,
  medium       VARCHAR(150),
  dimensions   VARCHAR(100),
  description  TEXT,
  price        DECIMAL(15,2),
  status       ENUM('FOR_SALE','SOLD','EXHIBITED') NOT NULL,
  id_artist    INT NOT NULL,
  FOREIGN KEY (id_artist) REFERENCES ARTIST(id_artist) ON DELETE RESTRICT
);

CREATE TABLE ARTWORK_TAG_LINK (
  id_artwork INT NOT NULL,
  name_tag   VARCHAR(50) NOT NULL,
  PRIMARY KEY (id_artwork, name_tag),
  FOREIGN KEY (id_artwork) REFERENCES ARTWORK(id_artwork)    ON DELETE CASCADE,
  FOREIGN KEY (name_tag)   REFERENCES ARTWORK_TAG(name_tag)  ON DELETE CASCADE
);

CREATE TABLE EXHIBITION (
  id_exhibition INT AUTO_INCREMENT PRIMARY KEY,
  title         VARCHAR(255) NOT NULL,
  startDate     DATE NOT NULL,
  endDate       DATE,
  description   TEXT,
  curatorName   VARCHAR(150),
  theme         VARCHAR(150),
  id_gallery    INT NOT NULL,
  FOREIGN KEY (id_gallery) REFERENCES GALLERY(id_gallery) ON DELETE RESTRICT
);

CREATE TABLE EXHIBITION_ARTWORK (
  id_exhibition INT NOT NULL,
  id_artwork    INT NOT NULL,
  PRIMARY KEY (id_exhibition, id_artwork),
  FOREIGN KEY (id_exhibition) REFERENCES EXHIBITION(id_exhibition) ON DELETE CASCADE,
  FOREIGN KEY (id_artwork)    REFERENCES ARTWORK(id_artwork)        ON DELETE CASCADE
);

CREATE TABLE WORKSHOP (
  id_workshop     INT AUTO_INCREMENT PRIMARY KEY,
  title           VARCHAR(255) NOT NULL,
  date            DATETIME NOT NULL,
  durationMinutes INT,
  maxParticipants INT,
  price           DECIMAL(10,2),
  location        VARCHAR(300),
  description     TEXT,
  level           VARCHAR(30),
  id_artist       INT NOT NULL,
  FOREIGN KEY (id_artist) REFERENCES ARTIST(id_artist) ON DELETE RESTRICT
);

CREATE TABLE COMMUNITY_MEMBER (
  id_member      INT AUTO_INCREMENT PRIMARY KEY,
  name           VARCHAR(150) NOT NULL,
  email          VARCHAR(200) NOT NULL UNIQUE,
  birthYear      INT,
  phone          VARCHAR(30),
  city           VARCHAR(100),
  membershipType VARCHAR(50)
);

CREATE TABLE MEMBER_DISCIPLINE (
  id_member       INT NOT NULL,
  name_discipline VARCHAR(50) NOT NULL,
  PRIMARY KEY (id_member, name_discipline),
  FOREIGN KEY (id_member)       REFERENCES COMMUNITY_MEMBER(id_member)    ON DELETE CASCADE,
  FOREIGN KEY (name_discipline) REFERENCES DISCIPLINE(name_discipline)     ON DELETE CASCADE
);

CREATE TABLE BOOKING (
  id_workshop   INT NOT NULL,
  id_member     INT NOT NULL,
  bookingDate   DATETIME,
  paymentStatus VARCHAR(50),
  PRIMARY KEY (id_workshop, id_member),
  FOREIGN KEY (id_workshop) REFERENCES WORKSHOP(id_workshop)         ON DELETE CASCADE,
  FOREIGN KEY (id_member)   REFERENCES COMMUNITY_MEMBER(id_member)   ON DELETE CASCADE
);

CREATE TABLE REVIEW (
  id_artwork  INT NOT NULL,
  id_member   INT NOT NULL,
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  reviewDate  DATE,
  PRIMARY KEY (id_artwork, id_member),
  FOREIGN KEY (id_artwork) REFERENCES ARTWORK(id_artwork)           ON DELETE CASCADE,
  FOREIGN KEY (id_member)  REFERENCES COMMUNITY_MEMBER(id_member)   ON DELETE CASCADE
);
