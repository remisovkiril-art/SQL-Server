USE master;
GO

CREATE DATABASE Academy;
GO

USE Academy;
GO

CREATE TABLE Faculties
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);
GO

CREATE TABLE Departments
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> ''),
    FacultyId INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);
GO

CREATE TABLE Groups
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name <> ''),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);
GO

CREATE TABLE Teachers
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);
GO

CREATE TABLE Subjects
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);
GO

CREATE TABLE Lectures
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    LectureRoom NVARCHAR(MAX) NOT NULL CHECK (LectureRoom <> ''),
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);
GO

CREATE TABLE GroupsLectures
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);
GO

CREATE TABLE Curators
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);
GO

CREATE TABLE GroupsCurators
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);
GO

INSERT INTO Faculties (Financing, Name)
VALUES 
(100000, N'Computer Science'),
(50000, N'Engineering');

INSERT INTO Departments (Financing, Name, FacultyId)
VALUES
(120000, N'Software Development', 1),
(20000, N'Cyber Security', 1),
(30000, N'Mechanics', 2);

INSERT INTO Groups (Name, Year, DepartmentId)
VALUES
('P107', 5, 1),
('P201', 3, 2),
('M101', 5, 3);

INSERT INTO Teachers (Name, Salary, Surname)
VALUES
('Samantha', 3000, 'Adams'),
('John', 2500, 'Brown'),
('Alice', 2800, 'Smith');

INSERT INTO Subjects (Name)
VALUES
(N'Database Theory'),
(N'Programming'),
(N'Mathematics');

INSERT INTO Lectures (LectureRoom, SubjectId, TeacherId)
VALUES
('B103', 1, 1),
('A201', 2, 2),
('B103', 3, 3);

INSERT INTO GroupsLectures (GroupId, LectureId)
VALUES
(1,1),
(1,2),
(2,3),
(3,3);

INSERT INTO Curators (Name, Surname)
VALUES
('Olga','Petrenko'),
('Ivan','Shevchenko');

INSERT INTO GroupsCurators (CuratorId, GroupId)
VALUES
(1,1),
(2,2);

SELECT T.Surname, G.Name
FROM Teachers T
CROSS JOIN Groups G;

SELECT DISTINCT F.Name
FROM Faculties F
JOIN Departments D ON D.FacultyId = F.Id
GROUP BY F.Id, F.Name, F.Financing
HAVING SUM(D.Financing) > F.Financing;

SELECT C.Surname, G.Name
FROM Curators C
JOIN GroupsCurators GC ON GC.CuratorId = C.Id
JOIN Groups G ON G.Id = GC.GroupId;

SELECT DISTINCT T.Surname
FROM Teachers T
JOIN Lectures L ON L.TeacherId = T.Id
JOIN GroupsLectures GL ON GL.LectureId = L.Id
JOIN Groups G ON G.Id = GL.GroupId
WHERE G.Name = 'P107';

SELECT DISTINCT T.Surname, F.Name
FROM Teachers T
JOIN Lectures L ON L.TeacherId = T.Id
JOIN GroupsLectures GL ON GL.LectureId = L.Id
JOIN Groups G ON G.Id = GL.GroupId
JOIN Departments D ON D.Id = G.DepartmentId
JOIN Faculties F ON F.Id = D.FacultyId;

SELECT D.Name, G.Name
FROM Departments D
JOIN Groups G ON G.DepartmentId = D.Id;

SELECT DISTINCT S.Name
FROM Subjects S
JOIN Lectures L ON L.SubjectId = S.Id
JOIN Teachers T ON T.Id = L.TeacherId
WHERE T.Name = 'Samantha'
AND T.Surname = 'Adams';

SELECT DISTINCT D.Name
FROM Departments D
JOIN Groups G ON G.DepartmentId = D.Id
JOIN GroupsLectures GL ON GL.GroupId = G.Id
JOIN Lectures L ON L.Id = GL.LectureId
JOIN Subjects S ON S.Id = L.SubjectId
WHERE S.Name = N'Database theory';

SELECT G.Name
FROM Groups G
JOIN Departments D ON D.Id = G.DepartmentId
JOIN Faculties F ON F.Id = D.FacultyId
WHERE F.Name = N'Computer Science';

SELECT G.Name, F.Name
FROM Groups G
JOIN Departments D ON D.Id = G.DepartmentId
JOIN Faculties F ON F.Id = D.FacultyId
WHERE G.Year = 5;

SELECT T.Surname, S.Name, G.Name
FROM Teachers T
JOIN Lectures L ON L.TeacherId = T.Id
JOIN Subjects S ON S.Id = L.SubjectId
JOIN GroupsLectures GL ON GL.LectureId = L.Id
JOIN Groups G ON G.Id = GL.GroupId
WHERE L.LectureRoom = 'B103';