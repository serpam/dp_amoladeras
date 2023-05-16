SELECT Gbif_desnudo_0.ZONA,
       Gbif_desnudo_0.BLOQUES,
       Gbif_desnudo_0.TRATAMIENTOS,
       Gbif_desnudo_0.ETIQUETA,
       Gbif_desnudo_0.TRANSECTO,
       Gbif_desnudo_0.ANIO_SEG,
       Gbif_desnudo_0.FECHA,
       Count(Gbif_desnudo_0.ETIQUETA) AS DESNUDO
FROM Gbif_desnudo_0
GROUP BY Gbif_desnudo_0.ZONA,
         Gbif_desnudo_0.BLOQUES,
         Gbif_desnudo_0.TRATAMIENTOS,
         Gbif_desnudo_0.ETIQUETA,
         Gbif_desnudo_0.TRANSECTO,
         Gbif_desnudo_0.ANIO_SEG,
         Gbif_desnudo_0.FECHA;
