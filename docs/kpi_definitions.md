# KPI Definitions

This file defines every KPI used in the Power BI report: what it means, how it is calculated, which table it comes from, and the level it is calculated at.

The **Value** column is the result for the full dataset (no filters). It is used to check that SQL and Power BI give the same numbers.

## General rules

- **Ticket level vs journey level.** Sales, demand and refund KPIs count tickets (`Fact_TicketSales`). Operational KPIs count journeys (`Fact_Journey`). One journey can have many tickets, so counting tickets would give wrong operational numbers. For example, the cancellation rate is 4.0% of journeys, but 5.9% if tickets are counted.
- **Revenue.** Revenue means the total of the `Price` column, which is the recorded ticket price. It is not profit, and refund requests are not subtracted, because the data does not show whether a refund was paid or how much.
- **Refund requests.** A refund request is a request made by the passenger. It does not mean a refund was approved or paid.
- **Dates.** Trends over time use the journey date (when the passenger travels). The purchase date is used only for purchasing behaviour.

## 1. Sales & Revenue

| KPI | Definition | Calculation | Table | Level | Value |
|---|---|---|---|---|---|
| Total Revenue | Total recorded ticket value | `SUM(Price)` | Fact_TicketSales | Ticket | £741,921 |
| Tickets Sold | Number of tickets sold | `COUNT(Transaction_ID)` | Fact_TicketSales | Ticket | 31,653 |
| Average Ticket Price | Average price paid per ticket | Total Revenue / Tickets Sold | Fact_TicketSales | Ticket | £23.44 |
| First Class Revenue Share | Part of the revenue that comes from First Class tickets | Revenue of First Class / Total Revenue | Fact_TicketSales + Dim_TicketClass | Ticket | 20.1% |

## 2. Passenger Demand & Travel Patterns

| KPI | Definition | Calculation | Table | Level | Value |
|---|---|---|---|---|---|
| Total Tickets | Number of tickets (demand) | `COUNT(Transaction_ID)` | Fact_TicketSales | Ticket | 31,653 |
| Average Tickets per Day | Average number of tickets per travel day | Total Tickets / number of journey days | Fact_TicketSales + Fact_Journey | Ticket | 261.6 (121 days) |
| Busiest Route | Route with the most tickets | Route with the highest ticket count | Fact_TicketSales + Fact_Journey + Dim_Route | Ticket | Manchester Piccadilly to Liverpool Lime Street (4,628) |
| Peak Hour | Departure hour with the most tickets | Hour of `Departure_Time` with the highest ticket count | Fact_TicketSales + Fact_Journey | Ticket | 18:00 (3,113), almost equal to 06:00 (3,112) |

Note: tickets are not the same as passengers. The data has no passenger ID, so we cannot count unique passengers.

## 3. Operational Performance

| KPI | Definition | Calculation | Table | Level | Value |
|---|---|---|---|---|---|
| Total Journeys | Number of train journeys | `COUNT(JourneyID)` | Fact_Journey | Journey | 19,871 |
| On-Time Rate | Share of journeys that arrived on time | On-time journeys / Total Journeys | Fact_Journey | Journey | 90.7% |
| Delay Rate | Share of journeys that were delayed | Delayed journeys / Total Journeys | Fact_Journey | Journey | 5.3% |
| Cancellation Rate | Share of journeys that were cancelled | Cancelled journeys / Total Journeys | Fact_Journey | Journey | 4.0% |
| Disruption Rate | Share of journeys that were delayed or cancelled | (Delayed + Cancelled) / Total Journeys | Fact_Journey | Journey | 9.3% |
| Average Delay | Average delay of delayed journeys, in minutes | `AVG(Delay_Minutes)` for delayed journeys only | Fact_Journey | Journey | 37.7 min |

Notes:

- Cancelled journeys have no delay value, so they are not included in Average Delay.
- When routes are compared by Disruption Rate, only routes with at least 100 journeys are shown, so that routes with very few journeys do not give misleading percentages.

## 4. Ticket Purchasing & Refunds

| KPI | Definition | Calculation | Table | Level | Value |
|---|---|---|---|---|---|
| Online Share | Share of tickets bought online | Online tickets / Tickets Sold | Fact_TicketSales + Dim_PurchaseType | Ticket | 58.5% |
| Railcard Usage | Share of tickets bought with a railcard | Tickets where Railcard is not "None" / Tickets Sold | Fact_TicketSales + Dim_Railcard | Ticket | 33.9% |
| Average Days Booked Ahead | Average days between purchase and journey | `AVG(Days_Booked_Ahead)` | Fact_TicketSales | Ticket | 1.66 days |
| Refund Requests | Number of tickets with a refund request | `COUNT` where Refund_Request = "Yes" | Fact_TicketSales | Ticket | 1,118 |
| Refund Request Rate | Share of tickets on delayed or cancelled journeys that asked for a refund | Refund Requests / tickets on delayed or cancelled journeys | Fact_TicketSales + Fact_Journey | Ticket | 26.8% |
| Value of Refund Requests | Total price of the tickets with a refund request | `SUM(Price)` where Refund_Request = "Yes" | Fact_TicketSales | Ticket | £38,702 |

Note: the Refund Request Rate uses only tickets on delayed or cancelled journeys, because on-time journeys have no refund requests at all.
