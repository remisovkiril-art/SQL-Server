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

CREATE TABLE Faculties
(
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Departments
(
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> ''),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    FacultyId INT NOT NULL,
    CONSTRAINT FK_Departments_Faculties FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

CREATE TABLE Teachers
(
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> ''),
    Salary MONEY NOT NULL CHECK (Salary > 0)
);

CREATE TABLE Subjects
(
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Groups
(
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name <> ''),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    StudentsCount INT NOT NULL DEFAULT 1 CHECK (StudentsCount > 0), 
    CONSTRAINT FK_Groups_Departments FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE Lectures
(
    Id INT IDENTITY PRIMARY KEY,
    DayOfWeek INT NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7),
    LectureRoom NVARCHAR(MAX) NOT NULL CHECK (LectureRoom <> ''),
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    CONSTRAINT FK_Lectures_Subjects FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    CONSTRAINT FK_Lectures_Teachers FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures
(
    Id INT IDENTITY PRIMARY KEY,
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    CONSTRAINT FK_GroupsLectures_Groups FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    CONSTRAINT FK_GroupsLectures_Lectures FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

INSERT INTO Faculties (Name) VALUES ('Computer Science'), ('Engineering');

INSERT INTO Departments (Name, Financing, FacultyId)
VALUES ('Software Development', 150000, 1), ('Artificial Intelligence', 200000, 1), ('Mechanical Engineering', 180000, 2);

INSERT INTO Teachers (Name, Surname, Salary)
VALUES ('Dave', 'McQueen', 5000), ('Jack', 'Underhill', 5500), ('Alice', 'Smith', 4800), ('Robert', 'Brown', 4500);

INSERT INTO Subjects (Name) VALUES ('C# Programming'), ('Databases'), ('Machine Learning'), ('Physics');

INSERT INTO Groups (Name, Year, DepartmentId, StudentsCount)
VALUES ('SD-101', 1, 1, 20), ('SD-201', 2, 1, 18), ('AI-101', 1, 2, 25), ('ME-101', 1, 3, 15);

INSERT INTO Lectures (DayOfWeek, LectureRoom, SubjectId, TeacherId)
VALUES (1, 'D201', 1, 1), (2, 'D201', 2, 1), (3, 'A101', 2, 2), (4, 'A102', 3, 2), (5, 'B201', 3, 3), (1, 'D201', 4, 4);

INSERT INTO GroupsLectures (GroupId, LectureId)
VALUES (1,1), (2,1), (1,2), (3,3), (3,4), (4,6);

SELECT COUNT(DISTINCT T.Id) AS TeacherCount FROM Teachers T
JOIN Lectures L ON T.Id = L.TeacherId
JOIN GroupsLectures GL ON L.Id = GL.LectureId
JOIN Groups G ON GL.GroupId = G.Id
JOIN Departments D ON G.DepartmentId = D.Id
WHERE D.Name = 'Software Development';

SELECT COUNT(*) AS LectureCount FROM Lectures L
JOIN Teachers T ON L.TeacherId = T.Id
WHERE T.Name = 'Dave' AND T.Surname = 'McQueen';

SELECT COUNT(*) AS LectureCount FROM Lectures WHERE LectureRoom = 'D201';

SELECT COUNT(DISTINCT GL.GroupId) AS StudentGroupCount FROM Lectures L
JOIN Teachers T ON L.TeacherId = T.Id
JOIN GroupsLectures GL ON L.Id = GL.LectureId
WHERE T.Name = 'Jack' AND T.Surname = 'Underhill';

SELECT AVG(T.Salary) AS AverageSalary FROM Teachers T
JOIN Lectures L ON T.Id = L.TeacherId
JOIN GroupsLectures GL ON L.Id = GL.LectureId
JOIN Groups G ON GL.GroupId = G.Id
JOIN Departments D ON G.DepartmentId = D.Id
JOIN Faculties F ON D.FacultyId = F.Id
WHERE F.Name = 'Computer Science';

SELECT AVG(Financing) AS AverageFinancing FROM Departments;

SELECT T.Name + ' ' + T.Surname AS FullName, COUNT(DISTINCT L.SubjectId) AS SubjectCount
FROM Teachers T
LEFT JOIN Lectures L ON T.Id = L.TeacherId
GROUP BY T.Name, T.Surname;

SELECT DayOfWeek, COUNT(*) AS LectureCount FROM Lectures
GROUP BY DayOfWeek;

SELECT L.LectureRoom, COUNT(DISTINCT D.Id) AS DepartmentCount FROM Lectures L
JOIN GroupsLectures GL ON L.Id = GL.LectureId
JOIN Groups G ON GL.GroupId = G.Id
JOIN Departments D ON G.DepartmentId = D.Id
GROUP BY L.LectureRoom;

SELECT F.Name, COUNT(DISTINCT S.Id) AS SubjectCount FROM Faculties F
JOIN Departments D ON F.Id = D.FacultyId
JOIN Groups G ON D.Id = G.DepartmentId
JOIN GroupsLectures GL ON G.Id = GL.GroupId
JOIN Lectures L ON GL.LectureId = L.Id
JOIN Subjects S ON L.SubjectId = S.Id
GROUP BY F.Name;

SELECT T.Name + ' ' + T.Surname AS Teacher, L.LectureRoom, COUNT(*) AS LectureCount
FROM Lectures L
JOIN Teachers T ON L.TeacherId = T.Id
GROUP BY T.Name, T.Surname, L.LectureRoom;

SELECT LectureRoom, COUNT(*) AS LectureCount FROM Lectures GROUP BY LectureRoom;