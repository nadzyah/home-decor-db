# Home Decor Database Project

> [!NOTE]
> This README file serves as the complete documentation for the
> project. No `*.doc` file is provided.

This project implements a complete database solution for a home
decor online shop application. It consists of two main components:

1. **OLTP (Online Transaction Processing)**: Designed to support
   real-time operational activities.
2. **OLAP (Online Analytical Processing)**: Designed for analytical
   data processing and reporting.

## OLTP Database Schema

The OLTP database is designed in 3NF and consists of the following
tables:

- **CUSTOMER**: Stores user account information.
- **CATEGORY**: Represents product categories with a hierarchical
  structure.
- **PRODUCT**: Contains product details, inventory, and pricing.
- **ORDER**: Tracks customer orders and their statuses.
- **ORDER_ITEM**: Holds the details of products in each order.
- **REVIEW**: Contains customer reviews and ratings for products.
- **ADDRESS**: Stores customer addresses.
- **PAYMENT_METHOD**: Tracks customer payment information.
- **CART**: Represents a customer's shopping cart.
- **CART_ITEM**: Holds items added to a customer's cart.

Please refer to the [oltp/schema.mmd](oltp/schema.mmd) file for the
full ER diagram.

## OLAP Database Schema

The OLAP database follows a **snowflake schema** and includes the
following tables:

### Fact Tables

- **FACT_SALES**: Records sales transactions.
- **FACT_INVENTORY**: Tracks inventory levels over time.

### Dimension Tables

- **DIM_CUSTOMER**: Stores customer information with SCD Type 2
  for tracking changes over time.
- **DIM_PRODUCT**: Contains product details.
- **DIM_CATEGORY**: Represents product category hierarchy.
- **DIM_TIME**: Captures time-related information for analytics.
- **DIM_BRAND**: Stores brand details.

Please refer to the [olap/schema.mmd](olap/schema.mmd) file for the
full snowflake schema.

## Setup Instructions

Before following the steps below, please ensure that you're running
PostgreSQL 12 or higher. Scripts are rerunnable and include mechanisms
to prevent overwriting unchanged data.

Follow these steps to set up and run the project:

1. **Create the OLTP Database**:
   - Run the following command to create the database:
     ```bash
     createdb home_decor_db
     ```
   - Initialise the schema:
     ```bash
     psql -d home_decor_db -f oltp/initialise.sql
     ```
   - Load the initial data:
     ```bash
     psql -d home_decor_db -f oltp/load.sql
     ```

2. **Create the OLAP Database**:
   - Run the following command to create the database:
     ```bash
     createdb home_decor_dw
     ```
   - Initialise the OLAP schema:
     ```bash
     psql -d home_decor_dw -f olap/initialise.sql
     ```

3. **Run the ETL Process**:
   - Transfer data from OLTP to OLAP:
     ```bash
     psql -U postgres -f olap/transfer.sql
     ```

4. **Run Queries for Insights**:
   - OLTP queries:
     ```bash
     psql -U postgres -d home_decor_db -f oltp/queries.sql
     ```
   - OLAP queries:
     ```bash
     psql -U postgres -d home_decor_dw -f olap/queries.sql
     ```

## Power BI Report

The Power BI report [report.pbix](./report.pbix) has been prepared
based on the OLAP database. This report provides analytical insights
with multiple visual components.
