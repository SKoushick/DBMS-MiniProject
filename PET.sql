CREATE DATABASE ExpenseTracker;
USE ExpenseTracker;

-- Users Table
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    PasswordHash VARCHAR(255),
    Designation varchar(200),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stored Procedure to Add User
DELIMITER $$
CREATE PROCEDURE AddUser(IN p_Name VARCHAR(100), IN p_Email VARCHAR(100), IN p_PasswordHash VARCHAR(255))
BEGIN
    INSERT INTO Users (Name, Email, PasswordHash) VALUES (p_Name, p_Email, p_PasswordHash);
END $$

-- Stored Procedure to Update User
CREATE PROCEDURE UpdateUser(IN p_UserID INT, IN p_Name VARCHAR(100), IN p_Email VARCHAR(100))
BEGIN
    UPDATE Users SET Name = p_Name, Email = p_Email WHERE UserID = p_UserID;
END $$

-- Stored Procedure to Delete User
CREATE PROCEDURE DeleteUser(IN p_UserID INT)
BEGIN
    DELETE FROM Users WHERE UserID = p_UserID;
END $$
DELIMITER ;


-- Categories Table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Name VARCHAR(100),
    Type ENUM('Income', 'Expense'),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Stored Procedure to Add Category
DELIMITER $$
CREATE PROCEDURE AddCategory(IN p_UserID INT, IN p_Name VARCHAR(100), IN p_Type VARCHAR(10))
BEGIN
    IF p_Type IN ('Income', 'Expense') THEN
        INSERT INTO Categories (UserID, Name, Type) VALUES (p_UserID, p_Name, p_Type);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid Category Type!';
    END IF;
END $$

-- Stored Procedure to Delete Category
CREATE PROCEDURE DeleteCategory(IN p_CategoryID INT)
BEGIN
    DELETE FROM Categories WHERE CategoryID = p_CategoryID;
END $$
DELIMITER ;


-- Transactions Table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    CategoryID INT,
    Amount DECIMAL(10,2),
    Description TEXT,
    TransactionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Stored Procedure to Add Transaction
DELIMITER $$
CREATE PROCEDURE AddTransaction(IN p_UserID INT, IN p_CategoryID INT, IN p_Amount DECIMAL(10,2), IN p_Description TEXT)
BEGIN
    INSERT INTO Transactions (UserID, CategoryID, Amount, Description) 
    VALUES (p_UserID, p_CategoryID, p_Amount, p_Description);
END $$

-- Stored Procedure to Delete Transaction
CREATE PROCEDURE DeleteTransaction(IN p_TransactionID INT)
BEGIN
    DELETE FROM Transactions WHERE TransactionID = p_TransactionID;
END $$
DELIMITER ;


-- Budgets Table
CREATE TABLE Budgets (
    BudgetID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    CategoryID INT,
    Amount DECIMAL(10,2),
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Stored Procedure to Set Budget
DELIMITER $$
CREATE PROCEDURE SetBudget(IN p_UserID INT, IN p_CategoryID INT, IN p_Amount DECIMAL(10,2), IN p_StartDate DATE, IN p_EndDate DATE)
BEGIN
    INSERT INTO Budgets (UserID, CategoryID, Amount, StartDate, EndDate) 
    VALUES (p_UserID, p_CategoryID, p_Amount, p_StartDate, p_EndDate);
END $$

-- Stored Procedure to Delete Budget
CREATE PROCEDURE DeleteBudget(IN p_BudgetID INT)
BEGIN
    DELETE FROM Budgets WHERE BudgetID = p_BudgetID;
END $$
DELIMITER ;


-- Reporting Procedures
DELIMITER $$

-- Get total expenses for a user within a date range
CREATE PROCEDURE GetTotalExpenses(IN p_UserID INT, IN p_StartDate DATE, IN p_EndDate DATE)
BEGIN
    SELECT COALESCE(SUM(Amount), 0) AS TotalExpense 
    FROM Transactions 
    WHERE UserID = p_UserID AND TransactionDate BETWEEN p_StartDate AND p_EndDate;
END $$

-- Get expenses by category
CREATE PROCEDURE GetExpensesByCategory(IN p_UserID INT)
BEGIN
    SELECT c.Name AS Category, COALESCE(SUM(t.Amount), 0) AS TotalSpent 
    FROM Transactions t
    JOIN Categories c ON t.CategoryID = c.CategoryID
    WHERE c.Type = 'Expense' AND t.UserID = p_UserID
    GROUP BY c.Name;
END $$

-- Get monthly expenses
CREATE PROCEDURE GetMonthlyExpenses(IN p_UserID INT, IN p_Year INT, IN p_Month INT)
BEGIN
    SELECT COALESCE(SUM(Amount), 0) AS MonthlyExpense 
    FROM Transactions
    WHERE UserID = p_UserID AND YEAR(TransactionDate) = p_Year AND MONTH(TransactionDate) = p_Month;
END $$

DELIMITER ;


INSERT INTO Users (Name, Email, PasswordHash,Designation) VALUES
('Rahul Sharma', 'rahul@email.com', 'hashed_password1','Manager'),
('Sophia Williams', 'sophia@email.com', 'hashed_password2','Software developer'),
('Ethan Brown', 'ethan@email.com', 'hashed_password3','Engineer'),
('Olivia Davis', 'olivia@email.com', 'hashed_password4','Doctor'),
('Mason Wilson', 'mason@email.com', 'hashed_password5','Teacher'),
('Isabella Martinez', 'isabella@email.com', 'hashed_password6','Postman'),
('Liam Thomas', 'liam@email.com', 'hashed_password7','Designer'),
('Ava White', 'ava@email.com', 'hashed_password8','Artist'),
('Noah Garcia', 'noah@email.com', 'hashed_password9','Cricketer'),
('Mia Anderson', 'mia@email.com', 'hashed_password10','Football Coach');


INSERT INTO Categories (UserID, Name, Type) VALUES
(1, 'Freelance Income', 'Income'),
(2, 'Stocks Dividends', 'Income'),
(3, 'Rent', 'Expense'),
(4, 'Medical Bills', 'Expense'),
(5, 'Gym Membership', 'Expense'),
(6, 'Clothing', 'Expense'),
(7, 'Home Maintenance', 'Expense'),
(8, 'Streaming Subscriptions', 'Expense'),
(9, 'Vacation Fund', 'Income'),
(10, 'Charity Donations','Expense');


INSERT INTO Transactions (UserID, CategoryID, Amount, Description) VALUES
(1, 1, 1500.00, 'Freelance project for a client'),
(2, 2, 300.00, 'Stock dividends received'),
(3, 3, 900.00, 'Monthly rent payment'),
(4, 4, 75.50, 'Doctor consultation fee'),
(5, 5, 40.00, 'Monthly gym membership'),
(6, 6, 120.00, 'New clothes shopping'),
(7, 7, 200.00, 'Plumbing repairs at home'),
(8, 8, 15.99, 'Netflix & Spotify subscription'),
(9, 9, 500.00, 'Deposit into vacation savings'),
(10, 10, 50.00, 'Donation to a charity organization');


INSERT INTO Budgets (UserID, CategoryID, Amount, StartDate, EndDate) VALUES
(1, 3, 1000.00, '2025-04-01', '2025-04-30'),
(2, 4, 200.00, '2025-04-01', '2025-04-30'),
(3, 5, 50.00, '2025-04-01', '2025-04-30'),
(4, 6, 150.00, '2025-04-01', '2025-04-30'),
(5, 7, 500.00, '2025-04-01', '2025-04-30'),
(6, 8, 30.00, '2025-04-01', '2025-04-30'),
(7, 9, 800.00, '2025-04-01', '2025-04-30'),
(8, 10, 100.00, '2025-04-01', '2025-04-30'),
(9, 3, 850.00, '2025-04-01', '2025-04-30'),
(10, 4, 180.00, '2025-04-01','2025-04-30');
