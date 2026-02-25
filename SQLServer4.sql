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
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> ''),
    FacultyId INT NOT NULL,
    CONSTRAINT FK_Departments_Faculties
        FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

CREATE TABLE Teachers
(
    Id INT IDENTITY PRIMARY KEY,
    IsProfessor BIT NOT NULL DEFAULT 0,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
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
    CONSTRAINT FK_Groups_Departments
        FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE Curators
(
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);

CREATE TABLE Students
(
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);

CREATE TABLE Lectures
(
    Id INT IDENTITY PRIMARY KEY,
    [Date] DATE NOT NULL CHECK ([Date] <= GETDATE()),
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    Week INT NOT NULL CHECK (Week BETWEEN 1 AND 52),
    CONSTRAINT FK_Lectures_Subjects
        FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    CONSTRAINT FK_Lectures_Teachers
        FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures
(
    Id INT IDENTITY PRIMARY KEY,
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    CONSTRAINT FK_GroupsLectures_Groups
        FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    CONSTRAINT FK_GroupsLectures_Lectures
        FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

CREATE TABLE GroupsStudents
(
    Id INT IDENTITY PRIMARY KEY,
    GroupId INT NOT NULL,
    StudentId INT NOT NULL,
    CONSTRAINT FK_GroupsStudents_Groups
        FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    CONSTRAINT FK_GroupsStudents_Students
        FOREIGN KEY (StudentId) REFERENCES Students(Id)
);

CREATE TABLE GroupsCurators
(
    Id INT IDENTITY PRIMARY KEY,
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    CONSTRAINT FK_GroupsCurators_Curators
        FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    CONSTRAINT FK_GroupsCurators_Groups
        FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

INSERT INTO Faculties (Name) VALUES
('Computer Science'),
('Economics');

INSERT INTO Departments (Building, Financing, Name, FacultyId) VALUES
(1, 150000, 'Software Development', 1),
(2, 80000, 'Cyber Security', 1),
(3, 200000, 'Finance', 2);

INSERT INTO Teachers (IsProfessor, Name, Salary, Surname) VALUES
(1, 'John', 5000, 'Smith'),
(1, 'Alice', 6000, 'Brown'),
(0, 'Mark', 7000, 'Wilson'),
(0, 'Emma', 3000, 'Taylor');

INSERT INTO Subjects (Name) VALUES
('Databases'),
('Algorithms'),
('Networks');

INSERT INTO Groups (Name, Year, DepartmentId) VALUES
('D221', 5, 1),
('D222', 5, 1),
('C101', 3, 2);

INSERT INTO Curators (Name, Surname) VALUES
('Olga', 'Ivanova'),
('Petr', 'Petrov');

INSERT INTO Students (Name, Rating, Surname) VALUES
('A',5,'A'),
('B',4,'B'),
('C',3,'C'),
('D',5,'D'),
('E',2,'E');

INSERT INTO GroupsStudents (GroupId, StudentId) VALUES
(1,1),(1,2),
(2,3),(2,4),
(3,5);

INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES
(1,1),
(2,1),
(1,2);

INSERT INTO Lectures ([Date], SubjectId, TeacherId, Week) VALUES
(GETDATE(),1,1,1),
(GETDATE(),1,1,1),
(GETDATE(),1,1,1),
(GETDATE(),2,3,1),
(GETDATE(),2,3,1),
(GETDATE(),2,3,1),
(GETDATE(),2,3,1),
(GETDATE(),2,3,1),
(GETDATE(),2,3,1),
(GETDATE(),2,3,1),
(GETDATE(),2,3,1),
(GETDATE(),2,3,1),
(GETDATE(),3,4,1);

INSERT INTO GroupsLectures (GroupId, LectureId)
SELECT 2, Id FROM Lectures;

SELECT Building
FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 100000;

SELECT g.Name
FROM Groups g
WHERE g.Year = 5
AND g.DepartmentId =
(
    SELECT Id FROM Departments
    WHERE Name = 'Software Development'
)
AND
(
    SELECT COUNT(*)
    FROM GroupsLectures gl
    JOIN Lectures l ON gl.LectureId = l.Id
    WHERE gl.GroupId = g.Id
    AND l.Week = 1
) > 10;

SELECT g.Name
FROM Groups g
WHERE
(
    SELECT AVG(s.Rating)
    FROM GroupsStudents gs
    JOIN Students s ON gs.StudentId = s.Id
    WHERE gs.GroupId = g.Id
)
>
(
    SELECT AVG(s.Rating)
    FROM GroupsStudents gs
    JOIN Students s ON gs.StudentId = s.Id
    WHERE gs.GroupId =
    (
        SELECT Id FROM Groups WHERE Name = 'D221'
    )
);

SELECT Surname, Name
FROM Teachers
WHERE Salary >
(
    SELECT AVG(Salary)
    FROM Teachers
    WHERE IsProfessor = 1
);

SELECT g.Name
FROM Groups g
WHERE
(
    SELECT COUNT(*)
    FROM GroupsCurators gc
    WHERE gc.GroupId = g.Id
) > 1;

SELECT g.Name
FROM Groups g
WHERE
(
    SELECT AVG(s.Rating)
    FROM GroupsStudents gs
    JOIN Students s ON gs.StudentId = s.Id
    WHERE gs.GroupId = g.Id
)
<
(
    SELECT MIN(GroupRating)
    FROM
    (
        SELECT AVG(s.Rating) AS GroupRating
        FROM Groups g2
        JOIN GroupsStudents gs ON g2.Id = gs.GroupId
        JOIN Students s ON gs.StudentId = s.Id
        WHERE g2.Year = 5
        GROUP BY g2.Id
    ) AS Ratings
);

SELECT f.Name
FROM Faculties f
WHERE
(
    SELECT SUM(d.Financing)
    FROM Departments d
    WHERE d.FacultyId = f.Id
)
>
(
    SELECT SUM(d.Financing)
    FROM Departments d
    WHERE d.FacultyId =
    (
        SELECT Id FROM Faculties WHERE Name = 'Computer Science'
    )
);

SELECT s.Name,
       t.Name + ' ' + t.Surname AS TeacherFullName
FROM Lectures l
JOIN Subjects s ON l.SubjectId = s.Id
JOIN Teachers t ON l.TeacherId = t.Id
GROUP BY s.Name, t.Name, t.Surname
HAVING COUNT(*) =
(
    SELECT MAX(LectureCount)
    FROM
    (
        SELECT COUNT(*) AS LectureCount
        FROM Lectures
        GROUP BY SubjectId, TeacherId
    ) AS Counts
);

SELECT s.Name
FROM Subjects s
JOIN Lectures l ON s.Id = l.SubjectId
GROUP BY s.Name
HAVING COUNT(*) =
(
    SELECT MIN(LectureCount)
    FROM
    (
        SELECT COUNT(*) AS LectureCount
        FROM Lectures
        GROUP BY SubjectId
    ) AS Counts
);

SELECT
(
    SELECT COUNT(DISTINCT gs.StudentId)
    FROM Groups g
    JOIN GroupsStudents gs ON g.Id = gs.GroupId
    WHERE g.DepartmentId =
    (
        SELECT Id FROM Departments
        WHERE Name = 'Software Development'
    )
) AS StudentsCount,
(
    SELECT COUNT(DISTINCT l.SubjectId)
    FROM Groups g
    JOIN GroupsLectures gl ON g.Id = gl.GroupId
    JOIN Lectures l ON gl.LectureId = l.Id
    WHERE g.DepartmentId =
    (
        SELECT Id FROM Departments
        WHERE Name = 'Software Development'
    )
) AS SubjectsCount;
