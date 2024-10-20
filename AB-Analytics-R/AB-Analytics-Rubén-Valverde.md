---
title: "ANÁLISIS DE LA CORRELACIÓN ENTRE LA INFLACIÓN Y LA PERCEPCIÓN DE CORRUPCIÓN"
author: "Rubén Valverde Romero"
date: "2024-10-19"
output:
  html_document:
    keep_md: true
---

<head><link rel="stylesheet" href="styles.css"></head>

<body>
  <button class="boton-expansion">↓</button>
:::: {#indice .collapsible}
  <h2>Índice</h2>

 

::: {style="padding-top: 0;"}
-   [Introducción](#introduccion)

-   [Limpieza de Datos](#limpieza-de-datos)

    -   [Carga y Visualización del DataFrame](#carga-y-visualizacion-del-dataframe)
    -   [Reemplazo de Valores "no data" por NA](#reemplazo-de-valores-no-data-por-na)
    -   [Conversión de Columnas a Numérico](#conversion-de-columnas-a-numerico)
    -   [Conteo de valores NA](#conteo-de-valores-na)
    
-   [Análisis de la Evolución de la Inflación Promedio Anual por Región](#analisis-de-la-evolución-de-la-inflacion-promedio-anual-por-region)

    -   [Formateo del DataFrame](#formateo-del-dataFrame)
    -   [Visualización de la Inflación](#visualizacion-de-la-inflacion)
    -   [Análisis del Gráfico de Evolución de la Inflación Promedio Anual por Región](#analisis-del-grafico-de-evolucion-de-la-inflacion-promedio-anual-por-region)

-   [Análisis de la Evolución del Indice de Percepción de Corrupción Promedio Anual (CPI) por Región](#analisis-de-la-evolucion-del-indice-de-percepcion-de-corrupcion-promedio-anual-cpi-por-region)

    -   [Adaptación al Cambio de Formato de 2012](#adaptacion-formato-cpi)
    -   [Calculo del CPI anual por región](#calculo-del-cpi-anual-por-region)
    -   [Visualización del CPI](#visualizacion-del-cpi)
    -   [Análisis del Gráfico de la Evolución de la Puntuación de la Percepción de Corrupción (CPI) Promedio Anual por Región](#analisis-del-grafico-de-la-evolucion-del-indice-de-percepcion-de-corrupcion-promedio-anual-cpi-por-region)

-   [Análisis de la Correlación entre la Puntuación de Corrupción y la Inflación](#analisis-de-la-correlacion-entre-la-puntuacion-de-corrupcion-y-la-inflacion)

    -   [Calculo de valores medianos de inflación y medios de puntuación de corrupción](#calculo-inflacion-cpi)
    -   [Visualización de la correlación](#visualizacion-correlacion)
    -   [Análisis del gráfico de la Correlación entre el CPI y la Inflación](#analisis-del-grafico-correlacion-cpi-inflacion)
    -   [Coeficiente de Correlación de Spearman's Rank](#spearman)
        -   [Resultados](#resultados)
        -   [Interpretación](#interpretacion)

    </div>

    </div>

    <script>
      const boton = document.querySelector('.boton-expansion');
      const indice = document.getElementById('indice');
      
      const newLeftValue = Math.floor(indice.offsetWidth * 0.9);
      boton.style.left = `${newLeftValue}px`;
      
      
      boton.addEventListener('click', () => {
        if (indice.classList.contains('expanded')) {
          indice.classList.remove('expanded');
          indice.style.maxHeight = '55px';
          boton.classList.remove('expanded');
          boton.textContent = '↓';
      
          // Calculate the new left value
          const newLeftValue = Math.floor(indice.offsetWidth * 0.9);
          boton.style.left = `${newLeftValue}px`;
        } else {
          indice.classList.add('expanded');
          indice.style.maxHeight = '100vh';
          boton.classList.add('expanded');
          boton.textContent = '↑';
      
          // Reset the left value
          const newLeftValue = Math.floor(indice.offsetWidth * 0.9);
          boton.style.left = `${newLeftValue}px`;
        }
      });
      </script>

    </body>


## Introducción {#introduccion}

El objetivo de este informe es analizar la relación entre la inflación y la corrupción.



## Limpieza de datos {#limpieza-de-datos}

### Carga y Visualización del DataFrame {#carga-y-visualizacion-del-dataframe}


```r
df <- read.csv("inflation_corruption_1995_2023_Ruben_Valverde.csv")
head(df[0:6])
```

```
##       country iso region inflation_2023 score_2023 rank_2023
## 1 Afghanistan AFG     AP        no data         20       162
## 2     Albania ALB    ECA            4.8         37        98
## 3     Algeria DZA   MENA            9.3         36       104
## 4      Angola AGO    SSA           13.6         33       121
## 5   Argentina ARG    AME          133.5         37        98
## 6     Armenia ARM    ECA              2         47        62
```

```r
# Nota: El resto de columnas son repeticiones de las columnas 3, 4 y 5 por lo que mostrarlas no aportan más información y empeoran la estética
```

### Reemplazo de Valores "no data" por NA {#reemplazo-de-valores-no-data-por-na}


```r
# Contar valores "no data" en cada columna
inflation <- df[, grepl("inflation", names(df))]
no_data_count <- colSums(inflation == "no data", na.rm = TRUE)
print(paste("Hay un total de", sum(no_data_count), "valores 'no data'"))
```

```
## [1] "Hay un total de 128 valores 'no data'"
```

```r
# Reemplazar los valores "no data" por NA en todo el DataFrame porque da problemas al conteo
df[df == "no data"] <- NA
```

### Conversión de Columnas a Numérico {#conversion-de-columnas-a-numerico}


```r
# Convertir las columnas de inflación de 1995 a 2023 a valores numéricos
for (year in 1995:2023) {
  column <- paste("inflation", year, sep = "_")
  df[[column]] <- as.numeric(df[[column]])
}
```

### Conteo de valores NA {#conteo-de-valores-na}


```r
# Contar y mostrar el número de valores nulos por columna
print(paste("Hay un total de", sum(is.na(df)), "valores nulos"))
```

```
## [1] "Hay un total de 2152 valores nulos"
```

## Análisis de la Evolución de la Inflación Promedio Anual por Región {#analisis-de-la-evolución-de-la-inflacion-promedio-anual-por-region}

### Formateo del DataFrame {#formateo-del-dataFrame}


```r
# Transformar el DataFrame de formato ancho a formato largo para poder analizar los datos de inflación, puntuación y rango a lo largo del tiempo posteriormente
df_melted <- df %>%
  pivot_longer(cols = starts_with("inflation_") | starts_with("score_") | starts_with("rank_"),
  names_to = c(".value", "year"),
  names_sep = "_") %>%
select(country, iso, region, year, inflation, score, rank)

# Convertir las columnas 'inflation', 'rank' y 'score' a tipo numérico en el DataFrame df_melted
df_melted <- df_melted %>%
    mutate(across(c(inflation, rank, score), as.numeric))
head(df_melted)
```

```
## # A tibble: 6 × 7
##   country     iso   region year  inflation score  rank
##   <chr>       <chr> <chr>  <chr>     <dbl> <dbl> <dbl>
## 1 Afghanistan AFG   AP     2023       NA      20   162
## 2 Afghanistan AFG   AP     2022       10.6    24   150
## 3 Afghanistan AFG   AP     2021        7.8    16   174
## 4 Afghanistan AFG   AP     2020        5.6    19   165
## 5 Afghanistan AFG   AP     2019        2.3    16   173
## 6 Afghanistan AFG   AP     2018        0.6    16   172
```

```r
summary(df_melted)
```

```
##    country              iso               region              year          
##  Length:5133        Length:5133        Length:5133        Length:5133       
##  Class :character   Class :character   Class :character   Class :character  
##  Mode  :character   Mode  :character   Mode  :character   Mode  :character  
##                                                                             
##                                                                             
##                                                                             
##                                                                             
##    inflation            score            rank       
##  Min.   :  -72.70   Min.   : 0.40   Min.   :  1.00  
##  1st Qu.:    1.80   1st Qu.: 3.50   1st Qu.: 35.00  
##  Median :    4.00   Median :10.00   Median : 74.00  
##  Mean   :   28.78   Mean   :24.07   Mean   : 78.74  
##  3rd Qu.:    8.10   3rd Qu.:38.00   3rd Qu.:121.00  
##  Max.   :65374.10   Max.   :92.00   Max.   :182.00  
##  NA's   :128        NA's   :1012    NA's   :1012
```

### Visualización de la Inflación {#visualizacion-de-la-inflacion}


```r
# Crear un DataFrame con la inflación promedio anual por región
df_avg_inflation <- df_melted %>%
    group_by(region, year) %>%
    summarise(inflation = median(inflation, na.rm = TRUE), .groups = "drop") %>%
    ungroup()

# Nota: Se utilizó la mediana en lugar del promedio para evitar que valores extremos afecten el resultado (Como la inflación de 1995 en Europa Oriental y Asia Central causada por Bulgaria y Venezuela en América)

# Agregar un tema a los gráficos
theme_set(theme_bw())

# Ajustar el tamaño de los gráficos
options(repr.plot.width=17, repr.plot.height=7)

# Hacer las letras más grandes y los títulos centrados
theme_update(
    plot.title = element_text(size = 20, hjust = 0.5),
    axis.title = element_text(size = 16),
    axis.text = element_text(size = 14),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14)
)
# Crear el lineplot
A <- ggplot(df_avg_inflation, aes(x = year, y = inflation, color = region, group = region)) +
    geom_line(size=1.5) +
    scale_y_continuous(limits = c(0, 23)) +
    geom_text(data = df_avg_inflation %>% filter(inflation > 23),
              aes(label = round(inflation, 1), y = 23),
              color = "green", size = 3, vjust = -0.5) +
    geom_point(size=3) +
    labs(title = "Evolución de la Inflación Promedio Anual por Región",
         x = "Año",
         y = "Inflación Promedio",
         color = "Región")
```

![](Inflacion_Anual_Region.png)<!-- -->

### Análisis del Gráfico de Evolución de la Inflación Promedio Anual por Región {#analisis-del-grafico-de-evolucion-de-la-inflacion-promedio-anual-por-region}

El gráfico muestra la evolución de la inflación promedio anual por región desde 1995 hasta 2023. A continuación, se presentan algunos puntos clave observados en el gráfico:

1.  **América (AME)**:
    -   Se observa una tendencia general a la baja en la inflación desde 1995 hasta principios de la década de 2000.
    -   Sin embargo, hay picos significativos en ciertos años, lo que indica episodios de alta inflación en algunos países de la región.
    -   En los últimos años, la inflación ha vuelto a aumentar, alcanzando niveles preocupantes.
2.  **África Subsahariana (SSA)**:
    -   La región muestra una tendencia similar a la de Latinoamérica, con una disminución de la inflación en la primera década del siglo XXI.
    -   A partir de 2010, la inflación ha mostrado una tendencia al alza, con picos notables en algunos años.
3.  **Asia-Pacífico (AP)**:
    -   La región ha mantenido una inflación relativamente baja y estable en comparación con otras regiones.
    -   Aunque hay algunos picos, la inflación en Asia-Pacífico ha sido más controlada.
4.  **Europa Occidental y Union Europea (WE/EU)**:
    -   Esta región ha experimentado una inflación muy baja y estable durante la mayor parte del período analizado.
    -   Sin embargo, en los últimos años se observa un aumento en la inflación, esto es debido al aumento maviso de la masa monetaria para superar la crisis del covid en un corto periodo de tiempo.
5.  **Medio Oriente y Norte de África (MENA)**:
    -   La región muestra una inflación relativamente alta en comparación con Europa y Asia-Pacífico.
    -   Hay fluctuaciones significativas en la inflación, lo que indica inestabilidad económica en algunos países de la región.
6.  **Europa Oriental y Asia Central (ECA)**:
    -   La región de ECA muestra una tendencia fluctuante en la inflación a lo largo de los años.
    -   Aunque algunos países han logrado mantener una inflación baja y estable, otros continúan enfrentando episodios de alta inflación.

## Análisis de la Evolución del Indice de Percepción de Corrupción Promedio Anual (CPI) por Región {#analisis-de-la-evolucion-del-indice-de-percepcion-de-corrupcion-promedio-anual-cpi-por-region}

### Adaptación al Cambio de Formato de 2012 {#adaptacion-formato-cpi}


```r
# Al ejecutar el gráfico previamente se podia observar que el formato del CPI cambió en 2012, siendo 100 la puntuación máxima en lugar de 10.
df_melted %>%
    filter(year %in% c(2010, 2011, 2012, 2013)) %>%
    group_by(region, year) %>%
    summarise(score = mean(score, na.rm = TRUE), .groups = "drop") %>%
    head(4)
```

```
## # A tibble: 4 × 3
##   region year  score
##   <chr>  <chr> <dbl>
## 1 AME    2010   4.02
## 2 AME    2011   4.16
## 3 AME    2012  44.9 
## 4 AME    2013  44.3
```

```r
# Multiplico por 10 el CPI de los años 1995 hasta 2011 para que estén en la misma escala que los años posteriores
df_melted <- df_melted %>%
    mutate(score = ifelse(year >= 1995 & year <= 2011, score * 10, score))
```

### Calculo del CPI anual por región {#calculo-del-cpi-anual-por-region}


```r
# Calcular el CPI promedio anual por región
df_avg_score <- df_melted %>%
    group_by(region, year) %>%
    summarise(score = mean(score, na.rm = TRUE), .groups = "drop") %>%
    ungroup()

# Eliminar filas con valores nulos en la columna 'score', provocaban warnings
df_avg_score <- df_avg_score %>% drop_na(score)   
```

### Visualización del CPI {#visualizacion-del-cpi}


```r
# Crear el lineplot
A <- ggplot(df_avg_score, aes(x = year, y = score, color = region, group = region)) +
    geom_line(size=1.5) +
    geom_point(size=3) +
    labs(title = "Evolución del Indice de Percepción de Corrupción Promedio Anual (CPI) por Región",
         x = "Año",
         y = "CPI Promedio",
         color = "Región")
```

![](CPI_Region_Año.png)<!-- -->

### Análisis del Gráfico de Evolución de la Puntuación de la Percepción de Corrupción (CPI) Promedio Anual por Región {#analisis-del-grafico-de-la-evolucion-del-indice-de-percepcion-de-corrupcion-promedio-anual-cpi-por-region}

El gráfico muestra la evolución de la puntuación de corrupción promedio anual por región desde 1995 hasta 2023. A continuación, se presentan algunos puntos clave observados en el gráfico:

1.  **América (AME)**:
    -   La puntuación de corrupción en Latinoamérica ha mostrado una tendencia fluctuante a lo largo de los años.
    -   Aunque hay años en los que se observa una mejora en la puntuación, la región sigue enfrentando desafíos significativos en términos de corrupción.
2.  **África Subsahariana (SSA)**:
    -   La región de África Subsahariana muestra una tendencia similar a la de Latinoamérica, con puntuaciones de corrupción que varían considerablemente a lo largo del tiempo.
    -   A pesar de algunos avances, la corrupción sigue siendo un problema persistente en muchos países de la región.
3.  **Asia-Pacífico (AP)**:
    -   La región de Asia-Pacífico ha mantenido una puntuación de corrupción relativamente estable en comparación con otras regiones.
    -   Aunque hay algunos picos y valles, la puntuación de corrupción en Asia-Pacífico ha sido más controlada.
4.  **Europa Occidental y Union Europea (WE/EU)**:
    -   Esta región ha experimentado una puntuación de corrupción relativamente baja y estable durante la mayor parte del período analizado.
    -   Sin embargo, en los últimos años se observa una ligera disminución en la puntuación, lo que podría indicar un aumento en los desafíos relacionados con la corrupción.
5.  **Medio Oriente y Norte de África (MENA)**:
    -   La región de MENA muestra una puntuación de corrupción relativamente alta en comparación con Europa y Asia-Pacífico.
    -   Hay fluctuaciones significativas en la puntuación, lo que indica inestabilidad en la lucha contra la corrupción en algunos países de la región.
6.  **Europa Oriental y Asia Central (ECA)**:
    -   La región de ECA muestra una tendencia fluctuante en la puntuación de corrupción a lo largo de los años.
    -   Aunque algunos países han logrado mejoras significativas, otros continúan enfrentando altos niveles de corrupción.

## Análisis de la Correlación entre la Puntuación de Corrupción y la Inflación {#analisis-de-la-correlacion-entre-la-puntuacion-de-corrupcion-y-la-inflacion}

### Calculo de valores medianos de inflación y medios de puntuación de corrupción {#calculo-inflacion-cpi}


```r
# Calculo los valores medios de inflación y puntuación de corrupción por país
df_avg <- df_melted %>%
    group_by(country, region) %>% 
    summarise(
        inflation = median(inflation, na.rm = TRUE),
        score = mean(score, na.rm = TRUE), .groups = "drop"
    ) %>%
    arrange(region, country)
    
# Nota1: ordeno por región y país para que el hue siga el mismo orden que el resto
# Nota2: utilizo la mediana para la inflación para evitar que valores extremos como los de Bulgaria y Venezuela ya mencionados.
```

### Visualización de la correlación {#visualizacion-correlacion}


```r
# Crear el scatter plot para visualizar la correlación entre inflación y puntuación de corrupción
# Crear el scatter plot con una línea de regresión única para todas las regiones pero sin el scatter (Quiero una única linea de regresión)
A <- ggplot(df_avg, aes(x = inflation, y = score, color = region)) +
    geom_point(size = 3) +
    geom_smooth(method = "lm", se = FALSE, linetype = "dashed", size = 2.5, color = "black", formula = y ~ x) +
    labs(
        title = "Correlación entre Inflación y Puntuación de Corrupción por País",
        x = "Inflación Mediana",
        y = "Puntuación de Corrupción Promedio",
        color = "Región"
    )
```

![](Correlacion_CPI_Inflacion.png)<!-- -->

### Análisis del gráfico de la Correlación entre el CPI y la Inflación {#analisis-del-grafico-correlacion-cpi-inflacion}

El scatterplot muestra la relación entre la inflación y la puntuación de corrupción promedio por país. A continuación, se presentan algunos puntos clave observados en el gráfico:

1.  **Tendencia General**:
    -   Existe una tendencia negativa entre la inflación y la puntuación de corrupción. Esto sugiere que a medida que aumenta la inflación, la puntuación de corrupción tiende a disminuir, indicando mayores niveles de corrupción.
2.  **Regiones con Alta Inflación**:
    -   Las regiones como Latinoamérica (AME) y África Subsahariana (SSA) muestran una mayor dispersión en los valores de inflación, con algunos países experimentando inflaciones extremadamente altas. Estos países también tienden a tener puntuaciones de corrupción más bajas, lo que indica altos niveles de corrupción.
3.  **Regiones con Baja Inflación**:
    -   Europa Occidental, la Union Europea(WE/EU) y Asia-Pacífico (AP) muestran inflaciones relativamente bajas y puntuaciones de corrupción más altas, lo que indica menores niveles de corrupción. Esto sugiere una mejor gestión económica y políticas más efectivas contra la corrupción en estas regiones.
4.  **Línea de Tendencia**:
    -   La línea de tendencia discontinua en el gráfico refuerza la relación negativa entre la inflación y la puntuación de corrupción. Aunque hay excepciones, la mayoría de los puntos siguen esta tendencia.
5.  **Valores Atípicos**:
    -   Se eliminaron los valores atípicos de inflación (percentil 95) para obtener una representación más clara de la tendencia general. Los valores extremadamente altos de inflación empeoraban la visualización de la relación entre las variables.

En resumen, el gráfico sugiere que existe una correlación negativa entre la inflación y la puntuación de corrupción. Las regiones con alta inflación tienden a tener mayores niveles de corrupción, mientras que las regiones con baja inflación muestran menores niveles de corrupción. Este análisis destaca la importancia de la estabilidad económica y la buena gobernanza en la retención del poder adquisitivo de la moneda.

### Coeficiente de Correlación de Spearman's Rank {#spearman}


```r
# Calcular el coeficiente de correlación de Spearman
corr_test <- cor.test(df_melted$inflation, df_melted$score,
                      method = "spearman", use = "complete.obs",
                      exact = FALSE)
# Nota: Utilizo el método de Spearman porque no se una distribución normal y hay valores extremos
# Nota: Me saltaba el error de que no era posible calcular el coeficiente exacto, por lo que lo he puesto en FALSE, es decir, que no se calcula exactamente.

# Definir el nivel de significancia
alpha <- 0.05

# Mostrar los resultados
cat("Coeficiente de Correlación de Spearman's Rank:", corr_test$estimate, "\n")
```

```
## Coeficiente de Correlación de Spearman's Rank: -0.4098749
```

```r
if (corr_test$p.value < alpha) {
  cat("p-valor:", corr_test$p.value, ", Se rechaza la hipótesis nula\n")
} else {
  cat("p-valor:", corr_test$p.value, ", No se rechaza la hipótesis nula\n")
}
```

```
## p-valor: 6.571181e-165 , Se rechaza la hipótesis nula
```

#### Resultados: {#resultados}

El Coeficiente de Correlación de Spearman's Rank calculado entre las columnas `inflation` y `score` ha arrojado los siguientes resultados:

-   **Coeficiente de Correlación de Spearman's Rank**: -0.4098749
-   **p-valor**: 6.571181e-165

#### Interpretación: {#interpretacion}

1.  **Coeficiente de Correlación**:
    -   El valor del coeficiente de correlación de Spearman es -0.4098749, lo que indica una correlación negativa moderada entre la inflación y la puntuación de corrupción. Esto sugiere que, en general, a medida que aumenta la inflación, la puntuación de corrupción tiende a disminuir, lo que indica mayores niveles de corrupción.
2.  **p-valor**:
    -   El **p-valor** obtenido es extremadamente bajo (6.571181e-165), lo que es mucho menor que el nivel de significancia comúnmente utilizado (**α** = 0.05). Esto significa que podemos rechazar la hipótesis nula de que no existe correlación entre la inflación y la puntuación de corrupción. En otras palabras, la correlación observada es estadísticamente significativa.

En resumen, los resultados del Coeficiente de Correlación de Spearman's Rank sugieren que existe una correlación negativa significativa entre la inflación y la puntuación de corrupción en los datos analizados.
:::
::::
