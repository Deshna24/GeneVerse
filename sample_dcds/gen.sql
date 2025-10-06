-- Table 1: Ethnicities
CREATE TABLE Ethnicities (
    ethnicity_id INTEGER PRIMARY KEY AUTOINCREMENT,
    ethnicity_name TEXT UNIQUE NOT NULL
);

-- Table 2: Individuals
CREATE TABLE Individuals (
    individual_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    gender TEXT NOT NULL, -- Use 'Male', 'Female', 'Other'
    date_of_birth DATE NOT NULL,
    ethnicity_id INTEGER,
    notes TEXT,
    FOREIGN KEY (ethnicity_id) REFERENCES Ethnicities(ethnicity_id)
);

-- Table 3: Families
CREATE TABLE Families (
    family_id INTEGER PRIMARY KEY AUTOINCREMENT,
    family_name TEXT NOT NULL
);

-- Table 4: Family_Members
CREATE TABLE Family_Members (
    family_member_id INTEGER PRIMARY KEY AUTOINCREMENT,
    family_id INTEGER,
    individual_id INTEGER,
    relation TEXT NOT NULL, -- Use 'Father', 'Mother', etc.
    FOREIGN KEY (family_id) REFERENCES Families(family_id),
    FOREIGN KEY (individual_id) REFERENCES Individuals(individual_id)
);

-- Table 5: Genes
CREATE TABLE Genes (
    gene_id INTEGER PRIMARY KEY AUTOINCREMENT,
    gene_symbol TEXT UNIQUE NOT NULL,
    gene_name TEXT NOT NULL,
    description TEXT
);

-- Table 6: Traits
CREATE TABLE Traits (
    trait_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trait_name TEXT UNIQUE NOT NULL,
    category TEXT NOT NULL, -- Use 'Physical', 'Health', etc.
    inheritance_pattern TEXT NOT NULL, -- Use 'Autosomal Dominant', etc.
    description TEXT
);

-- Table 7: Diseases
CREATE TABLE Diseases (
    disease_id INTEGER PRIMARY KEY AUTOINCREMENT,
    disease_name TEXT UNIQUE NOT NULL,
    description TEXT
);

-- Table 8: Studies
CREATE TABLE Studies (
    study_id INTEGER PRIMARY KEY AUTOINCREMENT,
    study_name TEXT NOT NULL,
    publication_year INTEGER,
    doi TEXT
);

-- Table 9: Gene_Trait_Associations
CREATE TABLE Gene_Trait_Associations (
    association_id INTEGER PRIMARY KEY AUTOINCREMENT,
    gene_id INTEGER,
    trait_id INTEGER,
    study_id INTEGER,
    evidence_score REAL CHECK (evidence_score BETWEEN 0 AND 1),
    FOREIGN KEY (gene_id) REFERENCES Genes(gene_id),
    FOREIGN KEY (trait_id) REFERENCES Traits(trait_id),
    FOREIGN KEY (study_id) REFERENCES Studies(study_id)
);

-- Table 10: Trait_Disease_Associations
CREATE TABLE Trait_Disease_Associations (
    td_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trait_id INTEGER,
    disease_id INTEGER,
    FOREIGN KEY (trait_id) REFERENCES Traits(trait_id),
    FOREIGN KEY (disease_id) REFERENCES Diseases(disease_id)
);

-- Table 11: Inheritance_Logs
CREATE TABLE Inheritance_Logs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    individual_id INTEGER,
    trait_id INTEGER,
    diagnosis_date DATE,
    status TEXT NOT NULL, -- Use 'Carrier', 'Affected', 'Unknown'
    notes TEXT,
    FOREIGN KEY (individual_id) REFERENCES Individuals(individual_id),
    FOREIGN KEY (trait_id) REFERENCES Traits(trait_id)
);

-- Audit table for trigger (no trigger in SQLite)
CREATE TABLE Inheritance_Logs_Audit (
    audit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    log_id INTEGER,
    individual_id INTEGER,
    trait_id INTEGER,
    action TEXT,
    action_date TEXT
);

-- Data Insertion (15+ tuples per table, realistic and diverse)
-- Ethnicities (15 entries)
INSERT INTO Ethnicities (ethnicity_name) VALUES
('Caucasian'), ('African American'), ('Hispanic'), ('Asian'), ('South Asian'),
('Middle Eastern'), ('Ashkenazi Jewish'), ('African'), ('East Asian'), ('Southeast Asian'),
('Pacific Islander'), ('Native American'), ('European'), ('Caribbean'), ('Mixed');

-- Individuals (30 entries, diverse ethnicities)
INSERT INTO Individuals (first_name, last_name, gender, date_of_birth, ethnicity_id, notes) VALUES
('Emma', 'Johnson', 'Female', '1998-04-22', 1, 'Starting individual, ID 10 for query'),
('Michael', 'Johnson', 'Male', '1970-06-15', 1, 'Father of Emma'),
('Sarah', 'Johnson', 'Female', '1972-08-30', 1, 'Mother of Emma'),
('James', 'Johnson', 'Male', '1945-03-10', 1, 'Grandfather of Emma'),
('Margaret', 'Brown', 'Female', '1947-05-25', 1, 'Grandmother of Emma'),
('David', 'Smith', 'Male', '1995-11-12', 1, 'Sibling of Emma'),
('Laura', 'Smith', 'Female', '2000-02-28', 1, 'Sibling of Emma'),
('Thomas', 'Brown', 'Male', '1975-09-05', 1, 'Uncle of Emma'),
('Emily', 'Brown', 'Female', '2005-01-17', 1, 'Cousin of Emma'),
('William', 'Johnson', 'Male', '1920-12-01', 1, 'Great-grandfather of Emma'),
('Alice', 'Wilson', 'Female', '1980-07-19', 2, 'Wilson family, African American'),
('Robert', 'Wilson', 'Male', '1978-03-14', 2, 'Husband of Alice'),
('Sophie', 'Wilson', 'Female', '2008-10-10', 2, 'Daughter of Alice'),
('Daniel', 'Taylor', 'Male', '1965-04-03', 3, 'Taylor family, Hispanic'),
('Olivia', 'Taylor', 'Female', '1967-06-22', 3, 'Wife of Daniel'),
('Liam', 'Taylor', 'Male', '1990-09-15', 3, 'Son of Daniel'),
('Chloe', 'Taylor', 'Female', '1993-12-07', 3, 'Daughter of Daniel'),
('George', 'Davis', 'Male', '1985-02-11', 4, 'Davis family, Asian'),
('Hannah', 'Davis', 'Female', '1987-04-30', 4, 'Wife of George'),
('Noah', 'Davis', 'Male', '2010-08-25', 4, 'Son of George'),
('Isabella', 'Martinez', 'Female', '1992-05-18', 3, 'Martinez family'),
('Alexander', 'Lee', 'Male', '1982-11-09', 9, 'East Asian family'),
('Mia', 'Hernandez', 'Female', '2003-07-14', 3, 'Hispanic family'),
('Ethan', 'Kim', 'Male', '1978-01-25', 9, 'East Asian family'),
('Ava', 'Lopez', 'Female', '1996-03-30', 3, 'Hispanic family'),
('Jacob', 'Nguyen', 'Male', '1989-09-05', 10, 'Southeast Asian'),
('Sophia', 'Patel', 'Female', '2001-12-12', 5, 'South Asian'),
('Mason', 'Singh', 'Male', '1994-06-20', 5, 'South Asian'),
('Charlotte', 'Cohen', 'Female', '1985-10-08', 7, 'Ashkenazi Jewish'),
('Logan', 'Levy', 'Male', '1975-04-17', 7, 'Ashkenazi Jewish');

-- Families (15 entries)
INSERT INTO Families (family_name) VALUES
('Johnson Family'), ('Wilson Family'), ('Taylor Family'), ('Davis Family'), ('Martinez Family'),
('Lee Family'), ('Hernandez Family'), ('Kim Family'), ('Lopez Family'), ('Nguyen Family'),
('Patel Family'), ('Singh Family'), ('Cohen Family'), ('Levy Family'), ('Mixed Family');

-- Family_Members (30 entries)
INSERT INTO Family_Members (family_id, individual_id, relation) VALUES
(1, 1, 'Child'), (1, 2, 'Father'), (1, 3, 'Mother'), (1, 4, 'Father'), (1, 5, 'Mother'),
(1, 6, 'Sibling'), (1, 7, 'Sibling'), (1, 8, 'Other'), (1, 9, 'Child'), (1, 10, 'Other'),
(2, 11, 'Mother'), (2, 12, 'Father'), (2, 13, 'Child'),
(3, 14, 'Father'), (3, 15, 'Mother'), (3, 16, 'Child'), (3, 17, 'Child'),
(4, 18, 'Father'), (4, 19, 'Mother'), (4, 20, 'Child'),
(5, 21, 'Mother'), (6, 22, 'Father'), (7, 23, 'Child'), (8, 24, 'Father'), (9, 25, 'Child'),
(10, 26, 'Father'), (11, 27, 'Mother'), (12, 28, 'Father'), (13, 29, 'Mother'), (14, 30, 'Father');

-- Genes (20 entries)
INSERT INTO Genes (gene_symbol, gene_name, description) VALUES
('CFTR', 'Cystic Fibrosis Transmembrane Conductance Regulator', 'Associated with Cystic Fibrosis, common in Caucasians'),
('HBB', 'Hemoglobin Subunit Beta', 'Associated with Sickle Cell Anemia, common in African Americans'),
('BRCA1', 'Breast Cancer 1', 'Associated with breast cancer risk'),
('APOE', 'Apolipoprotein E', 'Associated with Alzheimer’s risk'),
('TP53', 'Tumor Protein P53', 'Associated with multiple cancers'),
('FBN1', 'Fibrillin 1', 'Associated with Marfan syndrome'),
('PKD1', 'Polycystin 1', 'Associated with polycystic kidney disease'),
('HFE', 'Homeostatic Iron Regulator', 'Associated with hemochromatosis'),
('LCT', 'Lactase', 'Associated with lactose intolerance'),
('MC1R', 'Melanocortin 1 Receptor', 'Associated with red hair'),
('TCF7L2', 'Transcription Factor 7 Like 2', 'Associated with Type 2 Diabetes'),
('CAPN10', 'Calpain 10', 'Associated with Type 2 Diabetes'),
('IRS2', 'Insulin Receptor Substrate 2', 'Associated with Type 2 Diabetes'),
('SLC30A8', 'Solute Carrier Family 30 Member 8', 'Associated with Type 2 Diabetes'),
('HMGA2', 'High Mobility Group AT-Hook 2', 'Associated with height'),
('GDF5', 'Growth Differentiation Factor 5', 'Associated with height'),
('GPR126', 'G Protein-Coupled Receptor 126', 'Associated with height'),
('EFEMP1', 'EGF Containing Fibulin Extracellular Matrix Protein 1', 'Associated with height'),
('PNPT1', 'Polyribonucleotide Nucleotidyltransferase 1', 'Associated with height'),
('BRCA2', 'Breast Cancer 2', 'Associated with breast cancer risk');

-- Traits (15 entries, including polygenic)
INSERT INTO Traits (trait_name, category, inheritance_pattern, description) VALUES
('Cystic Fibrosis', 'Health', 'Autosomal Recessive', 'Lung and digestive disorder, high in Caucasians'),
('Sickle Cell Anemia', 'Health', 'Autosomal Recessive', 'Blood disorder, high in African Americans'),
('Breast Cancer Risk', 'Health', 'Polygenic', 'Increased breast cancer risk'),
('Alzheimers Risk', 'Health', 'Polygenic', 'Increased Alzheimer’s risk'),
('Marfan Syndrome', 'Health', 'Autosomal Dominant', 'Connective tissue disorder'),
('Polycystic Kidney Disease', 'Health', 'Autosomal Dominant', 'Kidney cysts'),
('Hemochromatosis', 'Health', 'Autosomal Recessive', 'Iron overload'),
('Lactose Intolerance', 'Physical', 'Autosomal Recessive', 'Inability to digest lactose'),
('Red Hair', 'Physical', 'Polygenic', 'Red hair color'),
('Height', 'Physical', 'Polygenic', 'Stature variation'),
('Type 2 Diabetes Risk', 'Health', 'Polygenic', 'Increased diabetes risk'),
('Blue Eyes', 'Physical', 'Polygenic', 'Eye color variation'),
('Skin Pigmentation', 'Physical', 'Polygenic', 'Skin color variation'),
('Obesity Risk', 'Health', 'Polygenic', 'Increased obesity risk'),
('Hypertension Risk', 'Health', 'Polygenic', 'Increased blood pressure risk');

-- Diseases (15 entries)
INSERT INTO Diseases (disease_name, description) VALUES
('Cystic Fibrosis', 'Lung and digestive disorder'),
('Sickle Cell Disease', 'Blood disorder causing pain'),
('Breast Cancer', 'Malignant breast tumor'),
('Marfan Syndrome', 'Connective tissue disorder'),
('Polycystic Kidney Disease', 'Kidney cysts'),
('Hemochromatosis', 'Iron overload disorder'),
('Type 2 Diabetes', 'Blood sugar regulation disorder'),
('Hypertension', 'High blood pressure'),
('Obesity', 'Excess body fat'),
('Lung Cancer', 'Malignant lung tumor'),
('Cardiovascular Disease', 'Heart and blood vessel disorder'),
('Asthma', 'Chronic respiratory condition'),
('Rheumatoid Arthritis', 'Autoimmune joint disorder'),
('Celiac Disease', 'Gluten intolerance disorder');

-- Studies (15 entries, realistic sources)
INSERT INTO Studies (study_name, publication_year, doi) VALUES
('OMIM CFTR Study', 2010, '10.1002/omim.cftr'), ('GWAS Cystic Fibrosis', 2015, '10.1038/gwas.cf'),
('OMIM Sickle Cell', 2008, '10.1002/omim.hbb'), ('DisGeNET Sickle Cell', 2017, '10.1093/disgenet.hbb'),
('GWAS Breast Cancer', 2019, '10.1038/gwas.brca'), ('OMIM BRCA1 Study', 2012, '10.1002/omim.brca1'),
('GWAS Alzheimer’s', 2020, '10.1038/gwas.apoe'), ('DisGeNET TP53', 2018, '10.1093/disgenet.tp53'),
('OMIM Marfan', 2011, '10.1002/omim.fbn1'), ('OMIM PKD1', 2013, '10.1002/omim.pkd1'),
('GWAS Type 2 Diabetes', 2016, '10.1038/gwas.t2d'), ('OMIM TCF7L2', 2014, '10.1002/omim.tcf7l2'),
('GWAS Height', 2017, '10.1038/gwas.height'), ('DisGeNET Height', 2019, '10.1093/disgenet.height'),
('GWAS Skin Pigmentation', 2018, '10.1038/gwas.skin');

-- Gene_Trait_Associations (30 entries, multiple sources per gene-trait)
INSERT INTO Gene_Trait_Associations (gene_id, trait_id, study_id, evidence_score) VALUES
(1, 1, 1, 0.95), (1, 1, 2, 0.92), (2, 2, 3, 0.94), (2, 2, 4, 0.90),
(3, 3, 5, 0.90), (3, 3, 6, 0.93), (4, 4, 7, 0.85), (5, 4, 8, 0.80),
(6, 5, 9, 0.93), (7, 6, 10, 0.91), (8, 7, 1, 0.89), (9, 8, 2, 0.87),
(10, 9, 3, 0.88), (11, 11, 11, 0.92), (11, 11, 12, 0.90), (12, 11, 11, 0.88),
(13, 11, 12, 0.85), (14, 11, 11, 0.89), (15, 10, 13, 0.91), (15, 10, 14, 0.87),
(16, 10, 13, 0.90), (17, 10, 13, 0.88), (18, 10, 14, 0.86), (19, 10, 13, 0.84),
(20, 3, 5, 0.92), (20, 3, 6, 0.89), (3, 11, 11, 0.80), (4, 15, 7, 0.82),
(10, 13, 15, 0.85), (15, 14, 13, 0.83);

-- Trait_Disease_Associations (15 entries)
INSERT INTO Trait_Disease_Associations (trait_id, disease_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (11, 8), (15, 9),
(14, 10), (8, 7), (9, 3), (10, 8), (12, 4), (13, 11);

-- Inheritance_Logs (30 entries, carrier vs. affected, ethnic relevance)
INSERT INTO Inheritance_Logs (individual_id, trait_id, diagnosis_date, status, notes) VALUES
(1, 1, '2010-06-15', 'Affected', 'Cystic Fibrosis - Caucasian'),
(2, 1, '1990-08-20', 'Carrier', 'Cystic Fibrosis - Caucasian'),
(4, 1, '1970-03-12', 'Carrier', 'Cystic Fibrosis - Caucasian'),
(10, 1, '1950-11-05', 'Carrier', 'Cystic Fibrosis - Caucasian'),
(11, 2, '2005-04-10', 'Affected', 'Sickle Cell Anemia - African American'),
(12, 2, '1985-07-22', 'Carrier', 'Sickle Cell - African American'),
(13, 2, '2015-01-30', 'Affected', 'Sickle Cell Anemia - African American'),
(14, 11, '2000-03-15', 'Affected', 'Type 2 Diabetes - Hispanic'),
(15, 11, '1995-09-10', 'Carrier', 'Type 2 Diabetes Risk - Hispanic'),
(16, 11, '2010-02-25', 'Affected', 'Type 2 Diabetes - Hispanic'),
(18, 10, '1980-06-18', 'Unknown', 'Height - Asian'),
(19, 10, '1990-11-11', 'Unknown', 'Height - Asian'),
(20, 10, '2005-05-20', 'Unknown', 'Height - Asian'),
(21, 3, '2015-08-30', 'Affected', 'Breast Cancer Risk - Hispanic'),
(22, 3, '2000-04-15', 'Carrier', 'Breast Cancer Risk - East Asian'),
(23, 4, '2012-02-10', 'Unknown', 'Alzheimer’s Risk - Hispanic'),
(24, 5, '1998-07-05', 'Affected', 'Marfan Syndrome - East Asian'),
(25, 6, '2008-12-20', 'Affected', 'Polycystic Kidney - Hispanic'),
(26, 7, '2018-09-15', 'Carrier', 'Hemochromatosis - Southeast Asian'),
(27, 8, '2003-06-30', 'Affected', 'Lactose Intolerance - South Asian'),
(28, 9, '2013-03-25', 'Unknown', 'Red Hair - South Asian'),
(29, 11, '1999-10-10', 'Affected', 'Type 2 Diabetes - Ashkenazi Jewish'),
(30, 2, '1989-05-05', 'Carrier', 'Sickle Cell - Ashkenazi Jewish'),
(1, 11, '2020-01-01', 'Affected', 'Type 2 Diabetes - Caucasian'),
(11, 10, '2010-02-02', 'Unknown', 'Height - African American'),
(21, 2, '2005-03-03', 'Carrier', 'Sickle Cell - Hispanic'),
(14, 3, '2015-04-04', 'Affected', 'Breast Cancer Risk - Hispanic'),
(22, 4, '2020-05-05', 'Unknown', 'Alzheimer’s Risk - East Asian'),
(27, 15, '2010-06-06', 'Affected', 'Hypertension Risk - South Asian'),
(30, 14, '2020-07-07', 'Affected', 'Obesity Risk - Ashkenazi Jewish');

-- Inheritance_Logs_Audit (15 entries, use CURRENT_TIMESTAMP for action_date)
INSERT INTO Inheritance_Logs_Audit (log_id, individual_id, trait_id, action, action_date) VALUES
(1, 1, 1, 'INSERT', CURRENT_TIMESTAMP), (2, 2, 1, 'INSERT', CURRENT_TIMESTAMP), (3, 4, 1, 'INSERT', CURRENT_TIMESTAMP),
(4, 10, 1, 'INSERT', CURRENT_TIMESTAMP), (5, 11, 2, 'INSERT', CURRENT_TIMESTAMP), (6, 12, 2, 'INSERT', CURRENT_TIMESTAMP),
(7, 13, 2, 'INSERT', CURRENT_TIMESTAMP), (8, 14, 11, 'INSERT', CURRENT_TIMESTAMP), (9, 15, 11, 'INSERT', CURRENT_TIMESTAMP),
(10, 16, 11, 'INSERT', CURRENT_TIMESTAMP), (11, 18, 10, 'INSERT', CURRENT_TIMESTAMP), (12, 19, 10, 'INSERT', CURRENT_TIMESTAMP),
(13, 20, 10, 'INSERT', CURRENT_TIMESTAMP), (14, 21, 3, 'INSERT', CURRENT_TIMESTAMP), (15, 22, 3, 'INSERT', CURRENT_TIMESTAMP);