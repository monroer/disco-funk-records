-- team 70: Disco Funk
-- Members: Jonathan Prevish, Riley Monroe
-- Disco Funk Records Database

-- Disable commits and Foreign key checks to minumize import errors
SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;

-- Delete tables if they exist (to make way for new tables)
DROP TABLE IF EXISTS SalesInventory;
DROP TABLE IF EXISTS PurchasesInventory;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS Purchases;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Songs;

-- Create Database Tables
CREATE TABLE Customers (
    customerID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phoneNumber VARCHAR(15),
    email VARCHAR(100) UNIQUE
);

CREATE TABLE Sales (
    salesID INT AUTO_INCREMENT PRIMARY KEY,
    customerID INT NOT NULL,
    invoiceDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    invoiceAmount DECIMAL(10, 2) NOT NULL,
    paymentType VARCHAR(50),
    status ENUM('pending', 'completed', 'cancelled') NOT NULL,
    FOREIGN KEY (customerID) REFERENCES Customers(customerID)
);

CREATE TABLE Suppliers (
    supplierID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phoneNumber VARCHAR(15),
    email VARCHAR(100) UNIQUE
);

CREATE TABLE Purchases (
    purchaseID INT AUTO_INCREMENT PRIMARY KEY,
    supplierID INT NOT NULL,
    purchaseDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    totalCost DECIMAL(10, 2),
    status ENUM('pending', 'completed', 'cancelled') NOT NULL,
    FOREIGN KEY (supplierID) REFERENCES Suppliers(supplierID)
);

CREATE TABLE Songs (
    songID INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    genre VARCHAR(100),
    artist VARCHAR(100) NOT NULL,
    album VARCHAR(100),
    dateReleased YEAR,
    format ENUM('vinyl', 'cassette', 'cd') NOT NULL
);

CREATE TABLE Inventory (
    inventoryID INT AUTO_INCREMENT PRIMARY KEY,
    songID INT NOT NULL,
    type ENUM('vinyl', 'cassette', 'cd') NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (songID) REFERENCES Songs(songID)
);

CREATE TABLE SalesInventory (
    salesInventoryID INT AUTO_INCREMENT PRIMARY KEY,
    salesID INT NOT NULL,
    inventoryID INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (salesID) REFERENCES Sales(salesID),
    FOREIGN KEY (inventoryID) REFERENCES Inventory(inventoryID)
);

CREATE TABLE PurchasesInventory (
    purchasesInventoryID INT AUTO_INCREMENT PRIMARY KEY,
    purchaseID INT NOT NULL,
    inventoryID INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (purchaseID) REFERENCES Purchases(purchaseID),
    FOREIGN KEY (inventoryID) REFERENCES Inventory(inventoryID)
);

-- Insert Data into Tables
INSERT INTO Customers (customerID, name, address, phoneNumber, email) 
VALUES 
( 1268, 'John Mann', '742 Evergreen Terrace, Springfield, IL 62701', '(217) 555-1268', 'john.mann@email.com'),
( 1269, 'Tom Redding', '589 Pine Street, Boston, MA 02108', '(617) 555-1269', 'tom.redding@email.com'),
( 1270, 'Mary Marshal', '1024 Cherry Lane, Denver, CO 80202', '(720) 555-1270', 'mary.marshal@email.com'),
( 1271, 'Issac Brown', '1268 DoaksFerry Road NW, Salem, OR 97304', '(304) 231-4655', 'isaacsmb@icloud.com');

INSERT INTO Suppliers (supplierID, name, address, phoneNumber, email)
VALUES 
( 624, 'Josh Bell', '1847 Maple Street, Austin, TX 78701', '(512) 555-0124', 'josh.bell@supplier.com'),
( 625, 'Dragon Joshington', '2901 Oak Avenue, Portland, OR 97204', '(503) 555-0625', 'dragon.j@dragonindustries.com'),
( 626, 'Mike Wazowski', '456 Scare Floor Drive, Monstropolis, CA 90210', '(626) 555-0626', 'm.wazowski@monstersinc.com'),
( 627, 'Tony Romo', '105 Kimbal Crossing, Kimball, TN 37347', '(214) 555-0627', 'tony.romo@romofootball.com');

INSERT INTO Sales (salesID, customerID, invoiceDate, invoiceAmount, paymentType, Status)
VALUES 
(4213, 1268, '2025-10-12', 33.14, 'Visa', 'completed'),
(4214, 1269, '2025-10-12', 52.42, 'MasterCard', 'pending'),
(4215, 1270, '2025-10-13', 42.42, 'Cash', 'pending'),
(4216, 1271, '2025-10-14', 39.84, 'RoBucks', 'cancelled');

INSERT INTO Purchases (purchaseID, supplierID, purchaseDate, totalCost, status)
VALUES
(2259, 624, '2025-10-1', 456.34, 'pending'),
(2260, 625, '2025-10-1', 229.77, 'cancelled'),
(2261, 626, '2025-10-1', 161.33, 'completed'),
(2262, 627, '2025-10-1', 983.31, 'completed');

INSERT INTO Songs (SongID, title, genre, artist, Album, dateReleased, format)
VALUES
(1, "Stayin\' Alive", 'Disco', 'Bee Gees', 'Saturday Night Fever', 1977, 1),
(5, 'Le Freak', 'Disco', 'Chic', "C'est Chic", 1978, 1),
(87, 'Boogie Oogie Oogie', 'Disco', 'A Taste of Honey', 'A Taste of Honey', 1978, 1),
(123, 'I Feel Love', 'Disco', 'Donna Summer', 'I Remember Yesterday', 1977, 3);

INSERT INTO Inventory (InventoryID, SongID, type, quantity, price)
VALUES
(32, 1, 'cassette', 23, '12.34'),
(33, 1, 'vinyl', 45, '15.42'),
(34, 5, 'vinyl', 34, '9.99'),
(35, 87, 'vinyl', 67, '13.01'),
(36, 123, 'vinyl', 187, '16.94');

INSERT INTO PurchasesInventory (purchasesInventoryID, purchaseID, inventoryID, quantity)
VALUES
(2259, 2259, 33, 25),
(2260, 2260, 35, 23),
(2261, 2261, 32, 17),
(2262, 2262, 36, 82);

INSERT INTO SalesInventory (salesInventoryID, salesID, inventoryID, quantity)
VALUES
(4213, 4213, 33, 25),
(4214, 4214, 35, 23),
(4215, 4215, 32, 17),
(4216, 4216, 36, 82);

-- Display all data
SELECT * FROM Customers;
SELECT * FROM Sales;
SELECT * FROM Purchases;
SELECT * FROM Suppliers;
SELECT * FROM Songs;
SELECT * FROM Inventory;
SELECT * FROM SalesInventory;
SELECT * FROM PurchasesInventory;

-- Re-enable foreign Key Checks
SET FOREIGN_KEY_CHECKS=1;
COMMIT;