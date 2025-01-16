#include <Rcpp.h>
#include <iostream>
#include <cmath> 
#include <vector>
#include <algorithm>
#include <cstddef>
#include <tuple>

using namespace Rcpp;

// [[Rcpp::export]]
NumericVector calcular_limites(NumericVector x) {
  
  // Calcular los percentiles
  NumericVector sorted = clone(x).sort();
  int n = sorted.size();
  double Q1 = sorted[floor(n * 0.25)];
  double Q3 = sorted[floor(n * 0.75)];
  double IQR = Q3 - Q1;

  // Calcular los límites
  double limite_superior = Q3 + 1.5 * IQR;
  double limite_inferior = Q1 - 1.5 * IQR;

  return NumericVector::create(IQR, limite_superior, limite_inferior);
}
