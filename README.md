# Home Decor Items Online Shop App

This project implements a complete database solution for a home decor
e-commerce platform, consisting of:

- OLTP database for operational transactions
- OLAP data warehouse for analytical processing

## Project Structure

```
.
├── olap/                      # Data Warehouse components
│   ├── initialise.sql         # DWH schema creation
│   ├── schema.mmd             # DWH schema visualisation
│   └── transfer.sql           # ETL process
├── oltp/                      # Transactional DB components
│   ├── datasets/              # Source data
│   │   ├── categories.csv
│   │   └── customers.csv
│   ├── initialise.sql         # OLTP schema creation
│   ├── load.sql               # Data loading script
│   └── schema.mmd             # OLTP schema visualisation
└── README.md                  # This file
```

## OLTP Database Schema

The operational database consists of the following main entities:
- **CUSTOMER**: Stores user account information
- **CATEGORY**: Product categories with hierarchy support
- **PRODUCT**: Product information with inventory
- **ORDER**: Order processing and status
- **ORDER_ITEM**: Order line items
- **REVIEW**: Product reviews and ratings
- **ADDRESS**: Customer shipping/billing addresses
- **PAYMENT_METHOD**: Customer payment information
- **CART**: Shopping cart functionality
- **CART_ITEM**: Items in shopping carts

The complete schema can be viewed in
[oltp/schema.mmd](./oltp/schema.mmd)

## OLAP Database Schema

The data warehouse uses a snowflake schema with:

Fact Tables:
- **FACT_SALES**: Sales transactions
- **FACT_INVENTORY**: Product inventory levels

Dimension Tables:
- **DIM_CUSTOMER**: Customer information (SCD Type 2)
- **DIM_PRODUCT**: Product details
- **DIM_CATEGORY**: Product category hierarchy
- **DIM_TIME**: Time dimension
- **DIM_BRAND**: Brand information

The complete schema can be viewed in
[olap/schema.mmd](./olap/schema.mmd)

## Setup Instructions

### Prerequisites

- PostgreSQL 12 or higher
- psql command-line tool

### Installation Steps

1. Create the OLTP database:

```bash
createdb home_decor_db
```

2. Initialise the OLTP schema:

```bash
cd oltp/
psql -d home_decor_db -f initialise.sql
```

3. Load initial OLTP data:

```bash
cd oltp/
psql -d home_decor_db -f load.sql
```

4. Create the OLAP database:

```bash
createdb home_decor_dw
```

5. Initialise the OLAP schema:

```bash
cd olap/
psql -d home_decor_dw -f initialise.sql
```

6. Run the ETL process:

```bash
cd olap/
psql -U postgres -f transfer.sql
```

7. Run queries to get more insights about the data

```bash
psql -U postgres -f oltp/queries.sql
psql -U postgres -f olap/queries.sql
```

## Data Flow

1. Operational data is stored in the OLTP database
2. ETL process extracts data from OLTP
3. Data is transformed according to DWH rules
4. Transformed data is loaded into OLAP
5. OLAP database maintains historical changes (SCD Type 2 for
   customers)

## Notes

- OLTP database optimised for transactions and real-time operations
- OLAP database optimised for analytical queries
- ETL process can be rerun safely (idempotent)
- All scripts include proper error handling and data validation
