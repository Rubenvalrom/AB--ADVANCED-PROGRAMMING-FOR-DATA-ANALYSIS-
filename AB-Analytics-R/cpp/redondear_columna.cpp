#include <Rcpp.h>
#include <iostream>
#include <cmath> 
#include <vector>
#include <algorithm>



double redondear_numero(double valor) {
    return std::round(valor * 100.0) / 100.0;
}

// [[Rcpp::export]]
std::vector<double> redondear_columna(const std::vector<double>& columna, double limite_superior, double limite_inferior) {
    std::vector<double> result(columna.size());
    for (size_t i = 0; i < columna.size(); ++i) {
        double val = redondear_numero(columna[i]);
        if (val > limite_superior) {
            val = NULL;
        } else if (val < limite_inferior) {
            val = NULL;
        }
        result[i] = val;
    }
    return result;
}
