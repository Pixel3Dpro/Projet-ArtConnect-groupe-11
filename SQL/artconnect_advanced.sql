-- ============================================================
-- ArtConnect -- Fonctionnalites avancees
-- TI603 Bases de Données 2 -- EFREI Paris
-- ============================================================

USE artconnect;

-- ============================================================
-- INDEX
-- ============================================================

CREATE INDEX idx_artwork_artist    ON ARTWORK(id_artist);
CREATE INDEX idx_artwork_status    ON ARTWORK(status);
CREATE INDEX idx_exhibition_gallery ON EXHIBITION(id_gallery);
CREATE INDEX idx_booking_workshop  ON BOOKING(id_workshop);
CREATE INDEX idx_booking_member    ON BOOKING(id_member);
CREATE INDEX idx_review_artwork    ON REVIEW(id_artwork);
CREATE INDEX idx_artist_city       ON ARTIST(city);

-- ============================================================
-- VUES
-- ============================================================

-- Vue 1 : Catalogue public des oeuvres (masque les infos artiste privees)
CREATE VIEW v_artwork_catalog AS
SELECT
    a.id_artwork,
    a.title,
    a.type,
    a.price,
    a.status,
    ar.name AS artist_name,
    ar.city AS artist_city,
    ROUND(AVG(r.rating), 1) AS avg_rating,
    COUNT(DISTINCT r.id_member) AS review_count
FROM ARTWORK a
JOIN ARTIST ar ON a.id_artist = ar.id_artist
LEFT JOIN REVIEW r ON a.id_artwork = r.id_artwork
GROUP BY a.id_artwork, a.title, a.type, a.price, a.status, ar.name, ar.city;

-- Vue 2 : Expositions en cours ou a venir (masque contact galerie)
CREATE VIEW v_upcoming_exhibitions AS
SELECT
    e.id_exhibition,
    e.title,
    e.startDate,
    e.endDate,
    e.theme,
    e.curatorName,
    g.name AS gallery_name,
    g.address AS gallery_address
FROM EXHIBITION e
JOIN GALLERY g ON e.id_gallery = g.id_gallery
WHERE e.endDate >= CURDATE();

-- Vue 3 : Taux de remplissage des ateliers en temps reel
CREATE VIEW v_workshop_availability AS
SELECT
    w.id_workshop,
    w.title,
    w.date,
    w.level,
    w.price,
    w.maxParticipants,
    COUNT(CASE WHEN b.paymentStatus != 'CANCELLED' THEN 1 END) AS confirmed_bookings,
    w.maxParticipants - COUNT(CASE WHEN b.paymentStatus != 'CANCELLED' THEN 1 END) AS places_left,
    ROUND(COUNT(CASE WHEN b.paymentStatus != 'CANCELLED' THEN 1 END) * 100.0 / w.maxParticipants, 1) AS fill_rate_pct
FROM WORKSHOP w
LEFT JOIN BOOKING b ON w.id_workshop = b.id_workshop
GROUP BY w.id_workshop, w.title, w.date, w.level, w.price, w.maxParticipants;

-- Vue 4 : Resume artiste (sans email ni telephone)
CREATE VIEW v_artist_summary AS
SELECT
    ar.id_artist,
    ar.name,
    ar.city,
    ar.isActive,
    COUNT(DISTINCT a.id_artwork) AS total_artworks,
    COUNT(DISTINCT CASE WHEN a.status = 'SOLD' THEN a.id_artwork END) AS artworks_sold,
    GROUP_CONCAT(DISTINCT d.name_discipline ORDER BY d.name_discipline SEPARATOR ', ') AS disciplines
FROM ARTIST ar
LEFT JOIN ARTWORK a ON ar.id_artist = a.id_artist
LEFT JOIN ARTIST_DISCIPLINE ad ON ar.id_artist = ad.id_artist
LEFT JOIN DISCIPLINE d ON ad.name_discipline = d.name_discipline
GROUP BY ar.id_artist, ar.name, ar.city, ar.isActive;

-- ============================================================
-- TRIGGERS
-- ============================================================

DELIMITER $$

-- Trigger 1 : Verifier que l atelier n est pas complet avant une reservation
CREATE TRIGGER trg_before_booking_insert
BEFORE INSERT ON BOOKING
FOR EACH ROW
BEGIN
    DECLARE current_count INT;
    DECLARE max_part INT;
    SELECT COUNT(*) INTO current_count
    FROM BOOKING
    WHERE id_workshop = NEW.id_workshop AND paymentStatus != 'CANCELLED';
    SELECT maxParticipants INTO max_part
    FROM WORKSHOP WHERE id_workshop = NEW.id_workshop;
    IF current_count >= max_part THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Atelier complet : nombre maximum de participants atteint.';
    END IF;
END$$

-- Trigger 2 : Verifier la coherence des dates d exposition
CREATE TRIGGER trg_before_exhibition_insert
BEFORE INSERT ON EXHIBITION
FOR EACH ROW
BEGIN
    IF NEW.endDate <= NEW.startDate THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La date de fin doit etre posterieure a la date de debut.';
    END IF;
END$$

-- Trigger 3 : Meme verification lors d une mise a jour d exposition
CREATE TRIGGER trg_before_exhibition_update
BEFORE UPDATE ON EXHIBITION
FOR EACH ROW
BEGIN
    IF NEW.endDate <= NEW.startDate THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La date de fin doit etre posterieure a la date de debut.';
    END IF;
END$$

-- Trigger 4 : Passer une oeuvre en EXHIBITED quand elle est ajoutee a une exposition
CREATE TRIGGER trg_after_exhibition_artwork_insert
AFTER INSERT ON EXHIBITION_ARTWORK
FOR EACH ROW
BEGIN
    UPDATE ARTWORK SET status = 'EXHIBITED'
    WHERE id_artwork = NEW.id_artwork AND status = 'FOR_SALE';
END$$

-- Trigger 5 : Restaurer FOR_SALE si l oeuvre n est plus dans aucune exposition
CREATE TRIGGER trg_after_exhibition_artwork_delete
AFTER DELETE ON EXHIBITION_ARTWORK
FOR EACH ROW
BEGIN
    DECLARE remaining INT;
    SELECT COUNT(*) INTO remaining
    FROM EXHIBITION_ARTWORK WHERE id_artwork = OLD.id_artwork;
    IF remaining = 0 THEN
        UPDATE ARTWORK SET status = 'FOR_SALE'
        WHERE id_artwork = OLD.id_artwork AND status = 'EXHIBITED';
    END IF;
END$$

-- Trigger 6 : Verifier que la note d un avis est entre 1 et 5
CREATE TRIGGER trg_before_review_insert
BEFORE INSERT ON REVIEW
FOR EACH ROW
BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La note doit etre comprise entre 1 et 5.';
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- FONCTIONS STOCKEES
-- ============================================================

DELIMITER $$

-- Fonction 1 : Nombre de participants confirmes a un atelier
CREATE FUNCTION fn_workshop_participant_count(p_workshop_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE cnt INT;
    SELECT COUNT(*) INTO cnt
    FROM BOOKING
    WHERE id_workshop = p_workshop_id AND paymentStatus != 'CANCELLED';
    RETURN cnt;
END$$

-- Fonction 2 : Revenus totaux d un artiste (oeuvres vendues)
CREATE FUNCTION fn_artist_revenue(p_artist_id INT)
RETURNS DECIMAL(15,2)
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(15,2);
    SELECT COALESCE(SUM(price), 0) INTO total
    FROM ARTWORK
    WHERE id_artist = p_artist_id AND status = 'SOLD';
    RETURN total;
END$$

-- Fonction 3 : Verifier si un membre peut encore s inscrire a un atelier
CREATE FUNCTION fn_can_book(p_workshop_id INT, p_member_id INT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE already_booked INT;
    DECLARE places_left INT;
    SELECT COUNT(*) INTO already_booked
    FROM BOOKING WHERE id_workshop = p_workshop_id AND id_member = p_member_id;
    SELECT (maxParticipants - fn_workshop_participant_count(p_workshop_id)) INTO places_left
    FROM WORKSHOP WHERE id_workshop = p_workshop_id;
    IF already_booked > 0 OR places_left <= 0 THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END$$

DELIMITER ;

-- ============================================================
-- PROCEDURES STOCKEES
-- ============================================================

DELIMITER $$

-- Procedure 1 : Inscription atomique d un membre a plusieurs ateliers
CREATE PROCEDURE sp_bulk_register_member(
    IN p_member_id INT,
    IN p_workshop_ids VARCHAR(255),
    OUT p_success INT,
    OUT p_errors TEXT
)
BEGIN
    DECLARE v_id INT;
    DECLARE v_pos INT DEFAULT 1;
    DECLARE v_len INT;
    SET p_success = 0;
    SET p_errors = '';
    START TRANSACTION;
    SET v_len = LENGTH(p_workshop_ids) - LENGTH(REPLACE(p_workshop_ids, ',', '')) + 1;
    loop_label: LOOP
        IF v_pos > v_len THEN LEAVE loop_label; END IF;
        SET v_id = CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_workshop_ids, ',', v_pos), ',', -1)) AS UNSIGNED);
        IF fn_can_book(v_id, p_member_id) THEN
            INSERT INTO BOOKING (id_workshop, id_member, bookingDate, paymentStatus)
            VALUES (v_id, p_member_id, NOW(), 'PENDING');
            SET p_success = p_success + 1;
        ELSE
            SET p_errors = CONCAT(p_errors, 'Atelier ', v_id, ' indisponible. ');
        END IF;
        SET v_pos = v_pos + 1;
    END LOOP;
    COMMIT;
END$$

-- Procedure 2 : Creer une exposition et associer des oeuvres (atomique)
CREATE PROCEDURE sp_create_exhibition_with_artworks(
    IN p_title VARCHAR(255),
    IN p_startDate DATE,
    IN p_endDate DATE,
    IN p_gallery_id INT,
    IN p_curator VARCHAR(150),
    IN p_theme VARCHAR(150),
    IN p_artwork_ids VARCHAR(255)
)
BEGIN
    DECLARE v_exhibition_id INT;
    DECLARE v_artwork_id INT;
    DECLARE v_pos INT DEFAULT 1;
    DECLARE v_len INT;
    DECLARE v_count INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;
    START TRANSACTION;
    INSERT INTO EXHIBITION (title, startDate, endDate, curatorName, theme, id_gallery)
    VALUES (p_title, p_startDate, p_endDate, p_curator, p_theme, p_gallery_id);
    SET v_exhibition_id = LAST_INSERT_ID();
    SET v_len = LENGTH(p_artwork_ids) - LENGTH(REPLACE(p_artwork_ids, ',', '')) + 1;
    loop_label: LOOP
        IF v_pos > v_len THEN LEAVE loop_label; END IF;
        SET v_artwork_id = CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_artwork_ids, ',', v_pos), ',', -1)) AS UNSIGNED);
        SELECT COUNT(*) INTO v_count FROM ARTWORK WHERE id_artwork = v_artwork_id;
        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Oeuvre introuvable, transaction annulee.';
        END IF;
        INSERT INTO EXHIBITION_ARTWORK VALUES (v_exhibition_id, v_artwork_id);
        SET v_pos = v_pos + 1;
    END LOOP;
    COMMIT;
END$$

-- Procedure 3 : Creer un atelier et inscrire automatiquement l instructeur si membre
CREATE PROCEDURE sp_create_workshop_and_register(
    IN p_title VARCHAR(255),
    IN p_date DATETIME,
    IN p_duration INT,
    IN p_max INT,
    IN p_price DECIMAL(10,2),
    IN p_location VARCHAR(300),
    IN p_desc TEXT,
    IN p_level VARCHAR(30),
    IN p_artist_id INT
)
BEGIN
    DECLARE v_workshop_id INT;
    DECLARE v_member_id INT DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;
    START TRANSACTION;
    INSERT INTO WORKSHOP (title, date, durationMinutes, maxParticipants, price, location, description, level, id_artist)
    VALUES (p_title, p_date, p_duration, p_max, p_price, p_location, p_desc, p_level, p_artist_id);
    SET v_workshop_id = LAST_INSERT_ID();
    SELECT id_member INTO v_member_id
    FROM COMMUNITY_MEMBER cm
    JOIN ARTIST a ON cm.email = a.contactEmail
    WHERE a.id_artist = p_artist_id LIMIT 1;
    IF v_member_id IS NOT NULL THEN
        INSERT INTO BOOKING (id_workshop, id_member, bookingDate, paymentStatus)
        VALUES (v_workshop_id, v_member_id, NOW(), 'PAID');
    END IF;
    COMMIT;
END$$

DELIMITER ;

-- ============================================================
-- SCRIPTS DE TEST DES TRANSACTIONS
-- ============================================================

-- Scenario 1 : Inscription atomique a plusieurs ateliers
CALL sp_bulk_register_member(8, '1,2,3', @success, @errors);
SELECT @success AS inscriptions_reussies, @errors AS messages_erreur;

-- Scenario 2 : Tentative d inscription sur atelier complet (doit echouer via trigger)
-- L atelier 3 a maxParticipants=6, on force l erreur
START TRANSACTION;
    INSERT INTO BOOKING (id_workshop, id_member, bookingDate, paymentStatus)
    VALUES (3, 5, NOW(), 'PENDING');
COMMIT;

-- Scenario 3 : Creation exposition avec oeuvres (atomique)
CALL sp_create_exhibition_with_artworks(
    'Hiver Artistique', '2026-01-10', '2026-03-15',
    2, 'Claire Dupuis', 'Hivernale',
    '2,6,9'
);

-- Scenario 4 : Vente d une oeuvre (UPDATE + retrait exposition si applicable)
START TRANSACTION;
    UPDATE ARTWORK SET status = 'SOLD' WHERE id_artwork = 6;
    DELETE FROM EXHIBITION_ARTWORK WHERE id_artwork = 6;
COMMIT;

-- Scenario 5 : Rollback sur date d exposition invalide (end <= start)
START TRANSACTION;
    INSERT INTO EXHIBITION (title, startDate, endDate, curatorName, theme, id_gallery)
    VALUES ('Expo Invalide', '2026-05-01', '2026-04-01', 'Test', 'Test', 1);
ROLLBACK;

-- Scenario 6 : Test des vues et fonctions
SELECT * FROM v_artwork_catalog;
SELECT * FROM v_upcoming_exhibitions;
SELECT * FROM v_workshop_availability;
SELECT fn_workshop_participant_count(1) AS participants_atelier_1;
SELECT fn_artist_revenue(1) AS revenus_clara_voss;
SELECT fn_can_book(1, 3) AS membre3_peut_reserver_atelier1;
