/*
 * Disco Funk Records - Web Application Server
 * CS340 Project - Team Disco Funk (70)
 * Members: Jonathan Prevish, Riley Monroe
 */

// Citation for the CREATE and UPDATE routes
// Date: 11/20/25
// based on the ones found at:
// Source URL: https://canvas.oregonstate.edu/courses/2017561/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=25645149

// express
const express = require('express');
const app = express();
const exphbs = require('express-handlebars');
app.use(express.json());
app.use(express.urlencoded({extended: true}));
app.use(express.static('public'));

// Initialize express application
const dbConnectionPool = require('./db-connector');  

// Port configuration
const PORT = 7070;

// Configure handlebars
const hbs = exphbs.create({
    extname: '.hbs',
    defaultLayout: 'main',
    helpers: {
        eq: (a, b) => a == b
    }
});

app.engine('.hbs', hbs.engine);
app.set('view engine', '.hbs');

hbs.handlebars.registerHelper('json', function(context) {
    return JSON.stringify(context, null, 2);
});


// Test database connection
(async () => {
    try {
        await dbConnectionPool.query('SELECT 1');
        console.log('Database connection successful');
    } catch (error) {
        console.log('Database connection failed :(');
        console.log(error);
    }
})();

//test route:
app.post('/customers-debug', function(req, res) {
  console.log('DEBUG /customers-debug body:', req.body);
  res.status(200).send('OK');
})


/*
 * ROUTES
 */

// =========================
// Homepage
// =========================
app.get('/', function(req, res) {
    res.render('index');
});

// =========================
// CUSTOMER
// =========================

// READ for customers
app.get('/customers', async function (req, res) {
    try {
        const query = `SELECT customerID, name, address, phoneNumber, email FROM Customers;`;

        const [customers] = await dbConnectionPool.query(query);

        res.render('customers', { customers: customers });
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});


// CREATE ROUTES for Customers
app.post('/customers/create', async function (req, res) {
    try {
        let data = req.body;

        // Cleanse and validate data.
        if (typeof data.phoneNumber !== 'string' || data.phoneNumber.length > 15)
            data.phoneNumber = null;

        const query = `CALL sp_CreateCustomer(?, ?, ?, ?, @new_customerID);`;

        
        await dbConnectionPool.execute(query, [
            data.name,          // customer name
            data.address,       // customer address
            data.phoneNumber,   // customer phone number
            data.email,         // customer email
        ]);

        
        const [[result]] = await dbConnectionPool.query('SELECT @new_customerID AS new_customerID');

        console.log(`Customer created. ID: ${result.new_customerID}, Name: ${data.name}`);

   
        res.redirect('/customers');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});


// UPDATE Customer
app.post('/customers/update', async function (req, res) {
    try {
        let data = req.body;

        // Cleanse and validate data
        if (typeof data.phoneNumber !== 'string' || data.phoneNumber.length > 15)
            data.phoneNumber = null;

        const query = 'CALL sp_UpdateCustomer(?, ?, ?, ?, ?);';

        await dbConnectionPool.execute(query, [
            data.customerID,    // customer ID to update
            data.name,          // customer name
            data.address,       // customer address
            data.phoneNumber,   // customer phone number
            data.email,         // customer email
        ]);

        console.log('Customer updated. ID: ${data.customerID}');
        res.redirect('/customers');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});


// DELETE ROUTE for Customers
app.post('/customers/delete', async function (req, res) {
    try {
        // Parse the form
        let data = req.body;

        const query = `CALL sp_DeleteCustomer(?);`;
        await dbConnectionPool.execute(query, [data.customerID]);

        console.log(`DELETE customer. ID: ${data.customerID}`);

        res.redirect('/customers');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send('An error occurred while executing the database queries.');
    }
});



// =========================
// SALE
// =========================
app.get('/sales', async function (req, res) {
    try {
        const query = `
            SELECT s.salesID, s.customerID, s.invoiceDate, s.invoiceAmount, s.paymentType, s.status, 
                   c.name AS customerName
            FROM Sales s
            JOIN Customers c ON s.customerID = c.customerID;
        `;
        
        const customersQuery = 'SELECT customerID, name FROM Customers ORDER BY name;';

        const [sales] = await dbConnectionPool.query(salesQuery);
        const [customers] = await dbConnectionPool.query(customersQuery);

        res.render('sales', { sales: sales, customers: customers });
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});



//CREATE sales
app.post('/sales/create', async function (req, res) {
    try {
        let data = req.body;

        const query = `CALL sp_CreateSale(?, ?, ?, ?, ?, @new_salesID);`;

        await dbConnectionPool.execute(query, [
            data.customerID,        // customerID (selected by user)
            data.invoiceAmount,     // invoiceAmount (form data)
            data.paymentType,       // paymentType (form data)
            data.status,            // status (form data)
            data.invoiceDate,       // invoiceDate (form data)
        ]);

        const [[result]] = await dbConnectionPool.query('SELECT @new_salesID AS new_salesID');
        console.log(`Sale created. ID: ${result.new_salesID}`);

        res.redirect('/sales');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send('An error occurred while creating the sale.');
    }
});

// UPDATE sale
app.post('/sales/update', async function (req, res) {
    try {
        let data = req.body;

        const query = 'CALL sp_UpdateSale(?, ?, ?, ?, ?, ?);';

        await dbConnectionPool.execute(query, [
            data.salesID,       // salesID to update
            data.customerID,    // customerID (selected by user)
            data.invoiceAmount, // invoiceAmount (form data)
            data.paymentType,   // paymentType (form data)
            data.status,        // status (form data)
            data.invoiceDate,   // invoiceDate (form data)
        ]);

        console.log('Sale updated. ID: ${data.salesID}');
        res.redirect('/sales');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while updating the sale.');
    }
});


// DELETE sale
app.post('/sales/delete', async function (req, res) {
    try {
        // Parse the form 
        let data = req.body;

        const query = `CALL sp_DeleteSale(?);`;
        await dbConnectionPool.execute(query, [data.salesID]);

        console.log(`DELETE sale. ID: ${data.salesID}`);

        // Redirect the user to the updated sales list page
        res.redirect('/sales');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while deleting the sale.');
    }
});



// =========================
// INVENTORY
// =========================

// READ inventory
app.get('/inventory', async function (req, res) {
    try {
        const query = `
            SELECT i.inventoryID, i.songID, s.title, s.artist, i.type AS format, i.quantity, i.price
            FROM Inventory i
            JOIN Songs s ON i.songID = s.songID;
        `;

        const songsQuery = 'SELECT songID, title, artist FROM Songs ORDER BY title;';

        const [inventory] = await dbConnectionPool.query(inventoryQuery);
        const [songs] = await dbConnectionPool.query(songsQuery)

        res.render('inventory', { inventory: inventory });
    } catch (error) {
        console.error('Error executing query:', error);
        res.status(500).send('An error occurred while fetching inventory data.');
    }
});




// CREATE inventory
app.post('/inventory/create', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Cleanse and validate data
        if (isNaN(parseInt(data.quantity)) || isNaN(parseFloat(data.price))) {
            return res.status(400).send('Invalid data. Please check your input.');
        }

        const query = `CALL sp_CreateInventory(?, ?, ?, ?, @new_inventoryID);`;

        await dbConnectionPool.execute(query, [
            data.songID,       // songID (linked to Songs table)
            data.type,         // type (vinyl/cassette/cd)
            data.quantity,     // quantity
            data.price,        // price
        ]);

        // Retrieve the newly created inventory ID from the stored procedure's output
        const [[result]] = await dbConnectionPool.query('SELECT @new_inventoryID AS new_inventoryID');

        console.log(`Inventory created. ID: ${result.new_inventoryID}, Song ID: ${data.songID}`);

        res.redirect('/inventory');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});


// UPDATE Inventory
app.post('/inventory/update', async function (req, res) {
    try {
        let data = req.body;

        // Cleanse and validate data
        if (isNaN(parseInt(data.quantity)) || isNaN(parseFloat(data.price))) {
            return res.status(400).send('Invalid data. Please check your input.');
        }

        const query = 'CALL sp_UpdateInventory(?, ?, ?, ?, ?);';

        await dbConnectionPool.execute(query, [
            data.inventoryID,  // inventoryID to update
            data.songID,       // songID (linked to Songs table)
            data.type,         // type (vinyl/cassette/cd)
            data.quantity,     // quantity
            data.price,        // price
        ]);

        console.log(`Inventory updated. ID: ${data.inventoryID}`);
        res.redirect('/inventory');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});


// DELETE Inventory
app.post('/inventory/delete', async function (req, res) {
    try {
        // Get the inventoryID from the request body
        let data = req.body;
        let inventoryID = data.inventoryID;

        const query = `CALL sp_DeleteInventory(?);`;
        await dbConnectionPool.execute(query, [inventoryID]);

        console.log(`Inventory deleted. ID: ${inventoryID}`);

        // Redirect back to the inventory list page
        res.redirect('/inventory');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});



// =========================
// SONG
// =========================
// READ songs
app.get('/songs', async function (req, res) {
    try {
        const query = `SELECT songID, title, genre, artist, album, dateReleased, format FROM Songs;`;

        const [songs] = await dbConnectionPool.query(query);

        res.render('songs', { songs: songs });
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});

// CREATE song
app.post('/songs/create', async function (req, res) {
    try {
        let data = req.body;

        if (typeof data.title !== 'string' || data.title.trim() === '') {
            data.title = null;
        }

        const query = `CALL sp_CreateSong(?, ?, ?, ?, ?, ?, @new_songID);`;

        await dbConnectionPool.execute(query, [
            data.title,          // song title
            data.genre,          // song genre
            data.artist,         // song artist
            data.album,          // song album
            data.dateReleased,   // song release date (year)
            data.format,         // song format (vinyl, cassette, or cd)
        ]);

        // Retrieve the newly created song ID from the stored procedure's output
        const [[result]] = await dbConnectionPool.query('SELECT @new_songID AS new_songID');

        console.log(`Song created. ID: ${result.new_songID}, Title: ${data.title}`);

        // Redirect the user to the updated songs list page
        res.redirect('/songs');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send('An error occurred while executing the database queries.');
    }
});


// UPDATE song
app.post('/songs/update', async function (req, res) {
    try {
        let data = req.body;

        if (typeof data.title !== 'string' || data.title.trim() === '') {
            data.title = null;
        }
        
        const query = 'CALL sp_UpdateSong(?, ?, ?, ?, ?, ?, ?);';

        await dbConnectionPool.execute(query, [
            data.songID,        // songID to update
            data.title,         // song title
            data.genre,         // song genre
            data.artist,        // song artist
            data.album,         // song album
            data.dateReleased,  // song release date (year)
            data.format,        // song format (vinyl, cassette, or cd)
        ]);

        console.log(`Song updated. ID: ${data.songID}`);
        res.redirect('/songs');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while updating the song.');
    }
});


// DELETE song
app.post('/songs/delete', async function (req, res) {
    try {
        // Parse the form 
        let data = req.body;
        
        const query = `CALL sp_DeleteSong(?);`;
        await dbConnectionPool.execute(query, [data.songID]);

        console.log(`DELETE song. ID: ${data.songID}`);
        
        res.redirect('/songs');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while deleting the song.');
    }
});




// =========================
// SUPPLIER
// =========================

// READ supplier
app.get('/suppliers', async function (req, res) {
    try {
        const query = `SELECT supplierID, name, address, phoneNumber, email FROM Suppliers;`;

        const [suppliers] = await dbConnectionPool.query(query);

        res.render('suppliers', { suppliers: suppliers });
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});


// CREATE supplier
app.post('/suppliers/create', async function (req, res) {
    try {
        let data = req.body;

        // Cleanse and validate data
        if (typeof data.phoneNumber !== 'string' || data.phoneNumber.length > 15)
            data.phoneNumber = null;

        const query = 'CALL sp_UpdateSupplier(?, ?, ?, ?, @new_supplierID);';

        await dbConnectionPool.execute(query, [
            data.name,          // supplier name
            data.address,       // supplier address
            data.phoneNumber,   // supplier phone number
            data.email,         // supplier email
        ]);

        const [[result]] = await dbConnectionPool.query('SELECT @new_supplierID AS new_supplierID');
        console.log(`Supplier created. ID: ${result.new_supplierID}, Name: ${data.name}`);

        res.redirect('/suppliers');
    } catch {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});


// edit supplier (form)


// UPDATE supplier
app.post('/suppliers/update', async function (req, res) {
    try {
        let data = req.body;

        // Cleanse and validate data
        if (typeof data.phoneNumber !== 'string' || data.phoneNumber.length > 15)
            data.phoneNumber = null;

        const query = `CALL sp_UpdateSupplier(?, ?, ?, ?, ?);`;

        await dbConnectionPool.execute(query, [
            data.supplierID,    // supplier ID to update
            data.name,          // supplier name
            data.address,       // supplier address
            data.phoneNumber,   // supplier phone number
            data.email,         // supplier email
        ]);

        console.log(`Supplier updated. ID: ${data.supplierID}`);
        res.redirect('/suppliers');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});


// DELETE supplier
app.post('/suppliers/delete', async function (req, res) {
    try {
        let data = req.body;

        const query = `CALL sp_DeleteSupplier(?);`;
        await dbConnectionPool.execute(query, [data.supplierID]);

        console.log(`DELETE supplier. ID: ${data.supplierID}`);
        res.redirect('/suppliers');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});



// =========================
// PURCHASE
// =========================

// READ purchase
app.get('/purchases', async function (req, res) {
    try {
        const purchasesQuery = `
            SELECT p.purchaseID, p.supplierID, p.purchaseDate, p.totalCost, p.status,
                   s.name AS supplierName
            FROM Purchases p
            JOIN Suppliers s ON p.supplierID = s.supplierID;
        `;

        const suppliersQuery = `SELECT supplierID, name FROM Suppliers ORDER BY name;`;

        const [purchases] = await dbConnectionPool.query(query);
        const [suppliers] = await dbConnectionPool.query(suppliersQuery);

        res.render('purchases', { purchases: purchases, suppliers: suppliers });
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});


// CREATE Purchase
app.post('/purchases/create', async function (req, res) {
    try {
        let data = req.body;

        const query = `CALL sp_CreatePurchase(?, ?, ?, ?, @new_purchaseID);`;

        await dbConnectionPool.execute(query, [
            data.supplierID,    // supplierID (selected by user)
            data.totalCost,     // totalCost (form data)
            data.status,        // status (form data)
            data.purchaseDate,  // purchaseDate (form data)
        ]);

        const [[result]] = await dbConnectionPool.query('SELECT @new_purchaseID AS new_purchaseID');
        console.log(`Purchase created. ID: ${result.new_purchaseID}`);

        res.redirect('/purchases');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while creating the purchase.');
    }
});


// EDIT purchase


// UPDATE purchase
app.post('/purchases/update', async function (req, res) {
    try {
        let data = req.body;

        const query = `CALL sp_UpdatePurchase(?, ?, ?, ?, ?);`;

        await dbConnectionPool.execute(query, [
            data.purchaseID,    // purchaseID to update
            data.supplierID,    // supplierID (selected by user)
            data.totalCost,     // totalCost (form data)
            data.status,        // status (form data)
            data.purchaseDate,  // purchaseDate (form data)
        ]);

        console.log(`Purchase updated. ID: ${data.purchaseID}`);
        res.redirect('/purchases');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while updating the purchase.');
    }
});


// DELETE purchase
app.post('/purchases/delete', async function (req, res) {
    try {
        let data = req.body;

        const query = `CALL sp_DeletePurchase(?);`;
        await dbConnectionPool.execute(query, [data.purchaseID]);

        console.log(`DELETE purchase. ID: ${data.purchaseID}`);
        res.redirect('/purchases');
    } catch (error) {
        console.error('Error executing queries:', error);
        res.status(500).send('An error occurred while deleting the purchase.');
    }
});


// =========================
// RESET DATABASE
// =========================
app.post('/reset', async (req, res) => {
    try {
        await dbConnectionPool.query('CALL sp_ResetDatabase();');

        
        res.redirect(req.get('referer'));
    } catch (error) {
        console.error('Error during reset operation:', error);
        res.status(500).send('An error occurred while resetting the database.');
    }
});




// Start server
app.listen(PORT, function() {
    console.log('==================================');
    console.log('Disco Funk Records Server Started');
    console.log('Express server listening on port ' + PORT);
    console.log('==================================');
});
