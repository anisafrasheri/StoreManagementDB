# StoreManagementDB
This project aims to create a comprehensive Oracle database schema for managing a market. The database will include essential tables, procedures, and triggers to handle various aspects of market operations such as inventory management, sales, supplier management, and customer relations.

## Requirements
The following functionalities and requirements must be implemented:
- **Category of Items**
- Manage categories for items.
- **Items** 
- Fields: name, category, sale price, unit, etc.
- Manage market items and their details.
- **Supplier**
- Fields: NIPT (tax identification number), name, address, contact information.
- Manage suppliers providing items to the market.
- **Supplies**
- Record incoming supplies to the market warehouse.
- **Warehouse and Inventory**
- Track the inventory status of items in the warehouse.
- **Customer**
- Fields: first name, last name, phone number, address.
- **Membership card with credit**
- Manage customer information and membership details.
- **Seller**
- Also serves as a system user.
- Manage seller details and system access.
- **Sales Receipt**
- Record market sales transactions.
- **Point of Sale**
- Location/table of sale.
- Manage sales points within the market.
- **Daily Activity Closure**
- Record the cash register status for each seller at the end of the day.
- **Supply and Sales Procedures**
- Procedures to manage supply and sales, including the ability to cancel them by generating corresponding negative value receipts.
- Implemented through database procedures.
- **Trigger for Sales**
- Ensure no sales can be made if the item quantity in inventory is zero.
- Implemented using triggers.

## Getting Started
1. Setup the Database
- Ensure you have Oracle Database installed.
- Execute the provided SQL scripts to create the schema and necessary objects.
2. Populate Initial Data
- Insert initial data into tables for testing and demonstration purposes.
3. Test Functionality
- Use provided example queries and procedures to test the database functionality.

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
