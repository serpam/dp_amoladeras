SELECT recubrimiento_tot_6.ZONA,
       recubrimiento_tot_6.ETIQUETA,
       recubrimiento_tot_6.TRATAMIENTOS,
       recubrimiento_tot_6.TRANSECTO,
       recubrimiento_tot_6.FECHA,
       recubrimiento_tot_6.ANIO_SEG,
       recubrimiento_tot_6.PORCENT,
       recubrimiento_tot_6.BLOQUES,
       recubrimiento_tot_6.TIPO_VEGETACION,
       [PORCENT]*2 AS REC_TOTAL
FROM recubrimiento_tot_6
GROUP BY recubrimiento_tot_6.ZONA,
         recubrimiento_tot_6.ETIQUETA,
         recubrimiento_tot_6.TRATAMIENTOS,
         recubrimiento_tot_6.TRANSECTO,
         recubrimiento_tot_6.FECHA,
         recubrimiento_tot_6.ANIO_SEG,
         recubrimiento_tot_6.PORCENT,
         recubrimiento_tot_6.BLOQUES,
         recubrimiento_tot_6.TIPO_VEGETACION
HAVING (((recubrimiento_tot_6.ZONA)="Aldeire"
         OR (recubrimiento_tot_6.ZONA)="Cabo de Gata"));
