SELECT diversidad_floristica_11.ZONA,
       diversidad_floristica_11.ETIQUETA,
       diversidad_floristica_11.ANIO_SEG,
       Sum(diversidad_floristica_11.Pi_LnPi) AS K,
       Sum(diversidad_floristica_11.Pi_Ln2Pi) AS K2,
       -1*[k] AS I_SHANNON_Ln,
       -1*[k2] AS I_SHANNON_Lg2,
       diversidad_floristica_11.recubrimiento_vegetal_1.TRATAMIENTOS AS TRATAMIENTO,
       diversidad_floristica_11.recubrimiento_vegetal_1.BLOQUES AS BLOQUE,
       diversidad_floristica_11.TIPO_VEGETACION
FROM diversidad_floristica_11
GROUP BY diversidad_floristica_11.ZONA,
         diversidad_floristica_11.ETIQUETA,
         diversidad_floristica_11.ANIO_SEG,
         diversidad_floristica_11.recubrimiento_vegetal_1.TRATAMIENTOS,
         diversidad_floristica_11.recubrimiento_vegetal_1.BLOQUES,
         diversidad_floristica_11.TIPO_VEGETACION;
