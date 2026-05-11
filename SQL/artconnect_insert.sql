-- ============================================================
-- ArtConnect -- Données d'exemple
-- TI603 Bases de Données 2 -- EFREI Paris
-- ============================================================

USE artconnect;

-- DISCIPLINES
INSERT INTO DISCIPLINE VALUES
('Peinture'), ('Sculpture'), ('Photographie'),
('Art numerique'), ('Gravure'), ('Musique'), ('Illustration'), ('Ceramique');

-- ARTWORK_TAG
INSERT INTO ARTWORK_TAG VALUES
('abstrait'), ('contemporain'), ('figuratif'), ('urbain'),
('nature'), ('minimaliste'), ('expressionniste'), ('vintage');

-- ARTIST
INSERT INTO ARTIST (name, bio, birthYear, contactEmail, phone, city, website, socialMedia, isActive) VALUES
('Clara Voss', 'Peintre expressionniste parisienne, connue pour ses toiles colorees.', 1985, 'clara.voss@mail.fr', '0612345678', 'Paris', 'claravoss.fr', '@claravoss', TRUE),
('Ines Khalid', 'Photographe documentaire basee a Marseille.', 1990, 'ines.khalid@mail.fr', '0623456789', 'Marseille', 'ineskhalid.com', '@ineskhalid', TRUE),
('Marc Dupont', 'Sculpteur specialise dans le bois recycle.', 1978, 'marc.dupont@mail.fr', '0634567890', 'Lyon', 'marcdupont.fr', '@marcdupont', TRUE),
('Sofia Reyes', 'Illustratrice et artiste numerique.', 1995, 'sofia.reyes@mail.fr', '0645678901', 'Bordeaux', 'sofiareyes.io', '@sofiareyes', TRUE),
('Julien Moreau', 'Graveur et ceramiste, expose dans toute l Europe.', 1980, 'julien.moreau@mail.fr', '0656789012', 'Nantes', 'julienmoreau.art', '@julienmoreau', TRUE),
('Amina Bousser', 'Peintre abstraite, lauréate du Prix Emergences 2022.', 1992, 'amina.bousser@mail.fr', '0667890123', 'Paris', 'aminabousser.fr', '@aminabousser', TRUE);

-- ARTIST_DISCIPLINE
INSERT INTO ARTIST_DISCIPLINE VALUES
(1,'Peinture'),(1,'Illustration'),
(2,'Photographie'),
(3,'Sculpture'),(3,'Ceramique'),
(4,'Art numerique'),(4,'Illustration'),
(5,'Gravure'),(5,'Ceramique'),
(6,'Peinture'),(6,'Art numerique');

-- GALLERY
INSERT INTO GALLERY (name, address, ownerName, openingHours, contactPhone, rating, website) VALUES
('Galerie Lumiere', '12 rue de la Paix, Paris', 'Henri Blanc', 'Mar-Sam 10h-19h', '0142000001', 4.8, 'galerielumiere.fr'),
('Espace Contemporain', '5 av. Victor Hugo, Lyon', 'Marie Ledoux', 'Mer-Dim 11h-18h', '0478000002', 4.5, 'espacecontemporain.fr'),
('Atelier des Arts', '88 cours Julien, Marseille', 'Karim Nassif', 'Lun-Ven 9h-17h', '0491000003', 4.2, 'atelierdesarts.fr'),
('Centre Creatif', '3 rue des Artisans, Bordeaux', 'Lucie Martin', 'Mar-Dim 10h-20h', '0556000004', 4.6, 'centrecreatif.fr');

-- ARTWORK
INSERT INTO ARTWORK (title, creationYear, type, medium, dimensions, description, price, status, id_artist) VALUES
('Eclats de Paris', 2021, 'Peinture', 'Huile sur toile', '80x100cm', 'Serie de toiles sur la vie parisienne.', 2200.00, 'FOR_SALE', 1),
('Lumiere d automne', 2022, 'Peinture', 'Acrylique', '60x80cm', 'Paysage automnal expressionniste.', 1500.00, 'FOR_SALE', 1),
('Marseille Intime', 2020, 'Photographie', 'Tirage argentique', '40x60cm', 'Portrait documentaire du quartier du Panier.', 800.00, 'SOLD', 2),
('Silences Urbains', 2023, 'Photographie', 'Impression pigmentaire', '50x70cm', 'Vides architecturaux de la ville moderne.', 950.00, 'FOR_SALE', 2),
('Torsion No.3', 2019, 'Sculpture', 'Bois recycle', '40x40x90cm', 'Sculpture en bois de chene recycle.', 3400.00, 'EXHIBITED', 3),
('Ancrage', 2021, 'Sculpture', 'Ceramique et metal', '30x30x60cm', 'Ceramique et metal, equilibre et tension.', 2800.00, 'FOR_SALE', 3),
('Flux Numerique', 2023, 'Art numerique', 'Impression UV sur aluminium', '70x100cm', 'Generatif, serie limitee a 10 exemplaires.', 1200.00, 'FOR_SALE', 4),
('Portrait Glitch', 2022, 'Art numerique', 'Impression UV', '50x70cm', 'Exploration de l identite numerique.', 900.00, 'SOLD', 4),
('Empreinte Verte', 2020, 'Gravure', 'Eau-forte sur cuivre', '30x40cm', 'Nature et ecologie, serie de 5 gravures.', 650.00, 'FOR_SALE', 5),
('Aplat Rouge', 2023, 'Peinture', 'Huile sur lin', '120x150cm', 'Grand format abstrait, rouge dominant.', 4100.00, 'EXHIBITED', 6);

-- ARTWORK_TAG_LINK
INSERT INTO ARTWORK_TAG_LINK VALUES
(1,'urbain'),(1,'expressionniste'),
(2,'nature'),(2,'expressionniste'),
(3,'figuratif'),(3,'vintage'),
(4,'urbain'),(4,'minimaliste'),
(5,'abstrait'),(5,'contemporain'),
(6,'contemporain'),
(7,'abstrait'),(7,'numerique' ),
(8,'figuratif'),
(9,'nature'),(9,'vintage'),
(10,'abstrait'),(10,'expressionniste');

-- EXHIBITION
INSERT INTO EXHIBITION (title, startDate, endDate, description, curatorName, theme, id_gallery) VALUES
('Eclats Parisiens', '2025-03-01', '2025-04-30', 'Exposition collective autour de la vie parisienne.', 'Sophie Marchand', 'Vie urbaine', 1),
('Formes et Matieres', '2025-05-10', '2025-07-15', 'Sculptures et ceramiques contemporaines.', 'Paul Renard', 'Sculpture contemporaine', 2),
('Regards Croises', '2025-06-01', '2025-08-31', 'Photographie documentaire et sociale.', 'Leila Amrani', 'Photographie sociale', 3),
('Numerique et Vivant', '2025-09-01', '2025-10-31', 'Art numerique et nature.', 'Thomas Klein', 'Art et technologie', 4),
('Automne Artistique', '2025-10-15', '2025-12-20', 'Grande exposition pluridisciplinaire d automne.', 'Sophie Marchand', 'Pluridisciplinaire', 1);

-- EXHIBITION_ARTWORK
INSERT INTO EXHIBITION_ARTWORK VALUES
(1,1),(1,2),
(2,5),(2,6),
(3,3),(3,4),
(4,7),(4,8),
(5,9),(5,10);

-- WORKSHOP
INSERT INTO WORKSHOP (title, date, durationMinutes, maxParticipants, price, location, description, level, id_artist) VALUES
('Initiation a la peinture acrylique', '2025-04-12 10:00:00', 180, 10, 55.00, 'Galerie Lumiere, Paris', 'Techniques de base de l acrylique.', 'beginner', 1),
('Photographie de rue', '2025-05-03 14:00:00', 240, 8, 70.00, 'Marseille centre', 'Prise de vue en milieu urbain.', 'intermediate', 2),
('Modelage ceramique', '2025-05-24 09:30:00', 300, 6, 90.00, 'Atelier des Arts, Marseille', 'Initiation au tour de potier.', 'beginner', 3),
('Illustration numerique', '2025-06-14 13:00:00', 180, 12, 60.00, 'Centre Creatif, Bordeaux', 'Illustration sur tablette graphique.', 'intermediate', 4),
('Gravure sur cuivre', '2025-07-05 10:00:00', 360, 6, 85.00, 'Atelier Moreau, Nantes', 'Technique de l eau-forte traditionnelle.', 'advanced', 5),
('Abstraction et couleur', '2025-09-20 14:00:00', 240, 10, 65.00, 'Galerie Lumiere, Paris', 'Composition abstraite a l huile.', 'intermediate', 6);

-- COMMUNITY_MEMBER
INSERT INTO COMMUNITY_MEMBER (name, email, birthYear, phone, city, membershipType) VALUES
('Alice Martin', 'alice.martin@mail.fr', 1995, '0611111111', 'Paris', 'premium'),
('Bruno Leclerc', 'bruno.leclerc@mail.fr', 1988, '0622222222', 'Lyon', 'free'),
('Chloe Simon', 'chloe.simon@mail.fr', 2000, '0633333333', 'Marseille', 'premium'),
('David Nguyen', 'david.nguyen@mail.fr', 1992, '0644444444', 'Paris', 'free'),
('Emma Petit', 'emma.petit@mail.fr', 1997, '0655555555', 'Bordeaux', 'premium'),
('Fabien Roux', 'fabien.roux@mail.fr', 1985, '0666666666', 'Nantes', 'free'),
('Gaelle Durand', 'gaelle.durand@mail.fr', 2001, '0677777777', 'Paris', 'premium'),
('Hugo Bernard', 'hugo.bernard@mail.fr', 1990, '0688888888', 'Lyon', 'free');

-- MEMBER_DISCIPLINE
INSERT INTO MEMBER_DISCIPLINE VALUES
(1,'Peinture'),(1,'Art numerique'),
(2,'Sculpture'),(2,'Ceramique'),
(3,'Photographie'),
(4,'Art numerique'),(4,'Illustration'),
(5,'Gravure'),(5,'Peinture'),
(6,'Ceramique'),
(7,'Peinture'),(7,'Illustration'),
(8,'Sculpture');

-- BOOKING
INSERT INTO BOOKING (id_workshop, id_member, bookingDate, paymentStatus) VALUES
(1,1,'2025-03-10 09:00:00','PAID'),
(1,4,'2025-03-11 10:00:00','PAID'),
(1,7,'2025-03-12 11:00:00','PENDING'),
(2,3,'2025-04-01 14:00:00','PAID'),
(2,5,'2025-04-02 15:00:00','PAID'),
(3,2,'2025-04-15 09:00:00','PAID'),
(3,6,'2025-04-16 10:00:00','PENDING'),
(4,1,'2025-05-01 10:00:00','PAID'),
(4,4,'2025-05-02 11:00:00','CANCELLED'),
(5,5,'2025-06-01 09:00:00','PAID'),
(6,1,'2025-08-10 10:00:00','PAID'),
(6,7,'2025-08-11 11:00:00','PENDING');

-- REVIEW
INSERT INTO REVIEW (id_artwork, id_member, rating, comment, reviewDate) VALUES
(1,1,5,'Magnifique serie, les couleurs sont saisissantes.','2025-04-15'),
(2,7,4,'Belle composition, tres touchant.','2025-04-20'),
(3,3,5,'Travail documentaire exceptionnel.','2025-05-05'),
(4,4,4,'Tres epure, j adore le minimalisme.','2025-05-10'),
(5,2,5,'Sculpture impressionnante, le bois est magnifiquement travaille.','2025-06-01'),
(7,1,4,'Serie numerique originale et bien executee.','2025-09-15'),
(9,5,5,'Gravure d une finesse remarquable.','2025-07-20'),
(10,7,5,'Grand format saisissant, le rouge domine avec puissance.','2025-11-01');
