# UK Train Rides: Insights and Recommendations

This file sums up what we found in the four Power BI pages and what we suggest to the rail company.
All numbers cover journeys from 1 January to 30 April 2024. They come from the Power BI report and were checked against the Python notebooks and the SQL queries in `sql/03_analysis_queries.sql`.

## How to read the numbers

- **Ticket level vs journey level.** One row in the data is one ticket. Many tickets can be on the same train, so sales and demand are counted per ticket (31,653 tickets), while delays and cancellations are counted per journey (19,871 journeys). Counting delays per ticket would make them look worse than they are (cancellations: 5.9% of tickets but 4.0% of journeys).
- **Revenue** means the recorded ticket price after discounts. It is not profit.
- **Refund requests** are requests, not confirmed refunds. The data does not say if a refund was paid.
- **Distance** is a straight line between stations (from the official ORR station file), not the real track length.

---

## 1. Sales and Revenue

| KPI | Value |
|---|---|
| Total revenue | £741,921 |
| Tickets sold | 31,653 |
| Average ticket price | £23.44 |
| First Class share of revenue | 20.1% |
| Revenue on delayed or cancelled journeys | £172,270 (23.2%) |

**Findings**

1. **Revenue depends on a few routes.** The top 5 routes bring 64% of revenue but only 41% of tickets. London Kings Cross → York alone brings £183,193 (about 1 in 4 pounds).
2. **First Class is small in volume but large in value.** It is 9.7% of tickets but 20.1% of revenue. The average First Class ticket is £48.86 against £20.72 for Standard.
3. **Advance tickets sell the most, Anytime tickets earn the most per ticket.** Advance: 17,561 tickets at £17.61 on average. Anytime: 5,340 tickets at £39.20.
4. **Station buyers pay more.** Online is 58.5% of tickets but 51.6% of revenue. The average station ticket is £27.35 against £20.67 online.
5. **Monthly revenue is stable.** It moves between £159K (February, the shortest month) and £200K (January).

## 2. Passenger Demand and Travel Patterns

| KPI | Value |
|---|---|
| Average tickets per day | 261.6 |
| Busiest route | Manchester Piccadilly → Liverpool Lime Street (4,628 tickets) |
| Peak departure hour | 18:00 (3,113 tickets), with 06:00 almost the same (3,112) |

**Findings**

1. **Two clear rush hours.** 06:00–08:00 and 16:00–18:00 hold 52% of all tickets. This matches the Off-Peak definition in the data dictionary.
2. **Weekends are as busy as weekdays.** Daily tickets per weekday range from 4,351 (Friday) to 4,692 (Wednesday), and Sunday (4,580) is close to the top.
3. **The busiest routes are not the most valuable.** Manchester → Liverpool is first by tickets but outside the top 5 by revenue, because the trip is short and cheap. Kings Cross → York is third by tickets but first by revenue.
4. **Demand is driven by London and the North West.** Most top routes start in London, Manchester or Liverpool.
5. **Data note:** the 1st of January, March and April have very few tickets (63–73 against about 262 on a normal day). This looks like a cut in how the data was collected, not a real drop, so we do not treat it as a trend.

## 3. Operational Performance (journey level)

| KPI | Value |
|---|---|
| Total journeys | 19,871 |
| On-time rate | 90.7% |
| Delay rate | 5.3% (1,062 journeys) |
| Cancellation rate | 4.0% (790 journeys) |
| Average delay (delayed journeys only) | 37.7 minutes |

**Findings**

1. **Most journeys run on time, but problems are not spread evenly.** The overall disruption rate is 9.3%, yet a few routes are far worse.
2. **The London Euston routes from the North West are the weak point.**
   - Manchester Piccadilly → London Euston: 67.1% of journeys delayed or cancelled.
   - Liverpool Lime Street → London Euston: 61.4%.
   - Birmingham New Street → Manchester Piccadilly: 54.9%.
3. **Weather is the top cause overall** (466 disrupted journeys), followed by Staffing (437) and Signal Failure (424). The five causes are close, so there is no single fix.
4. **Manchester Piccadilly → Leeds has the longest delays:** 137.5 minutes on average when late.
5. **Data note:** 18 tickets are marked Delayed with a 0-minute delay. We kept them as they are and noted them as an anomaly.

## 4. Ticket Purchasing and Refunds

| KPI | Value |
|---|---|
| Online share | 58.5% of tickets |
| Railcard usage | 33.9% of tickets |
| Average days booked ahead | 1.66 days |
| Refund requests | 1,118 (26.8% of tickets on disrupted journeys) |
| Value of refund requests | £38,702 |

**Findings**

1. **Passengers buy at the last minute.** 88% of tickets are bought on the day of travel or one day before. Only Advance tickets are bought early (about 3 days on average); Anytime and Off-Peak are always bought on the day.
2. **Credit card is the main payment method** in both channels (62.0% online, 58.2% at stations). Debit card is used twice as often at stations (7.9%) as online (3.5%).
3. **Two thirds of tickets have no railcard.** Railcard holders pay much less on average (Senior £10.58, Disabled £16.92, Adult £17.81) than passengers without one (£27.43).
4. **The cause of the disruption decides whether people ask for a refund.** Technical Issue: 54.9% of affected tickets ask for a refund. Weather: only 9.7%. Passengers seem to accept weather but not problems the company controls.
5. **Cancellations lead to more refund requests than delays** (30.4% against 23.8%).

---

## Key insight across pages

**One route explains most of the revenue at risk.** Liverpool Lime Street → London Euston is the second biggest route by revenue (£113,299), but 81% of that revenue (£92,304) is on delayed or cancelled journeys. That is 54% of all revenue on disrupted journeys in the dataset. The main cause on this route is Weather. The route also produced 171 refund requests worth £13,126, about one third of all refund value.

## Recommendations

1. **Start with the London Euston corridor.** Review the timetable, weather plans and spare trains for Liverpool → Euston and Manchester → Euston. Fixing these two routes would remove most of the revenue at risk.
2. **Treat technical issues as the first refund driver.** More than half of the tickets hit by a technical issue ask for a refund. Better maintenance on the routes with the most technical issues should cut refund requests faster than any other action.
3. **Plan staff and trains around the two rush hours.** More than half of tickets are for 06:00–08:00 and 16:00–18:00, so extra capacity and staff should go there first.
4. **Encourage earlier booking.** Almost all tickets are bought at the last minute. Clearer Advance fares online could move demand earlier and make planning easier.
5. **Protect the high-value routes and First Class.** Kings Cross → York and First Class tickets bring a large share of revenue from a small share of tickets, so service quality there matters most.
6. **Look at the station price gap.** Station buyers pay £6.68 more per ticket on average. It is worth checking if they are missing online or Advance fares.

## Limits of this analysis

- The data covers only four months (January–April 2024), so we cannot see seasonal patterns.
- There is no cost data, so we talk about revenue, not profit.
- Refund requests are not confirmed refunds.
- Distances are straight lines, not real track length.
- The analysis is descriptive. We did not build forecasts or predictive models.
