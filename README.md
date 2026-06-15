# 🛒 Tijartik

A real-time data intelligence platform for the Egyptian e-commerce market, built as an ITI graduation project by the Baraka Team (Tanta, Power BI Development Track).

The platform ingests raw e-commerce data, runs it through a full Medallion pipeline on Databricks, stores a warehouse in Azure SQL, and surfaces insights through 20 Power BI dashboards, 6 SSRS reports, a RAG chatbot, and a live AI alert layer — all scheduled and running in production.

---

## The Problem

Egyptian e-commerce platforms operate with limited visibility into their own marketplace. Sellers have no structured way to benchmark performance, platform operators cannot detect risks proactively, and there is no unified layer connecting raw transactions to business decisions.

---

## What Tijartik Does

**Platform View** — a 10-page intelligence hub for marketplace operators covering revenue, logistics, seller health, COD risk, regional delays, and anomaly detection.

**Seller View** — a 10-page personalized dashboard per seller covering sales analysis, demand insights, product performance, fulfillment, customer segmentation, and AI-generated recommendations with estimated revenue opportunity.

**AI Layer** — a RAG chatbot where sellers ask natural language questions and receive answers grounded in their actual warehouse data. Backed by an executive morning briefing that surfaces critical alerts, risks, and opportunities automatically.

---

## Architecture

```
Kaggle (Olist Dataset)
    └── Python adaptation to Egyptian market context
        └── Azure SQL OLTP (source database)
            └── Databricks ELT Pipeline
                ├── Bronze  — raw ingestion, immutable
                ├── Silver  — cleaning, validation, business rules
                └── Gold    — star schema, fact + dimension tables
                    └── Azure Data Factory
                        └── Azure SQL Reporting DB
                            ├── Power BI (20 dashboards)
                            └── SSRS (6 operational reports)
```

The pipeline runs nightly at midnight (Cairo time) via Azure Scheduler. Every run since deployment has succeeded — 18+ consecutive green runs, averaging 6 minutes end to end.

---

## Data Model

The warehouse follows a Galaxy Schema (multiple fact tables sharing conformed dimensions):

**Fact tables:** `fact_sales`, `fact_shipments`, `fact_returns`, `fact_events`

**Dimension tables:** `dim_date`, `dim_customer`, `dim_product` (SCD2), `dim_seller`, `dim_location`, `dim_promotion`, `dim_payment_bridge`, `dim_reviews`

The OLTP source was designed from scratch — conceptual ERD, logical schema, and physical deployment on Azure SQL — with data generated via Python (Faker, pandas) adapted to Egyptian cities, regions, categories, and naming conventions.

---

## Pipeline Details

**Bronze** — connects to Azure SQL, ingests all source tables as Delta tables, preserves full history, tracks ingestion metadata.

**Silver** — data cleaning and validation, null handling, Egyptian market normalization (currency, region classification, product categories), business rule enforcement.

**Gold** — builds the star schema from Silver, populates all fact and dimension tables, runs row count verification before marking the run complete.

Fault isolation is enforced: if Bronze fails, Silver and Gold do not run. Email alerts fire on any task failure with the specific step and error detail.

---

## Reporting Layer

A separate Azure SQL reporting database sits between the warehouse and the BI tools, built via Azure Data Factory. This keeps reporting queries fast, isolates access by role, and prevents dashboard load from hitting the warehouse directly.

**SSRS reports (6):**
- Product Listing Quality and Return Rate Audit
- Regional Shipment Delay (drilldown by city)
- Customer Promotion Campaign Effectiveness
- Customers Monthly Anniversary Navigator
- Monthly Cash on Delivery Risk Report
- Recent Low-Rated Customer Reviews

---

## Power BI Dashboards

**Platform View (10 pages)**

| Page | Business Question |
|------|------------------|
| Executive Overview | How is the marketplace performing as a whole? |
| Sales Performance | Where is revenue coming from? |
| Revenue Trends | What cycles and patterns are emerging? |
| Product & Demand | What are customers buying most? |
| Regional Delay Analysis | Which regions have the worst delays? |
| Delivery & Logistics | Where is the fulfillment network breaking down? |
| Seller Performance | Who are the top sellers and how are they distributed? |
| Payment & COD Risk | What is the financial exposure from failed payments? |
| Marketplace Quality | How satisfied are customers overall? |
| Platform Pulse | What must the platform team act on right now? |

**Seller View (10 pages)**

Overview, Sales Analysis, Health Score, Demand Insights, Promotion Performance, Product Performance, Returns & Complaints, Fulfillment Performance, Customer Insights, and an AI Recommendations page with estimated revenue opportunity in EGP.

All 20 pages connect live to the reporting database, with role-level security, slicers, drill-through, and trend comparisons.

---

## AI Layer

**RAG Chatbot** — sellers ask questions in natural language. The pipeline runs: query optimizer → vector search (Supabase) → LLM agent → business answer. Built with n8n for orchestration, OpenRouter for the LLM, and a Databricks Genie query flow for structured data retrieval. Supports conversational queries, analytical responses, and visual chart outputs.

**Executive Intelligence Brief** — an AI-generated morning briefing that monitors the marketplace continuously and surfaces critical alerts (e.g. sellers showing consecutive sales decline, home appliance revenue down 23%), high-priority actions, and growth opportunities with recommended next steps. Refreshes every 15 minutes.

---

## Tech Stack

| Layer | Tools |
|-------|-------|
| Data source | Kaggle (Olist), Python (Faker, pandas, numpy) |
| Database | Azure SQL, SQL Server |
| Processing | Databricks (Serverless), PySpark, Delta Lake |
| Orchestration | Azure Scheduler, Databricks Workflows |
| Data movement | Azure Data Factory |
| Reporting | SSRS, Power BI |
| AI | n8n, OpenRouter, Supabase (vector), Databricks Genie |
| Frontend (alert UI) | React, Streamlit |
| Version control | Git, GitHub |
| Design & docs | draw.io, Canva, VS Code, Google Meet |

---

## Team

| Name | Contributions |
|------|--------------|
| Basant Abdelwahab (Team Lead) | Project documentation, ERD, logical schema, Python DB generation, SQL Server setup, ADF pipeline, SSRS (3 reports), Power BI seller view (5 pages), presentation |
| Mohamed Nazeeh | ERD, DW design, SSRS (3 reports), Power BI seller view (1 page), Power BI platform view (4 pages) |
| Mohamed Abo Elil | ERD, DW design, RAG system, Streamlit app, Power BI seller view (1 page), Power BI platform view (4 pages) |
| Yasmeen Elshamy | ERD, DB creation, ELT process, Databricks pipeline, Power BI seller view (4 pages), Power BI platform view (3 pages), live AI brief, presentation |

---

## Project Timeline

| Sprint | Date | Focus |
|--------|------|-------|
| 1 | Apr 24 | Brainstorm & scope definition |
| 2 | Apr 28 | Data modeling (ERD, schemas, data dictionary) |
| 3 | May 02 | Azure SQL setup, Python data generation |
| 4 | May 07 | Databricks workspace, Medallion design |
| 5 | May 11 | ELT pipelines, Delta tables, scheduling |
| 6 | May 14 | Azure reporting layer, ADF pipeline |
| 7 | May 17 | SSRS reports, RAG system, chatbot |
| 8 | May 20 | Power BI dashboards (all 20 pages) |
| Final | May 25 | End-to-end demo, stakeholder presentation |

---


ITI Power BI Development Track — Tanta, 2026
