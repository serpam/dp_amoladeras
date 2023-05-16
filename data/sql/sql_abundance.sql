SELECT dicc_parcelas.etiqueta,
       dicc_fecha_visita.anio_seg,
       dicc_fecha_visita.fecha,
       dicc_cuadrante.cuadrante,
       cuadrante.n_individuos
FROM   ((dicc_parcelas
         INNER JOIN parcelas
                 ON dicc_parcelas.cod_dicc_parcela = parcelas.cod_dicc_parcela)
        INNER JOIN (dicc_fecha_visita
                    INNER JOIN visita_segu_densidad
                            ON dicc_fecha_visita.cod_dicc_fecha_visita =
                               visita_segu_densidad.cod_dicc_fecha_visita)
                ON parcelas.cod_parcela = visita_segu_densidad.cod_parcela)
       INNER JOIN (dicc_cuadrante
                   INNER JOIN cuadrante
                           ON dicc_cuadrante.cod_dicccuadrante =
                              cuadrante.cod_dicc_cuadrante)
               ON visita_segu_densidad.cod_visita_seg_densidad =
                  cuadrante.cod_visita_segu_densida;
