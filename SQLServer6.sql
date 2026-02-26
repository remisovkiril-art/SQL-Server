CREATE DATABASE SportsStore;
GO

USE SportsStore;
GO

CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Position NVARCHAR(50) NOT NULL,
    HireDate DATE NOT NULL,
    Gender NVARCHAR(10),
    Salary DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE ArchivedEmployees (
    ArchiveID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    FullName NVARCHAR(100),
    Position NVARCHAR(50),
    HireDate DATE,
    Gender NVARCHAR(10),
    Salary DECIMAL(10,2),
    DismissalDate DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    ProductType NVARCHAR(50),
    QuantityInStock INT,
    CostPrice DECIMAL(10,2),
    Manufacturer NVARCHAR(100),
    SalePrice DECIMAL(10,2)
);
GO

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    Gender NVARCHAR(10),
    DiscountPercent INT,
    IsSubscribed BIT
);
GO

CREATE TABLE Sales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    EmployeeID INT NOT NULL,
    CustomerID INT NULL,
    SalePrice DECIMAL(10,2),
    Quantity INT,
    SaleDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Sales_Product FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT FK_Sales_Employee FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmployeeID),

    CONSTRAINT FK_Sales_Customer FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
);
GO

CREATE TRIGGER trg_ArchiveEmployee
ON Employees
AFTER DELETE
AS
BEGIN
    INSERT INTO ArchivedEmployees
    (
        EmployeeID,
        FullName,
        Position,
        HireDate,
        Gender,
        Salary,
        DismissalDate
    )
    SELECT
        d.EmployeeID,
        d.FullName,
        d.Position,
        d.HireDate,
        d.Gender,
        d.Salary,
        GETDATE()
    FROM deleted d;
END;
GO

INSERT INTO Employees (FullName, Position, HireDate, Gender, Salary)
VALUES 
('John Smith', 'Manager', '2020-03-01', 'Male', 5000),
('Emily Brown', 'Sales Consultant', '2021-06-15', 'Female', 3500);

SELECT * FROM Employees;
GO

DELETE FROM Employees WHERE FullName = 'Emily Brown';
GO

SELECT * FROM ArchivedEmployees;
GO