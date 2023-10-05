library(targets)
library(tarchetypes)

source("R/functions.R")

# Set target-specific options such as packages.
tar_option_set(packages = c("tidyverse", "janitor", "sf",
                            "readxl", "purrr", "taxize", "writexl",
                            "readr", "glue"))

# Targets
list(

  # Prepare events
  ## Prepare Spatial data for events
  tar_file(geo_parcelas, "data/geoinfo/amoladeras_parcelas.shp"),
  tar_file(geo_transectos,"data/geoinfo/amoladeras_transectos.shp"),
  tar_file(geo_subplots, "data/geoinfo/amoladeras_subplots.shp"),

  ### --- prepare wkt; add treatment
  tar_target(wkt_parcelas, genera_wkt(geo_file = geo_parcelas)),
  tar_target(wkt_transectos, genera_wkt(geo_file = geo_transectos)),
  tar_target(wkt_subplots, genera_wkt(geo_file = geo_subplots)),
  tar_target(event_parcelas_aux,
             genera_event_parcelas_aux(df = wkt_parcelas)),
  tar_target(event_subplot_aux,
             genera_event_subplot_aux(
               df = wkt_subplots,
               parcelas_event_aux = event_parcelas_aux)),
  tar_target(event_transect_aux,
             genera_event_transect_aux(
               df = wkt_transectos,
               parcelas_event_aux = event_parcelas_aux)),

  ### genera dicc event
  tar_target(event_dic,
             genera_event_dic(
               parcelas_event_aux = event_parcelas_aux,
               subplots_event_aux = event_subplot_aux,
               transectos_event_aux = event_transect_aux)),

  # Transects event
  ## Prepare transects files
  parameters_transects <- tibble::tibble(
    xlsx_file = c(
      "data/raw_data/transectos/desnudo.xlsx",
      "data/raw_data/transectos/musgo_liquen.xlsx",
      "data/raw_data/transectos/recubrimiento_total.xlsx",
      "data/raw_data/transectos/recubrimiento_vegetal.xlsx",
      "data/raw_data/transectos/riqueza.xlsx",
      "data/raw_data/transectos/diversidad_floristica.xlsx"),
    sheet = c(
      "Gbif_desnudo_1", "Gbif_musgo_liquen_1", "recubrimiento_tot_7",
      "recubrimiento_vegetal_2", "riqueza_2", "diversidad_floristica_22"),
    var_interes = c("desnudo", "musgo_liquen", "rec_total", "rec_vegetal", "n_especies", "i_shannon_ln"),
    name = c("desnudo", "musgo", "rec_tot", "rec_veg", "riq", "div")),

  mapped <- tarchetypes::tar_map(
    values = parameters_transects,
    tar_target(read_tr,
      read_transects_data(
        file = xlsx_file,
        sheet = sheet,
        var_interes = var_interes)),
    names = tidyselect::any_of("name")),

  tar_combine(combina_tr, mapped[["read_tr"]],
              command = dplyr::bind_rows(!!!.x)),
  tar_target(prepara_tr, command = prepare_transects(combina_tr)),

  ### Generate event transects
  tar_target(event_transects, genera_event_transects(aux_transecto = prepara_tr)),

  ## Prepare abundance files
  tar_file(file_densidad, "data/raw_data/densidad_androcymbium.xlsx"),
  tar_target(raw_densidad, read_abundance(x = file_densidad)),

  ### Generate event abundance
  tar_target(event_abundance, genera_event_abundance(raw = raw_densidad)),

  # Prepare Variables
  ## Variables Dictionary
  tar_file(file_dic_variables, "data/raw_data/dic_variables_serpam.xlsx"),
  tar_target(prepara_variables, prepare_variables_dicc(file = file_dic_variables)),

  ## Occurence Files
  tar_file(file_occ_transectos, "data/raw_data/recubrimiento_especies.xlsx"),
  tar_target(occurrences_transectos, read_occurrences_tr(file = file_occ_transectos)),

  ## Taxonomy
  tar_target(taxaToResolve, prepare_taxaToResolve(raw_sps = occurrences_transectos)),
  tar_target(existingTaxa, check_new_taxa(
    taxaToResolve = taxaToResolve, path = "data/raw_data/")),
  tar_target(potential_taxa, get_potential_taxa(
      uniqueTaxa = existingTaxa, path = "data/raw_data/")),
  tar_target(taxonomy_valid, get_validated_taxonomy(file = "data/raw_data/potential_names.xlsx")),

  # Generate emof
  ### emof abundance
  tar_target(emof_abundances, genera_emof_abundance(raw = raw_densidad)),
  ### emof transects
  tar_target(emof_transects, genera_emof_transects(
      aux_transecto = prepara_tr,
      dic_variables = prepara_variables)),
  ### emof sps
  tar_target(emof_sps, genera_emof_sps(
    occurrences_transectos = occurrences_transectos,
    dic_variables = prepara_variables
  )),
  ## bind emofs
  tar_target(combine_emof,
             genera_emof(emof_abundances = emof_abundances,
                         emof_transects = emof_transects,
                         emof_sps = emof_sps)),

  # Generate occ
  ## occ abundance
  tar_target(occ_abundances, genera_occ_abundance(
      event_abundance = event_abundance,
      taxa_validate = taxonomy_valid)),
  ## occ sps
  tar_target(occ_sps, genera_occ_sps(
    occurrences_transectos =  occurrences_transectos,
    taxa_validate = taxonomy_valid)),
  ## bind occs
  tar_target(combine_occ,
             genera_occ(occ_abundances = occ_abundances,
                        occ_sps = occ_sps)),

  # Combine events
  tar_target(combine_events,
             genera_events(event_abundance = event_abundance,
                           event_transects = event_transects,
                           dicc_eventos = event_dic$dicc_eventos)),

  # Genera csvs
  tar_target(
    name = export_csvs,
    {
      write_csv(event_dic$dicc_eventos, "data/dwc_db/dicc_eventos.csv")
      write_csv(event_dic$parcelas_event, "data/dwc_db/dicc_eventos_parcela.csv")
      write_csv(event_dic$subplots_event, "data/dwc_db/dicc_eventos_subplots.csv")
      write_csv(event_dic$transectos_event, "data/dwc_db/dicc_eventos_transectos.csv")
      write_csv(event_abundance, "data/dwc_db/event_abundances.csv")
      write_csv(event_transects, "data/dwc_db/event_transectos.csv")
      write.csv(emof_abundances, "data/dwc_db/emof_abundances.csv")
      write.csv(emof_transects, "data/dwc_db/emof_transectos.csv")
      write.csv(emof_sps, "data/dwc_db/emof_sps.csv")
      write.csv(occ_abundances, "data/dwc_db/occ_abundances.csv")
      write.csv(occ_sps, "data/dwc_db/occ_sps.csv")
      write.csv(combine_emof, "data/dwca/emof.csv", row.names = FALSE)
      write.csv(combine_occ, "data/dwca/occ.csv", row.names = FALSE)
      write.csv(combine_events, "data/dwca/events.csv", row.names = FALSE)
    }
  ),

  # Genera reports
  tarchetypes::tar_render(report_network, "doc/network.Rmd"),
  tarchetypes::tar_render(report_abundance, "doc/prepare_dwc_abundances.Rmd"),
  tarchetypes::tar_render(report_occurences, "doc/generate_occurences.Rmd"),
  tarchetypes::tar_render(report_emof, "doc/generate_emof.Rmd"),
  tarchetypes::tar_render(report_events, "doc/generate_events.Rmd"),

  # sqls
  ### sqls
  tar_target(sql_abundance, print_sql(sql_path = "data/sql/sql_abundance.sql")),
  tar_target(sql_desnudo, print_sql(sql_path = "data/sql/sql_desnudo.sql")),
  tar_target(sql_musgo_liquen, print_sql(sql_path = "data/sql/sql_musgo_liquen.sql")),
  tar_target(sql_rec_total, print_sql(sql_path = "data/sql/sql_rec_total.sql")),
  tar_target(sql_rec_vegetal, print_sql(sql_path = "data/sql/sql_rec_vegetal.sql")),
  tar_target(sql_riqueza, print_sql(sql_path = "data/sql/sql_riqueza.sql")),
  tar_target(sql_diversidad, print_sql(sql_path = "data/sql/sql_diversidad.sql"))

)
