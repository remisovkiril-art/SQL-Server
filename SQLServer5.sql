USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'Academy')
BEGIN
    ALTER DATABASE Academy SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Academy;
END
GO

CREATE DATABASE Academy;
GO

USE Academy;
GO

CREATE TABLE Teachers
(
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);

CREATE TABLE Assistants
(
    Id INT IDENTITY PRIMARY KEY,
    TeacherId INT NOT NULL UNIQUE,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Curators
(
    Id INT IDENTITY PRIMARY KEY,
    TeacherId INT NOT NULL UNIQUE,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Deans
(
    Id INT IDENTITY PRIMARY KEY,
    TeacherId INT NOT NULL UNIQUE,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Heads
(
    Id INT IDENTITY PRIMARY KEY,
    TeacherId INT NOT NULL UNIQUE,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Faculties
(
    Id INT IDENTITY PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> ''),
    DeanId INT NOT NULL UNIQUE,
    FOREIGN KEY (DeanId) REFERENCES Deans(Id)
);

CREATE TABLE Departments
(
    Id INT IDENTITY PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> ''),
    FacultyId INT NOT NULL,
    HeadId INT NOT NULL UNIQUE,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id),
    FOREIGN KEY (HeadId) REFERENCES Heads(Id)
);

CREATE TABLE Groups
(
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name <> ''),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE GroupsCurators
(
    Id INT IDENTITY PRIMARY KEY,
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

CREATE TABLE Subjects
(
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Lectures
(
    Id INT IDENTITY PRIMARY KEY,
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures
(
    Id INT IDENTITY PRIMARY KEY,
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

CREATE TABLE LectureRooms
(
    Id INT IDENTITY PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Schedules
(
    Id INT IDENTITY PRIMARY KEY,
    Class INT NOT NULL CHECK (Class BETWEEN 1 AND 8),
    DayOfWeek INT NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7),
    Week INT NOT NULL CHECK (Week BETWEEN 1 AND 52),
    LectureId INT NOT NULL,
    LectureRoomId INT NOT NULL,
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id),
    FOREIGN KEY (LectureRoomId) REFERENCES LectureRooms(Id)
);

INSERT INTO Teachers (Name, Surname) VALUES
('Edward', 'Hopper'),
('Alex', 'Carmack'),
('John', 'Dean'),
('Michael', 'Head'),
('Sarah', 'Assistant'),
('David', 'Curator');

INSERT INTO Deans (TeacherId) VALUES (3);
INSERT INTO Heads (TeacherId) VALUES (4);
INSERT INTO Assistants (TeacherId) VALUES (5);
INSERT INTO Curators (TeacherId) VALUES (6);

INSERT INTO Faculties (Building, Name, DeanId)
VALUES (5, 'Computer Science', 1);

INSERT INTO Departments (Building, Name, FacultyId, HeadId)
VALUES (5, 'Software Development', 1, 1);

INSERT INTO Groups (Name, Year, DepartmentId)
VALUES ('F505', 5, 1);

INSERT INTO GroupsCurators (CuratorId, GroupId)
VALUES (1, 1);

INSERT INTO Subjects (Name) VALUES
('Databases'),
('Algorithms');

INSERT INTO Lectures (SubjectId, TeacherId) VALUES
(1, 1),
(2, 2),
(1, 5);

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
(1, 1),
(1, 2),
(1, 3);

INSERT INTO LectureRooms (Building, Name) VALUES
(5, 'A311'),
(5, 'A104'),
(2, 'B201');

INSERT INTO Schedules (Class, DayOfWeek, Week, LectureId, LectureRoomId) VALUES
(3, 3, 2, 1, 1),
(1, 1, 1, 2, 2),
(2, 5, 1, 3, 3);

SELECT DISTINCT lr.Name
FROM Teachers t
JOIN Lectures l ON t.Id = l.TeacherId
JOIN Schedules s ON l.Id = s.LectureId
JOIN LectureRooms lr ON s.LectureRoomId = lr.Id
WHERE t.Name = 'Edward' AND t.Surname = 'Hopper';

SELECT DISTINCT t.Surname
FROM Groups g
JOIN GroupsLectures gl ON g.Id = gl.GroupId
JOIN Lectures l ON gl.LectureId = l.Id
JOIN Assistants a ON l.TeacherId = a.TeacherId
JOIN Teachers t ON a.TeacherId = t.Id
WHERE g.Name = 'F505';

SELECT DISTINCT s.Name
FROM Teachers t
JOIN Lectures l ON t.Id = l.TeacherId
JOIN Subjects s ON l.SubjectId = s.Id
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE t.Name = 'Alex' AND t.Surname = 'Carmack'
AND g.Year = 5;

SELECT DISTINCT t.Surname
FROM Teachers t
WHERE t.Id NOT IN
(
    SELECT l.TeacherId
    FROM Lectures l
    JOIN Schedules s ON l.Id = s.LectureId
    WHERE s.DayOfWeek = 1
);

SELECT lr.Name, lr.Building
FROM LectureRooms lr
WHERE lr.Id NOT IN
(
    SELECT LectureRoomId
    FROM Schedules
    WHERE DayOfWeek = 3
    AND Week = 2
    AND Class = 3
);

SELECT t.Name + ' ' + t.Surname AS FullName
FROM Teachers t
JOIN Lectures l ON t.Id = l.TeacherId
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
JOIN Departments d ON g.DepartmentId = d.Id
JOIN Faculties f ON d.FacultyId = f.Id
WHERE f.Name = 'Computer Science'
AND t.Id NOT IN
(
    SELECT c.TeacherId
    FROM Curators c
    JOIN GroupsCurators gc ON c.Id = gc.CuratorId
    JOIN Groups g2 ON gc.GroupId = g2.Id
    JOIN Departments d2 ON g2.DepartmentId = d2.Id
    WHERE d2.Name = 'Software Development'
);

SELECT Building FROM Faculties
UNION
SELECT Building FROM Departments
UNION
SELECT Building FROM LectureRooms;

SELECT Name + ' ' + Surname AS FullName
FROM Teachers t
LEFT JOIN Deans d ON t.Id = d.TeacherId
LEFT JOIN Heads h ON t.Id = h.TeacherId
LEFT JOIN Curators c ON t.Id = c.TeacherId
LEFT JOIN Assistants a ON t.Id = a.TeacherId
ORDER BY
    CASE
        WHEN d.TeacherId IS NOT NULL THEN 1
        WHEN h.TeacherId IS NOT NULL THEN 2
        WHEN c.TeacherId IS NULL AND a.TeacherId IS NULL THEN 3
        WHEN c.TeacherId IS NOT NULL THEN 4
        WHEN a.TeacherId IS NOT NULL THEN 5
    END;

SELECT DISTINCT s.DayOfWeek
FROM Schedules s
JOIN LectureRooms lr ON s.LectureRoomId = lr.Id
WHERE lr.Name IN ('A311','A104')
AND lr.Building = 5;