USE master;
GO

IF OBJECT_ID('Books', 'U') IS NOT NULL DROP TABLE Books;
IF OBJECT_ID('Authors', 'U') IS NOT NULL DROP TABLE Authors;
GO

CREATE TABLE Authors (
    Id INT PRIMARY KEY IDENTITY,
    FullName NVARCHAR(100) NOT NULL,
    Discount INT DEFAULT 0
);
GO

CREATE TABLE Books (
    Id INT PRIMARY KEY IDENTITY,
    Title NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    AuthorId INT NOT NULL
        FOREIGN KEY REFERENCES Authors(Id)
);
GO

CREATE TRIGGER trg_UpdateBookPrices
ON Authors
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Discount)
    BEGIN
        UPDATE b
        SET b.Price = b.Price - (b.Price * i.Discount / 100.0)
        FROM Books b
        JOIN inserted i ON b.AuthorId = i.Id;
    END
END;
GO

INSERT INTO Authors (FullName, Discount)
VALUES ('John Tolkien', 0);

INSERT INTO Books (Title, Price, AuthorId)
VALUES 
('Book A', 100, 1),
('Book B', 200, 1);

PRINT 'Prices BEFORE discount:';
SELECT * FROM Books;
GO

UPDATE Authors
SET Discount = 10
WHERE Id = 1;
GO

PRINT 'Prices AFTER 10% discount:';
SELECT * FROM Books;
GO
