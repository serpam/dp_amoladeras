SELECT riqueza_1.ZONA,
       riqueza_1.ETIQUETA,
       riqueza_1.ANIO_SEG,
       Count(riqueza_1.ANIO_SEG) AS N_ESPECIES,
       riqueza_1.TRATAMIENTOS,
       riqueza_1.BLOQUES,
       riqueza_1.TIPO_VEGETACION,
       riqueza_1.TRANSECTO,
       riqueza_1.FECHA
FROM riqueza_1
GROUP BY riqueza_1.ZONA,
         riqueza_1.ETIQUETA,
         riqueza_1.ANIO_SEG,
         riqueza_1.TRATAMIENTOS,
         riqueza_1.BLOQUES,
         riqueza_1.TIPO_VEGETACION,
         riqueza_1.TRANSECTO,
         riqueza_1.FECHA;
