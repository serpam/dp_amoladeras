SELECT recubrimiento_vegetal_0.ZONA,
       recubrimiento_vegetal_0.ETIQUETA,
       recubrimiento_vegetal_0.TRANSECTO,
       recubrimiento_vegetal_0.FECHA,
       recubrimiento_vegetal_0.ANIO_SEG,
       recubrimiento_vegetal_0.NOMBRE_CIEN,
       Count(recubrimiento_vegetal_0.NOMBRE_CIEN) AS PORCENT,
       recubrimiento_vegetal_0.TRATAMIENTOS,
       recubrimiento_vegetal_0.BLOQUES,
       recubrimiento_vegetal_0.TIPO_VEGETACION,
       [PORCENT]*2 AS REC_VEG
FROM recubrimiento_vegetal_0
GROUP BY recubrimiento_vegetal_0.ZONA,
         recubrimiento_vegetal_0.ETIQUETA,
         recubrimiento_vegetal_0.TRANSECTO,
         recubrimiento_vegetal_0.FECHA,
         recubrimiento_vegetal_0.ANIO_SEG,
         recubrimiento_vegetal_0.NOMBRE_CIEN,
         recubrimiento_vegetal_0.TRATAMIENTOS,
         recubrimiento_vegetal_0.BLOQUES,
         recubrimiento_vegetal_0.TIPO_VEGETACION
HAVING (((recubrimiento_vegetal_0.ZONA)="Cabo de Gata"
         OR (recubrimiento_vegetal_0.ZONA)="Aldeire"));
