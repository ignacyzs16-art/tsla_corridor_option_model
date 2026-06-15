Exotic Option Pricing and Method Comparison
================

## 1.1. Introduction and Objective

The primary objective of this project was to confront a theoretical pricing model with raw market data for an asset characterized by extreme volatility. Instead of relying on idealized assumptions and artificially generated parameters, we implemented the following four-stage verification process:

- **Data Extraction and Calibration:** We retrieved actual time-series data from the past two years for Tesla (TSLA) stock. Based on this data, we estimated the historical volatility of log returns, which served as the primary input parameter for the simulation.

- **Monte Carlo Engine Implementation:** We programmed a price trajectory generator from scratch based on the stochastic Geometric Brownian Motion (GBM) model. To optimize the simulation and minimize the standard error, we utilized a variance reduction technique (antithetic variates).

- **Payout Structure Modeling:** We defined the boundary conditions for a European Asset-or-Nothing corridor option (with a lower barrier at 85% and an upper barrier at 115% of the current stock price). The option expires worthless if the terminal price falls outside this range.

- **Cross-Validation:** We confronted the numerical results obtained via Monte Carlo simulation with an exact analytical solution based on Black-Scholes extensions for exotic options.

## 1.2. Target Audience

- **Financial Analysts / Quantitative Analysts (Quants):** The primary target group, specializing in building mathematical models to price financial instruments using R or Python. Required skills include formula implementation, simulation design, and optimization techniques.
- **Risk Management Specialists:** Professionals who need to evaluate portfolio behavior during extreme market shocks. Additionally, this study highlights the distinct hedging challenges associated with "All-or-Nothing" structures.
- **Traders and Students:** For option pricing applications and advanced educational purposes in quantitative finance.

## 1.3. Why Tesla?

Tesla exhibits high historical volatility and pays no dividends, providing an excellent environment to test the sensitivity of a corridor model. High price dynamics drastically increase the probability of breaching the barriers, which should be reflected in a relatively low option premium.

**Option Characteristics**

- **Underlying Asset:** Tesla stock (TSLA).
- **Payout Condition:** The option pays the terminal stock price ($S_T$) at maturity $T$ if $X_L < S_T < X_U$.
- **Zero Payout:** If the price breaches the corridor boundaries, the option expires worthless.

# 2. Data Retrieval and Parameter Estimation

In this section, the script automatically retrieves historical data for Tesla.

**Parameter Summary as of 2026-05-05**

- Underlying Asset Price ($S_0$): 389.37 USD
- Risk-Free Rate ($r$): 5.28%
- Volatility ($\sigma$): 60.32%
- Corridor Range: \[330.96, 447.78\] USD

# 3. Monte Carlo Simulation

The numerical simulation is based on the Geometric Brownian Motion (GBM) model, which assumes a log-normal distribution of returns. 

**Computational Optimization:** To reduce the standard error without expanding the number of iterations, an antithetic variates technique was implemented. For every randomly sampled path, the engine generates its exact mirror image (inverting the sign). This stabilizes the symmetry of the distribution and improves estimator precision.

# 4. Hakansson's Model

To validate the accuracy of the Monte Carlo simulation, Hakansson's model was utilized. This provides an exact analytical mathematical solution, extending the classical Black-Scholes framework to exotic path-dependent options.

# 5. Results and Final Conclusions

| Method               | Option Price (USD) |
|:---------------------|:-------------------|
| **Monte Carlo** | 145.8916           |
| **Hakansson's Model**| 145.7411           |

**Summary:**

- **Technological Accuracy:** The result obtained via Monte Carlo simulation is highly convergent with the analytical solution. This convergence confirms the correct implementation of the option's payout logic.
- **Impact of Volatility on Pricing:** The model's mathematics accurately reflect market realities. Investors anticipate sharp movements in a volatile stock like TSLA, making the probability of the price remaining within a narrow corridor for 3 months quite low. Consequently, the option premium represents only a small fraction of the underlying stock price.
- **Option Price vs. Market Price Analysis:** The spot price of TSLA on the valuation date was 389.37 USD. The calculated option value is drastically lower. Holding the stock itself guarantees capital preservation tied to its spot performance. The corridor option, being an "All-or-Nothing" structure, ruthlessly discounts the risk of barrier breaches, sharply driving down its present value.
- **Model Limitations and Weaknesses:** The primary limitation of this study lies in the foundational assumptions of the classical Black-Scholes / Hakansson models. They assume that volatility ($\sigma$) and the risk-free rate ($r$) remain constant over the option's lifespan. In reality, these parameters are highly dynamic. Furthermore, the Geometric Brownian Motion (GBM) model assumes continuous price paths, whereas tech stocks frequently experience gaps (jump risk).
- **Theoretical Price vs. Real-World OTC Market:** The calculated amount of 145.8916 USD represents a purely theoretical fair value. Exotic options are traded over-the-counter (OTC). In a real market environment, an investment bank would incorporate a wider bid-ask spread and an additional premium for jump risk, likely resulting in a lower valuation from the seller's perspective.

# References

- Hull, J. C. (2021). Options, Futures, and Other Derivatives. Pearson. (The market standard defining the mathematics of pricing for classical and exotic options, including binary instruments).
- Glasserman, P. (2003). Monte Carlo Methods in Financial Engineering. Springer. (The canonical source describing correct modeling of stochastic processes and the application of variance reduction techniques, such as antithetic variates).
