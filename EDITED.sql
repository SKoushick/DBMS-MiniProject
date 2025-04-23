-- Create the database and use it
CREATE DATABASE IF NOT EXISTS ExpenseTracker;
USE ExpenseTracker;

-- Users Table
CREATE TABLE IF NOT EXISTS Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    PasswordHash VARCHAR(255),
    Designation VARCHAR(200),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stored Procedures for User Management
DELIMITER $$

CREATE PROCEDURE AddUser(IN p_Name VARCHAR(100), IN p_Email VARCHAR(100), IN p_PasswordHash VARCHAR(255))
BEGIN
    INSERT INTO Users (Name, Email, PasswordHash) VALUES (p_Name, p_Email, p_PasswordHash);
END $$

CREATE PROCEDURE UpdateUser(IN p_UserID INT, IN p_Name VARCHAR(100), IN p_Email VARCHAR(100))
BEGIN
    UPDATE Users SET Name = p_Name, Email = p_Email WHERE UserID = p_UserID;
END $$

CREATE PROCEDURE DeleteUser(IN p_UserID INT)
BEGIN
    DELETE FROM Users WHERE UserID = p_UserID;
END $$

DELIMITER ;

-- Categories Table
CREATE TABLE IF NOT EXISTS Categories (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Name VARCHAR(100),
    Type ENUM('Income', 'Expense'),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Stored Procedures for Category Management
DELIMITER $$

CREATE PROCEDURE AddCategory(IN p_UserID INT, IN p_Name VARCHAR(100), IN p_Type VARCHAR(10))
BEGIN
    IF p_Type IN ('Income', 'Expense') THEN
        INSERT INTO Categories (UserID, Name, Type) VALUES (p_UserID, p_Name, p_Type);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid Category Type!';
    END IF;
END $$

CREATE PROCEDURE DeleteCategory(IN p_CategoryID INT)
BEGIN
    DELETE FROM Categories WHERE CategoryID = p_CategoryID;
END $$

DELIMITER ;

-- Transactions Table
CREATE TABLE IF NOT EXISTS Transactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    CategoryID INT,
    Amount DECIMAL(10,2),
    Description TEXT,
    TransactionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Stored Procedures for Transaction Management
DELIMITER $$

CREATE PROCEDURE AddTransaction(IN p_UserID INT, IN p_CategoryID INT, IN p_Amount DECIMAL(10,2), IN p_Description TEXT)
BEGIN
    INSERT INTO Transactions (UserID, CategoryID, Amount, Description) 
    VALUES (p_UserID, p_CategoryID, p_Amount, p_Description);
END $$

CREATE PROCEDURE DeleteTransaction(IN p_TransactionID INT)
BEGIN
    DELETE FROM Transactions WHERE TransactionID = p_TransactionID;
END $$

DELIMITER ;

-- Budgets Table
CREATE TABLE IF NOT EXISTS Budgets (
    BudgetID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    CategoryID INT,
    Amount DECIMAL(10,2),
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Stored Procedures for Budget Management
DELIMITER $$

CREATE PROCEDURE SetBudget(IN p_UserID INT, IN p_CategoryID INT, IN p_Amount DECIMAL(10,2), IN p_StartDate DATE, IN p_EndDate DATE)
BEGIN
    INSERT INTO Budgets (UserID, CategoryID, Amount, StartDate, EndDate) 
    VALUES (p_UserID, p_CategoryID, p_Amount, p_StartDate, p_EndDate);
END $$

CREATE PROCEDURE DeleteBudget(IN p_BudgetID INT)
BEGIN
    DELETE FROM Budgets WHERE BudgetID = p_BudgetID;
END $$

DELIMITER ;

-- Reporting Procedures
DELIMITER $$

CREATE PROCEDURE GetTotalExpenses(IN p_UserID INT, IN p_StartDate DATE, IN p_EndDate DATE)
BEGIN
    SELECT COALESCE(SUM(Amount), 0) AS TotalExpense 
    FROM Transactions 
    WHERE UserID = p_UserID AND TransactionDate BETWEEN p_StartDate AND p_EndDate;
END $$

CREATE PROCEDURE GetExpensesByCategory(IN p_UserID INT)
BEGIN
    SELECT c.Name AS Category, COALESCE(SUM(t.Amount), 0) AS TotalSpent 
    FROM Transactions t
    JOIN Categories c ON t.CategoryID = c.CategoryID
    WHERE c.Type = 'Expense' AND t.UserID = p_UserID
    GROUP BY c.Name;
END $$

CREATE PROCEDURE GetMonthlyExpenses(IN p_UserID INT, IN p_Year INT, IN p_Month INT)
BEGIN
    SELECT COALESCE(SUM(Amount), 0) AS MonthlyExpense 
    FROM Transactions
    WHERE UserID = p_UserID AND YEAR(TransactionDate) = p_Year AND MONTH(TransactionDate) = p_Month;
END $$

DELIMITER ;

-- Validate User Login and Return User Details
DELIMITER $$

CREATE PROCEDURE ValidateUserLogin(IN p_Email VARCHAR(100), IN p_PasswordHash VARCHAR(255))
BEGIN
    DECLARE v_UserID INT;
    DECLARE v_Name VARCHAR(100);
    DECLARE v_Email VARCHAR(100);
    DECLARE v_Designation VARCHAR(200);
    DECLARE v_CreatedAt TIMESTAMP;

    SELECT UserID, Name, Email, Designation, CreatedAt
    INTO v_UserID, v_Name, v_Email, v_Designation, v_CreatedAt
    FROM Users
    WHERE Email = p_Email AND PasswordHash = p_PasswordHash;

    IF v_UserID IS NOT NULL THEN
        SELECT v_UserID AS UserID, v_Name AS Name, v_Email AS Email, v_Designation AS Designation, v_CreatedAt AS CreatedAt;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email or password';
    END IF;
END $$

DELIMITER ;

-- Sample Data Insertion
INSERT INTO Users (Name, Email, PasswordHash, Designation) VALUES
('Rahul Sharma', 'rahul@email.com', 'hashed_password1', 'Manager'),
('Sophia Williams', 'sophia@email.com', 'hashed_password2', 'Software Developer'),
('Ethan Brown', 'ethan@email.com', 'hashed_password3', 'Engineer'),
('Olivia Davis', 'olivia@email.com', 'hashed_password4', 'Doctor'),
('Mason Wilson', 'mason@email.com', 'hashed_password5', 'Teacher'),
('Isabella Martinez', 'isabella@email.com', 'hashed_password6', 'Postman'),
('Liam Thomas', 'liam@email.com', 'hashed_password7', 'Designer'),
('Ava White', 'ava@email.com', 'hashed_password8', 'Artist'),
('Noah Garcia', 'noah@email.com', 'hashed_password9', 'Cricketer'),
('Mia Anderson', 'mia@email.com', 'hashed_password10', 'Football Coach');


 
