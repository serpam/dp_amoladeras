SELECT Gbif_musgo_liquen_0.ZONA,
       Gbif_musgo_liquen_0.BLOQUES,
       Gbif_musgo_liquen_0.TRATAMIENTOS,
       Gbif_musgo_liquen_0.ETIQUETA,
       Gbif_musgo_liquen_0.TRANSECTO,
       Gbif_musgo_liquen_0.FECHA,
       Gbif_musgo_liquen_0.ANIO_SEG,
       Count(Gbif_musgo_liquen_0.ETIQUETA) AS MUSGO_LIQUEN
FROM Gbif_musgo_liquen_0
GROUP BY Gbif_musgo_liquen_0.ZONA,
         Gbif_musgo_liquen_0.BLOQUES,
         Gbif_musgo_liquen_0.TRATAMIENTOS,
         Gbif_musgo_liquen_0.ETIQUETA,
         Gbif_musgo_liquen_0.TRANSECTO,
         Gbif_musgo_liquen_0.FECHA,
         Gbif_musgo_liquen_0.ANIO_SEG;
