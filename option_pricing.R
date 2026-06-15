library(quantmod)
library(lubridate)
library(tseries)
symbol <- "TSLA"
data_wyceny <- as.Date("2026-05-05") 
start_date <- data_wyceny - years(2)

# Pobieranie kursów historycznych
invisible(getSymbols(symbol, src = "yahoo", from = start_date, to = data_wyceny + days(1), auto.assign = TRUE))
df <- as.data.frame(get(symbol))
colnames(df) <- c("Open", "High", "Low", "Close", "Volume", "Adjusted")
  
# Definicja parametrów finansowych
S0  <- as.numeric(tail(df$Close, 1)) # Cena akcji w dniu wyceny
r   <- 0.0528                        # Stopa risk-free (5.28%)
q   <- 0                             # Brak dywidendy (q = 0)
T   <- 0.25                          # Czas do wygaśnięcia (3 miesiące)
XL  <- S0 * 0.85                     # Dolna granica korytarza (-15%)
XU  <- S0 * 1.15                     # Górna granica korytarza (+15%)

# Obliczanie zmienności historycznej (sigma)
returns <- diff(log(df$Close))
sig <- sqrt(252) * sd(returns, na.rm = TRUE)
# Zapewnienie powtarzalności wyników
set.seed(42)
# Parametry techniczne
Q   <- 1
dT  <- 1/252/Q
NoT <- 1000
K   <- 1000
N   <- T/dT

mc_results = matrix(0, K, 1)

for (k in 1:K) {
    # Generowanie ścieżek (Zmienne antytetyczne)
    z_plus  <- matrix(rnorm(NoT/2 * N), NoT/2)
    z_minus <- -z_plus
    z       <- rbind(z_plus, z_minus)
    
    # Obliczanie końcowej ceny ST
    R      <- (r - q - sig^2/2) * dT + sig * sqrt(dT) * z
    Rsum   <- apply(R, 1, sum)
    ST     <- S0 * exp(Rsum)
    
    # Warunek wypłaty korytarzowej
    ST[ST > XU | ST < XL] <- 0
    mc_results[k] <- exp(-r * T) * mean(ST)
}

mc_price <- mean(mc_results)
Hakansson_Price <- function(S0, XU, XL, r, q, T, sig) {
  d1 <- (log(S0/XL) + (r - q + sig^2/2) * T) / (sig * sqrt(T))
  d2 <- (log(S0/XU) + (r - q + sig^2/2) * T) / (sig * sqrt(T))
  value <- S0 * exp(-q * T) * (pnorm(d1) - pnorm(d2))
  return(value)
}

analytical_price <- Hakansson_Price(S0, XU, XL, r, q, T, sig)
