Disco Funk Records 

A full-stack record store management web app built with a teammate for a database design course. Manages customers, suppliers, sales, purchases, songs, and inventory across a normalized relational schema.


What It Does

A CRUD web application over a multi-table relational database, letting store staff:

View and manage Customers, Suppliers, and Songs
Track Sales and Purchases, joined against customer/supplier records
Manage Inventory levels tied to the songs catalog
Tech Stack
Backend: Node.js, Express
Templating: Handlebars (express-handlebars)
Database: MySQL (mysql2), hand-written SQL queries with joins across related tables
Frontend: Server-rendered HTML/CSS
Schema Highlights

Data modeled with ER diagramming before implementation, covering one-to-many and many-to-many relationships (e.g., Sales ↔ Customers, Purchases ↔ Suppliers, Inventory ↔ Songs).

Setup
bash
npm install
cp .env.example .env   # fill in your DB host/user/password/database
npm start

App runs on http://localhost:7070.

Team

Built with Jonathan Prevish as a two-person team project.

Note: This app reads its database connection from environment variables (see .env.example) rather than hardcoded credentials.
