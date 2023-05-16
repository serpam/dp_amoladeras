SELECT recubrimiento_vegetal_1.ZONA,
       recubrimiento_vegetal_1.ETIQUETA,
       recubrimiento_vegetal_1.ANIO_SEG,
       recubrimiento_vegetal_1.TRATAMIENTOS,
       recubrimiento_vegetal_1.BLOQUES,
       recubrimiento_vegetal_1.TIPO_VEGETACION,
       Sum(recubrimiento_vegetal_1.PORCENT) AS N_CONTACTOS,
       Sum(recubrimiento_vegetal_1.REC_VEG) AS REC_VEGETAL,
       recubrimiento_vegetal_1.TRANSECTO,
       recubrimiento_vegetal_1.FECHA
FROM recubrimiento_vegetal_1
GROUP BY recubrimiento_vegetal_1.ZONA,
         recubrimiento_vegetal_1.ETIQUETA,
         recubrimiento_vegetal_1.ANIO_SEG,
         recubrimiento_vegetal_1.TRATAMIENTOS,
         recubrimiento_vegetal_1.BLOQUES,
         recubrimiento_vegetal_1.TIPO_VEGETACION,
         recubrimiento_vegetal_1.TRANSECTO,
         recubrimiento_vegetal_1.FECHA;
