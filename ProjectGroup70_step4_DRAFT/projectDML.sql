-- Disco Funk Records - Data Manipulation Queries
-- cs340 Project - Team Disco Funk (70)
-- Jonathan Prevish, Riley Monroe
--
-- Queries tp support CRUD operations for the Disco Funk Records website.

-- CUSTOMER QUERIES ========================================================================

-- Get all customers for browse customers page
SELECT customerID, name, address, phoneNumber, email
FROM Customers;

-- Get a customer by ID 
SELECT customerID, name, address, phoneNumber, email
FROM Customers
WHERE customerID = @customerIDSelected;

-- Get customer by name (for search functionality)
SELECT customerID, name, address, phoneNumber, email
FROM Customers
WHERE name LIKE CONCAT('%', @searchName, '%');

-- Add a new customer
INSERT INTO Customers (name, address, phoneNumber, email)
VALUES (@nameInput, @addressInput, @phoneNumberInput, @emailInput);

-- Update a customers info
UPDATE Customers
SET name = @nameInput,
    address = @addressInput,
    phoneNumber = @phoneNumberInput,
    email = @emailInput
WHERE customerID = @customerID_Selected;

-- Delete a customer
DELETE FROM Customers
WHERE customerID = @customerID_Selected;


-- SALES QUERIES ===========================================================================

-- Get all sales with customer names for browse sales page
SELECT  Sales.salesID, Sales.invoiceDate, Customers.name AS customerName,
        Sales.invoiceAmount, Sales.paymentType, Sales.status
FROM Sales
INNER JOIN Customers ON Sales.customerID = Customers.customerID
ORDER BY Sales.invoiceDate DESC;

-- Get a single sale by sales ID
SELECT  Sales.salesID, Sales.customerID, Sales.invoiceDate,
        Sales.invoiceAmount, Sales.paymentType, Sales.status
FROM Sales
WHERE salesID = @salesID_Selected;

-- Get all customers for dropdown when adding a new sale
SELECT customerID, name
FROM Customers
ORDER BY name;

-- Add a new sale
INSERT INTO Sales (customerID, invoiceDate, invoiceAmount, paymentType, status)
VALUES  (@customerID_from_dropdown, @invoiceDateInput, @invoiceAmountInput, 
        @paymentTypeInput, @statusInput);

-- Update a sale
UPDATE Sales
SET customerID = @customerID_from_dropdown
    invoiceDate = @invoiceDateInput
    invoiceAmount = @invoiceAmountInput
    paymentType = @paymentTypeInput
    status = @statusInput
WHERE salesID = @salesID_Selected;

-- Delete a sale
DELETE FROM Sales
WHERE salesID = @salesID_Selected;


-- INVENTORY QUERIES =======================================================================

-- Get all inventory items with song details for browse inventory page
SELECT  Inventory.inventoryID, Songs.title, Songs.artist, 
        Inventory.format, Inventory.quantity, Inventory.price
FROM Inventory
INNER JOIN Songs ON Inventory.songID = Songs.songID
ORDER BY Songs.title;

-- Get a single inventory item by ID
SELECT  Inventory.inventoryID, inventory.songID, inventory.format,
        Inventory.quantity, Inventory.price
FROM Inventory
WHERE inventoryID = @inventoryID_Selected;

-- Get all songs for dropdown when adding new inventory
SELECT songID, title, artist
FROM Songs
ORDER BY title;

-- Add a new inventory item
INSERT INTO Inventory (songID, format, quantity, price)
VALUES (@songID_from_dropdown, @formatInput, @quantityInput, @priceInput);

-- Update an inventory item
UPDATE Inventory
SET songID = @songID_from_dropdown
    format = @formatInput
    quantity = @quantityInput
    price = @priceInput
WHERE inventoryID = @inventoryID_Selected;

-- Delete an inventory item
DELETE FROM Inventory
WHERE inventoryID = @inventoryID_Selected;

-- Update inventory quantity for restoking or sales
UPDATE Inventory
SET quantity = quantity + @quantityChange
WHERE inventoryID = @inventoryID_Selected;


-- SONGS QUERIES ===========================================================================

-- Get all songs for browse songs page
SELECT songID, title, genre, artist, album, dateReleased, format
FROM Songs
ORDER BY title;

-- Get a single song by ID
SELECT songID, title, genre, artist, album, dateReleased, format
FROM Songs
WHERE songID = @songID_Selected

-- Search song by title or artist
SELECT songID, title, genre, artist, album, dateReleased, format
FROM Songs
WHERE title LIKE CONCAT('%', @searchName, '%')
    OR artist LIKE CONCAT('%', @searchTerm, '%')
ORDER BY title;

-- Add a new song
INSERT INTO Songs (songID, title, genre, artist, album, dateReleased, format)
VALUES (@titleInput, @genreInput, @artistInput, @albumInput, @dateReleasedInput, @formatInput);

-- Update a song
UPDATE Songs
SET title = @titleInput
    genre = @genreInput
    artist = @artistInput
    album = @albumInput
    dateReleased = @dateReleasedInput
    format = @formatInput
WHERE songID = @songID_Selected;

-- Delete a song
DELETE FROM Songs
WHERE songID = @songID_Selected;


-- SUPPLIERS QUERIES ======================================================================

-- Get all suppliers for browse suppliers page
SELECT supplierID, name, address, phoneNumber, email
FROM Suppliers
ORDER BY name;

-- Get a single supplier by ID
SELECT supplierID, name, address, phoneNumber, email
FROM Suppliers
WHERE supplierID = @supplierID_Selected;

-- Add a new supplier
INSERT INTO Suppliers (supplierID, name, address, phoneNumber, email)
VALUES (@nameInput, @addressInput, @phoneNumberInput, @emailInput);

-- Update a supplier
UPDATE Suppliers
SET name = @nameInput,
    address = @addressInput,
    phoneNumber = @phoneNumberInput,
    email = @emailInput
WHERE supplierID = @supplierID_Selected;

-- Delete a supplier
DELETE FROM Suppliers
WHERE supplierID = @supplierID_Selected;


-- PURCHASES QUERIES =====================================================================

-- Get all purchases with supplier names for browse purchases page
SELECT  Purchases.purchaseID, Purchases.purchaseDate, 
        Suppliers.name AS supplierName, Purchases.totalCost, Purchases.status
FROM Purchases
INNER JOIN Suppliers ON Purchases.supplierID = Suppliers.supplierID
ORDER BY Purchases.purchaseDate DESC;

-- Get a singlew purchase by ID
SELECT purchaseID, supplierID, purchaseDate, totalCost, status
FROM Purchases
WHERE purchaseID = @purchaseID_Selected;

-- Get all suppliers for dropdown when adding new purchase
SELECT supplierID, name
FROM Suppliers
ORDER BY name;

-- Add a new purchase order
INSERT INTO Purchases (supplierID, purchaseDate, totalCost, status)
VALUES (@supplierID_from_dropdown, @purchaseDateInput, @totalCostInput, @statusInput);

-- Update a purchase order
UPDATE Purchases
SET supplierID = @supplierID_from_dropdown
    purchaseDate = @purchaseDateInput
    totalCost = @totalCostInput
    status = @statusInput
WHERE purchaseID = @purchaseID_Selected;

-- Delete a purchase order
DELETE FROM Purchases
WHERE purchaseID = @purchaseID_Selected;


-- SALES INVENTORY QUERIES (INTERSECTION TABLE) =========================================

-- Get all items in a specific sale for viewing sale details
SELECT  SalesInventory.salesInventoryID, Songs.title, Songs.artist,
        Inventory.format, SalesInventory.quantity, Inventory.price,
        (SalesInventory.quantity * Inventory.price) AS lineTotal
FROM SalesInventory
INNER JOIN Inventory ON SalesInventory.inventoryID = Inventory.inventoryID
INNER JOIN Songs ON Inventory.songID = Songs.songID
WHERE SalesInventory.salesID = @salesID_Selected;

-- Get all inventory items for dropdown when adding items to a sale
SELECT  Inventory.inventoryID, Songs.title, Songs.artist,
        Inventory.format, Inventory.price
FROM Inventory
INNER JOIN Songs ON Inventory.songID = Songs.songID
WHERE Inventory.quantity > 0
ORDER BY Songs.title;

-- Add an item to a sale
INSERT INTO SalesInventory (salesID, inventoryID, quantity)
VALUES (@salesID_Selected, @inventoryID_from_dropdown, @quantityInput);

-- Update quantity of an item in a sale
UPDATE SalesInventory
SET quantity = @quantityInput
WHERE salesInventoryID = @salesInventoryID_Selected;

-- Remove an item from a sale
DELETE FROM SalesInventory
WHERE salesInventoryID = @salesInventoryID_Selected;


-- PURCHASES INVENTORY QUERIES (INTERSECTION TABLE)

-- Get all items in a specific purchase order
SELECT  PurchasesInventory.purchasesInventoryID, Songs.title, Songs.artist,
        Inventory.format, PurchasesInventory.quantity
FROM PurchasesInventory
INNER JOIN Inventory ON PurchasesInventory.inventoryID = Inventory.inventoryID
INNER JOIN Songs ON Inventory.songID = Songs.songID
WHERE PurchasesInventory.purchaseID = @purchaseID_Selected;

-- Get all inventory items for dropdown when adding items to a purchase
SELECT Inventory.inventoryID, Songs.title, Songs.artist, Inventory.format
FROM Inventory
INNER JOIN Songs ON Inventory.songID = Songs.songID
ORDER BY Songs.title;

-- Add a new item to a purchase order
INSERT INTO PurchasesInventory (purchaseID, inventoryID, quantity)
VALUES (@purchaseID_Selected, @inventoryID_from_dropdown, @quantityInput);

-- Update quantity of an item in a purchase order
UPDATE PurchasesInventory
SET quantity = @quantityInput
WHERE purchasesInventoryID = @purchasesInventoryID_Selected;

-- Remove an item from a purchase order
DELETE FROM PurchasesInventory
WHERE purchasesInventoryID = @purchasesInventoryID_Selected;

