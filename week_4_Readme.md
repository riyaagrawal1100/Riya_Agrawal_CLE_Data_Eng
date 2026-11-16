# Week 4 – Sales Data Dimensional Modelling

## About the Project
This project is about organizing sales data so that it becomes easier to understand and analyse.

I created a simple database using SQLite and used a Star Schema to organize the data.

## Technologies Used
- SQLite
- SQL
- VS Code

## Database Tables
The project contains 4 main tables:

1. **dim_customer** – Stores customer information.
2. **dim_product** – Stores product information.
3. **dim_date** – Stores date information.
4. **fact_sales** – Stores sales transactions.

## What Does This Project Do?
- Creates a sales database.
- Organizes data into different tables.
- Connects the tables using a Star Schema.
- Stores sales details like quantity and price.
- Helps calculate total sales revenue.

## How to Run the Project
1. Open the project folder in VS Code.
2. Open the `lab4_sales_model.sql` file.
3. Open your SQLite database (`week4.db`).
4. Execute the SQL queries.


## Expected Output
- Total Records: 5
- Total Quantity Sold: 12
- Total Revenue: ₹53,200

## Conclusion
This project helped me understand how sales data can be organized using SQL and a Star Schema. It also gave me basic knowledge of fact tables, dimension tables, and data analysis.
