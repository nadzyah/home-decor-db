# Home decor items online shop app

This project implements a PostgreSQL database for a home decor
e-commerce platform. The database supports core e-commerce
functionality including user management, product catalog, order
processing, reviews, and payment handling.

## Database Schema

The database consists of the following main entities:

- **CUSTOMER**: Stores user account information
- **CATEGORY**: Product categories
- **PRODUCT**: Product information with inventory
- **ORDER**: Order processing and status
- **ORDER_ITEM**: Order line items
- **REVIEW**: Product reviews and ratings
- **ADDRESS**: Customer shipping/billing addresses
- **PAYMENT_METHOD**: Customer payment information

The schema can be checked in [schema.mmd](./schema.mmd) Mermaid file

## Setup Instructions

### Prerequisites

- PostgreSQL 12 or higher
- psql command-line tool

### Installation Steps

1. Create a new database in PostgreSQL shell:

```postgres
CREATE DATABASE home_decor_db
```

2. Initialize the database schema:

```bash
psql -d home_decor_db -f initialise.sql
```

3. Load sample data:

```bash
psql -d home_decor_db -f load.sql
```
