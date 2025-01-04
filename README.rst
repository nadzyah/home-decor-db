===========================
Home Decor Database Project
===========================

.. note::
   This README file serves as the complete documentation for the project, as discussed with the teacher. No `.doc` file is provided.

Project Overview
================

This project implements a complete database solution for a home decor
e-commerce platform. It consists of two main components:

1. **OLTP (Online Transaction Processing)**: Designed to support real-time operational activities.
2. **OLAP (Online Analytical Processing)**: Designed for analytical data processing and reporting.

OLTP Database Schema
====================

The OLTP database is designed in **3NF** and consists of the following tables:

- **CUSTOMER**: Stores user account information.
- **CATEGORY**: Represents product categories with a hierarchical structure.
- **PRODUCT**: Contains product details, inventory, and pricing.
- **ORDER**: Tracks customer orders and their statuses.
- **ORDER_ITEM**: Holds the details of products in each order.
- **REVIEW**: Contains customer reviews and ratings for products.
- **ADDRESS**: Stores customer addresses.
- **PAYMENT_METHOD**: Tracks customer payment information.
- **CART**: Represents a customer's shopping cart.
- **CART_ITEM**: Holds items added to a customer's cart.

**Keys and Constraints**:
- Each table has primary keys (`PK`) and appropriate foreign keys (`FK`) to maintain referential integrity.
- Constraints include `CHECK` (e.g., to ensure valid prices and ratings) and `UNIQUE` (e.g., to prevent duplicate product names for the same brand).

**Schema Diagram**:
Refer to the `oltp/schema.mmd` file for the full ER diagram.

OLAP Database Schema
====================

The OLAP database follows a **snowflake schema** and includes the following tables:

**Fact Tables**:
- **FACT_SALES**: Records sales transactions.
- **FACT_INVENTORY**: Tracks inventory levels over time.

**Dimension Tables**:
- **DIM_CUSTOMER**: Stores customer information with **SCD Type 2** for tracking changes over time.
- **DIM_PRODUCT**: Contains product details.
- **DIM_CATEGORY**: Represents product category hierarchy.
- **DIM_TIME**: Captures time-related information for analytics.
- **DIM_BRAND**: Stores brand details.

**Keys and Constraints**:
- All dimensions have primary keys (`PK`), and foreign keys (`FK`) link fact tables to dimension tables.
- Constraints ensure data integrity and valid relationships.

**Schema Diagram**:
Refer to the `olap/schema.mmd` file for the full snowflake schema.

Setup Instructions
==================

Follow these steps to set up and run the project:

1. **Create the OLTP Database**:
   - Run the following command to create the database:
     ::
       createdb home_decor_db

   - Initialize the schema:
     ::
       psql -d home_decor_db -f oltp/initialise.sql

   - Load the initial data:
     ::
       psql -d home_decor_db -f oltp/load.sql

2. **Create the OLAP Database**:
   - Run the following command to create the database:
     ::
       createdb home_decor_dw

   - Initialize the OLAP schema:
     ::
       psql -d home_decor_dw -f olap/initialise.sql

3. **Run the ETL Process**:
   - Transfer data from OLTP to OLAP:
     ::
       psql -U postgres -f olap/transfer.sql

4. **Run Queries for Insights**:
   - OLTP queries:
     ::
       psql -U postgres -f oltp/queries.sql

   - OLAP queries:
     ::
       psql -U postgres -f olap/queries.sql

Notes
=====
- Ensure that PostgreSQL 12 or higher is installed.
- Scripts are rerunnable and include mechanisms to prevent overwriting unchanged data.
- The ETL process handles data transformations and maintains historical data integrity.

Power BI Report
===============
A Power BI report (`report.pbix`) has been prepared based on the OLAP database. This report provides analytical insights with multiple visual components.
