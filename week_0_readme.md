# Week 0 — Orientation & Setup

## Overview
This week focuses on understanding the data engineering lifecycle and preparing the development environment for upcoming hands-on labs.

## Key Learning Areas
- **Data Engineering Lifecycle:** Source → Ingestion → Storage → Transformation → Serving
- **Development Environment:** Python and Visual Studio Code
- **Version Control:** Git, GitHub, and basic command-line operations
- **Project Organization:** Structured directories for data, SQL, source code, documentation
- **Database Preparation:** Getting ready for SQL practice and database connectivity

## Tools
Python 3.x, Visual Studio Code, Git, GitHub, and mysql setup.

# Practice Dataset — Retail / E-commerce

This folder contains small synthetic CSV files for the CLE Data Engineering hands-on labs.
The files use a retail/e-commerce scenario so later exercises can build on the same data.

## Files

| File | Purpose |
|---|---|
| `customers.csv` | Customer details and segments |
| `products.csv` | Product catalogue and prices |
| `orders.csv` | Order headers, dates, status, and payment method |
| `order_items.csv` | Products and quantities within each order |
| `events.csv` | Order lifecycle events from different sources |

## For realistic data

- Duplicate rows in `orders.csv`, `order_items.csv`, and `events.csv`.
- A missing city in `customers.csv`.
- An invalid date in `orders.csv` (`2026-15-40`).
- A negative quantity in `order_items.csv`.
- A late-arriving event: the delivery event for order `O1005` is dated after the order date and appears later in the event history.
- A changed customer attribute: customer `C002` appears with a different city in the sample records (`customers.csv`). Treat this as a scenario to investigate rather than assuming which value is correct.


## Expected Outcome
A structured repository, a working Python environment, and a tested database connection to support upcoming data engineering exercises.
