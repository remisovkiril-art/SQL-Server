USE master;
GO

DROP DATABASE Academy;
GO

CREATE DATABASE Academy;
GO

USE Academy;
GO

CREATE TABLE Faculties
(
    Id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Dean NVARCHAR(MAX) NOT NULL CHECK (Dean <> ''),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);
GO

CREATE TABLE Departments
(
    Id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);
GO

CREATE TABLE Groups
(
    Id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name <> ''),
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5),
    [Year] INT NOT NULL CHECK ([Year] BETWEEN 1 AND 5)
);
GO

CREATE TABLE Teachers
(
    Id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    EmploymentDate DATE NOT NULL CHECK (EmploymentDate >= '1990-01-01'),
    IsAssistant BIT NOT NULL DEFAULT 0,
    IsProfessor BIT NOT NULL DEFAULT 0,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Position NVARCHAR(MAX) NOT NULL CHECK (Position <> ''),
    Premium MONEY NOT NULL DEFAULT 0 CHECK (Premium >= 0),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);
GO

INSERT INTO Departments (Financing, Name)
VALUES 
    (15000, 'Software Development'),
    (30000, 'Cyber Security'),
    (9000, 'Mathematics');
GO

INSERT INTO Faculties (Dean, Name)
VALUES 
    ('John Smith', 'Computer Science'),
    ('Anna Brown', 'Engineering');
GO

INSERT INTO Groups (Name, Rating, [Year])
VALUES 
    ('CS-101', 4, 5),
    ('CS-201', 3, 2);
GO

INSERT INTO Teachers
    (EmploymentDate, IsAssistant, IsProfessor, Name, Position, Premium, Salary, Surname)
VALUES
    ('1998-05-10', 1, 0, 'Alex', 'Assistant', 200, 800, 'Johnson'),
    ('2005-09-01', 0, 1, 'Robert', 'Professor', 500, 1500, 'Williams'),
    ('1995-03-15', 1, 0, 'David', 'Assistant', 300, 600, 'Taylor');
GO

USE Academy;
GO

SELECT Name, Financing, Id
FROM Departments;

SELECT 
    Name AS [Group Name],
    Rating AS [Group Rating]
FROM Groups;

SELECT 
    Surname,
    (Premium * 100.0 / Salary) AS PremiumPercentOfSalary,
    (Salary * 100.0 / (Salary + Premium)) AS SalaryPercentOfTotal
FROM Teachers;

SELECT 
    'The dean of faculty ' + Name + ' is ' + Dean + '.' AS FacultyInfo
FROM Faculties;

SELECT Surname
FROM Teachers
WHERE IsProfessor = 1 AND Salary > 1050;

SELECT Name
FROM Departments
WHERE Financing < 11000 OR Financing > 25000;

SELECT Name
FROM Faculties
WHERE Name <> 'Computer Science';

SELECT Surname, Position
FROM Teachers
WHERE IsProfessor = 0;

SELECT Surname, Position, Salary, Premium
FROM Teachers
WHERE IsAssistant = 1 AND Premium BETWEEN 160 AND 550;

SELECT Surname, Salary
FROM Teachers
WHERE IsAssistant = 1;

SELECT Surname, Position
FROM Teachers
WHERE EmploymentDate < '2000-01-01';

SELECT Name AS [Name of Department]
FROM Departments
WHERE Name < 'Software Development';

SELECT Surname
FROM Teachers
WHERE IsAssistant = 1 AND (Salary + Premium) <= 1200;

SELECT Name
FROM Groups
WHERE [Year] = 5 AND Rating BETWEEN 2 AND 4;

SELECT Surname
FROM Teachers
WHERE IsAssistant = 1 AND (Salary < 550 OR Premium < 200);
