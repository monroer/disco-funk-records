USE cs340_previshj;

-- #############################
-- CREATE Customers Procedure
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateCustomer;

DELIMITER //
CREATE PROCEDURE sp_CreateCustomer(
    IN p_name VARCHAR(100),
    IN p_address VARCHAR(255),
    IN p_phoneNumber VARCHAR(15),
    IN p_email VARCHAR(100),
    OUT p_customerID INT
)
BEGIN
    INSERT INTO Customers (name, address, phoneNumber, email)
    VALUES (p_name, p_address, p_phoneNumber, p_email);

    SELECT LAST_INSERT_ID() INTO p_customerID;

    SELECT LAST_INSERT_ID() AS 'new_customerID';
END //
DELIMITER ;


-- #############################
-- UPDATE Customer Procedure
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateCustomer;

DELIMITER //
CREATE PROCEDURE sp_UpdateCustomer(
    IN p_customerID INT,
    IN p_name VARCHAR(100),
    IN p_address VARCHAR(255),
    IN p_phoneNumber VARCHAR(15),
    IN p_email VARCHAR(100)
)
BEGIN 
    DECLARE error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN 
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

        UPDATE Customers
        SET name = p_name,
            address = p_address,
            phoneNumber = p_phoneNumber,
            email = p_email
        WHERE customerID = p_customerID;

        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found for customerID: ', p_customerID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message
        END IF;

    COMMIT;
END //
DELIMITER ;


-- #############################
-- DELETE Customer Procedure
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteCustomer;

DELIMITER //
CREATE PROCEDURE sp_DeleteCustomer(IN p_customerID INT)
BEGIN
    DECLARE error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        DELETE FROM Customers WHERE customerID = p_customerID;

        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found for customerID: ', p_customerID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;
END //
DELIMITER ;


-- #############################
-- CREATE Sale
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateSale;

DELIMITER //

CREATE PROCEDURE sp_CreateSale(
    IN p_customerID INT, 
    IN p_invoiceAmount DECIMAL(10, 2), 
    IN p_paymentType VARCHAR(50), 
    IN p_status ENUM('pending', 'completed', 'cancelled'), 
    IN p_invoiceDate DATETIME,
    OUT p_salesID INT)
BEGIN
    INSERT INTO Sales (customerID, invoiceAmount, paymentType, status, invoiceDate)
    VALUES (p_customerID, p_invoiceAmount, p_paymentType, p_status, p_invoiceDate);

    SELECT LAST_INSERT_ID() into p_salesID;

    SELECT LAST_INSERT_ID() AS 'new_sales_id';
END //

DELIMITER ;


-- #############################
-- UPDATE SALE
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateSale;

DELIMITER //
CREATE PROCEDURE sp_UpdateSale(
    IN p_salesID INT,
    IN p_customerID INT,
    IN p_invoiceAmount DECIMAL(10, 2),
    IN p_paymentType VARCHAR(50),
    IN p_status ENUM('pending', 'completed', 'cancelled'),
    IN p_invoiceDate DATETIME
)
BEGIN 
    DECLARE error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN 
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

        UPDATE Sales
        SET customerID = p_customerID,
            invoiceAmount = p_invoiceAmount,
            paymentType = p_paymentType,
            status = p_status,
            invoiceDate = p_invoiceDate
        WHERE salesID = p_salesID;

        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found for salesID: ', p_salesID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;
END //
DELIMITER ;



-- #############################
-- DELETE SALE
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteSale;

DELIMITER //

CREATE PROCEDURE sp_DeleteSale(IN p_salesID INT)
BEGIN
    DECLARE error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    
    DELETE FROM SalesInventory WHERE salesID = p_salesID;

    DELETE FROM Sales WHERE salesID = p_salesID;

    IF ROW_COUNT() = 0 THEN
        SET error_message = CONCAT('No matching record found for salesID: ', p_salesID);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;

    COMMIT;
END //

DELIMITER ;

-- #############################
-- CREATE Inventory
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateInventory;

DELIMITER //
CREATE PROCEDURE sp_CreateInventory(
    IN p_songID INT,
    IN p_type ENUM('vinyl', 'cassette', 'cd'),
    IN p_quantity INT,
    IN p_price DECIMAL(10, 2),
    OUT p_inventoryID INT)
BEGIN
    START TRANSACTION;

    INSERT INTO Inventory (songID, type, quantity, price)
    VALUES (p_songID, p_type, p_quantity, p_price);

    SELECT LAST_INSERT_ID() INTO p_inventoryID;

    COMMIT;
    
    SELECT p_inventoryID AS new_inventoryID;
END //
DELIMITER ;


-- #############################
-- UPDATE Inventory
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateInventory;

DELIMITER //
CREATE PROCEDURE sp_UpdateInventory(
    IN p_inventoryID INT,
    IN p_songID INT,
    IN p_type ENUM('vinyl', 'cassette', 'cd'),
    IN p_quantity INT,
    IN p_price DECIMAL(10, 2)
)
BEGIN
    DECLARE error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    
        UPDATE Inventory
        SET songID = p_songID,
            type = p_type,
            quantity = p_quantity,
            price = p_price
        WHERE inventoryID = p_inventoryID;

        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found for inventoryID: ', p_inventoryID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;
END //
DELIMITER ;


-- #############################
-- DELETE Inventory
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteInventory;

DELIMITER //
CREATE PROCEDURE sp_DeleteInventory(IN p_inventoryID INT)
BEGIN
    DECLARE error_message VARCHAR(255); 

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    
        DELETE FROM Inventory WHERE inventoryID = p_inventoryID;

        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found for inventoryID: ', p_inventoryID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;



-- #############################
-- CREATE Song Procedure
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateSong;

DELIMITER //

CREATE PROCEDURE sp_CreateSong(
    IN p_title VARCHAR(255), 
    IN p_genre VARCHAR(100),
    IN p_artist VARCHAR(100),
    IN p_album VARCHAR(100),
    IN p_dateReleased YEAR,
    IN p_format ENUM('vinyl', 'cassette', 'cd'),
    OUT p_songID INT)
BEGIN
    DECLARE error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    INSERT INTO Songs (title, genre, artist, album, dateReleased, format)
    VALUES (p_title, p_genre, p_artist, p_album, p_dateReleased, p_format);

    SELECT LAST_INSERT_ID() INTO p_songID;

    SELECT LAST_INSERT_ID() AS 'new_songID';


END //

DELIMITER ;


-- #############################
-- DELETE Song Procedure
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateSong;

DELIMITER //
CREATE PROCEDURE sp_UpdateSong(
    IN p_songID INT,
    IN p_title VARCHAR(255),
    IN p_genre VARCHAR(100),
    IN p_artist VARCHAR(100),
    IN p_album VARCHAR(100),
    IN p_dateReleased YEAR,
    IN p_format ENUM('vinyl', 'cassette', 'cd')
)
BEGIN 
    DECLARE error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN  
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

        UPDATE Songs
        SET title = p_title,
            genre = p_genre,
            artist = p_artist,
            album = p_album, 
            dateReleased = p_dateReleased,
            format = p_format
        WHERE songID = p_songID;

        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found for songID: ', p_songID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;
END // 
DELIMITER ;


-- #############################
-- DELETE Song Procedure
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteSong;

DELIMITER //

CREATE PROCEDURE sp_DeleteSong(IN p_songID INT)
BEGIN
    DECLARE error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    
    IF EXISTS (SELECT 1 FROM SalesInventory WHERE inventoryID IN (SELECT inventoryID FROM Inventory WHERE songID = p_songID)) THEN
        SET error_message = CONCAT('The song with ID ', p_songID, ' cannot be deleted because it is part of an active sale.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;

    IF EXISTS (SELECT 1 FROM Inventory WHERE songID = p_songID) THEN
        SET error_message = CONCAT('The song with ID ', p_songID, ' cannot be deleted because it is part of the inventory.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;

    DELETE FROM Songs WHERE songID = p_songID;

    IF ROW_COUNT() = 0 THEN
        SET error_message = CONCAT('No song found with ID: ', p_songID);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;

    COMMIT;
END //

DELIMITER ;


-- #############################
-- CREATE Supplier Procedure
-- #############################
DROP PROCEDURE IF Exists sp_CreateSupplier;

DELIMITER //
CREATE PROCEDURE sp_CreateSupplier(
    IN p_name VARCHAR(100),
    IN p_address VARCHAR(255),
    IN p_phoneNumber VARCHAR(15),
    IN p_email VARCHAR(100),
    OUT p_supplierID INT
)
BEGIN
    INSERT INTO Suppliers (name, address, phoneNumber, email)
    VALUES (p_name, p_address, p_phoneNumber, p_email);

    SELECT LAST_INSERT_ID() INTO p_supplierID;

    SELECT LAST_INSERT_ID() AS 'new_supplierID';
END //
DELIMITER ;


-- #############################
-- UPDATE Supplier Procedure
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateSupplier;

DELIMITER //
CREATE PROCEDURE sp_UpdateSupplier(
    IN p_supplierID INT,
    IN p_name VARCHAR(100),
    IN p_address VARCHAR(255),
    IN p_phoneNumber VARCHAR(15),
    IN p_email VARCHAR(100)
)
BEGIN 
    DECLARE error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

        UPDATE Suppliers
        SET name = p_name,
            address = p_address,
            phoneNumber = p_phoneNumber,
            email = p_email
        WHERE supplierID = p_supplierID;

        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found for supplierID: ', p_supplierID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;
END //
DELIMITER ;


-- #############################
-- DELETE Supplier Procedure
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteSupplier;

DELIMITER //
CERATE PROCEDURE sp_DeleteSupplier(IN p_supplierID INT)
BEGIN
    DECLARE error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

        DELETE FROM Suppliers WHERE supplierID = p_supplierID;

        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found for supplierID: ', p_supplierID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;
END //
DELIMITER ;


-- #############################
-- CREATE Purchase Procedure
-- #############################
DROP PROCEDURE IF EXISTS sp_CreatePurchase;

DELIMITER // 
CREATE PROCEDURE sp_CreatePurchase(
    IN p_supplierID INT,
    IN p_totalCost DECIMAL(10, 2),
    IN p_status ENUM('pending', 'completed', 'cancelled'),
    IN p_purchaseDate DATETIME,
    OUT p_purchaseID INT
)
BEGIN
    INSERT INTO Purchases (supplierID, totalCost, status, purchaseDate)
    VALUES (p_supplierID, p_totalCost, p_status, p_purchaseDate);

    SELECT LAST_INSERT_ID() INTO p_purchaseID;

    SELECT LAST_INSERT_ID() AS 'new_purchaseID';
END // 
DELIMITER ;


-- #############################
-- UPDATE Purchase Procedure
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdatePurchase;

DELIMITER //
CREATE PROCEDURE sp_UpdatePurchase(
    IN p_purchaseID INT,
    IN p_supplierID INT,
    IN p_totalCost DECIMAL(10, 2),
    IN p_status ENUM('pending', 'completed', 'cancelled'),
    IN p_purchaseDate DATETIME
)
BEGIN 
    DECLARE error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

        UPDATE Purchases
        SET supplierID = p_supplierID,
            totalCost = p_totalCost,
            status = p_status,
            purchaseDate = p_purchaseDate
        WHERE purchaseID = p_purchaseID;

        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found for purchaseID: ', p_purchaseID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;
END // 
DELIMITER ;


-- #############################
-- DELETE Purchase Procedure
-- #############################
DROP PROCEDURE IF EXISTS sp_DeletePurchase;

DELIMITER //
CREATE PROCEDURE sp_DeletePurchase(IN p_purchaseID INT)
BEGIN
    DECLARE error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Delete from intersection table first
    DELETE FROM PurchasesInventory WHERE purchaseID = p_purchaseID;

    -- Then delete the purchase
    DELETE FROM Purchases WHERE purchaseID = p_purchaseID;

    IF ROW_COUNT() = 0 THEN
        SET error_message = CONCAT('No matching record found for purchaseID: ', p_purchaseID);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;

    COMMIT;
END //

DELIMITER ;



-- #############################
-- RESET DATABASE
-- #############################
DROP PROCEDURE IF EXISTS sp_ResetDatabase;

DELIMITER //

CREATE PROCEDURE sp_ResetDatabase()
BEGIN
    -- Disable foreign key checks to prevent errors
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

    
    SET FOREIGN_KEY_CHECKS = 1;
    COMMIT;

END //

DELIMITER ;

