
read_abundance <- function(x) {
  raw <- readxl::read_excel(x, sheet = "densidad_1") |>
    clean_names()
  return(raw)
}


read_transects_data <- function(file, sheet, var_interes) {
  x <- readxl::read_excel(file, sheet = sheet) |>
    clean_names() |>
    mutate(transecto = paste0("T", transecto)) |>
    dplyr::select(etiqueta, transecto, fecha, {{ var_interes }}) |>
    rename(value = one_of({{ var_interes }})) |>
    mutate(variable = {{ var_interes }})
  return(x)
}

read_occurrences_tr <- function(file) {
  raw_sps <- readxl::read_excel(file) |>
    janitor::clean_names()
  return(raw_sps)
}
######################################################
# Prepare Dicc Variables
######################################################

prepare_variables_dicc <- function(file) {
  x <- readxl::read_excel(file) |>
    janitor::clean_names() |>
    rename(
      measurementType = name_var,
      measurementUnit = units,
      measurementMethod = methods,
      measurementRemarks = url_controlled
    )
  return(x)
}

######################################################
# Prepare Transects data
######################################################

prepare_transects <- function(x) {
  aux_transecto <- x |>
    pivot_wider(names_from = "variable", values_from = "value") |>
    mutate(aux = "CSIC-EEZ:SERPAM:AMOLADERAS") |>
    mutate(aux_date = gsub("-", "", fecha)) |>
    unite("parentEventID", c("aux", "etiqueta", "transecto"), remove = FALSE) |>
    unite("eventID", c("parentEventID", "aux_date"), remove = FALSE) |>
    rename(eventDate = aux_date) |>
    dplyr::select(-etiqueta, -transecto, -aux, -fecha)

  return(aux_transecto)
}

######################################################
# Prepare EVENT
######################################################

# Genera WKT from geoinfo
genera_wkt <- function(geo_file) {
  x <- sf::st_read(geo_file) |> janitor::clean_names()

  wkt <- x |>
    mutate(wkt = st_as_text(geometry)) |>
    st_set_geometry(NULL) |>
    as.data.frame()

  out <- wkt |>
    mutate(name_trat = case_when(
      tratamient == "G+C+" ~ "herbivorism (sheep, rabbit)",
      tratamient == "G-C+" ~ "livestock excluded",
      tratamient == "G-C-" ~ "rabbit and livestock excluded"
    ))

  return(out)
}

# Genera event
## Aux events
### Parcelas event
genera_event_parcelas_aux <- function(df) {
  event_parcelas_aux <- df |>
    mutate(
      bloque = paste0("Bloque ", bloque),
      dataset = "CSIC-EEZ:SERPAM:AMOLADERAS"
    ) |>
    unite(bloque:tratamient, col = "fieldNumber", sep = " | ") |>
    unite(c(dataset, parcela), col = "eventID", remove = FALSE, sep = "_") |>
    mutate(
      parentEventID = "",
      eventDate = "",
      samplingProtocol = "",
      sampleSizeValue = NA,
      sampleSizeUnit = "",
      footprintSRS = "epsg:25830",
      countryCode = "ES",
      stateProvinde = "AL",
      municipality = "Cabo de Gata",
      location = "Amoladeras"
    ) |>
    rename(
      footprintWKT = wkt,
      fieldNotes = name_trat
    ) |>
    relocate(footprintWKT, .after = sampleSizeUnit) |>
    relocate(c(fieldNumber, fieldNotes, parcela), .after = location) |>
    dplyr::select(-dataset)

  return(event_parcelas_aux)
}
### Subplot event
genera_event_subplot_aux <- function(df, parcelas_event_aux) {
  parcelas_event_parent <- parcelas_event_aux |>
    dplyr::select(eventID, parcela, fieldNumber) |>
    rename(parentEventID = eventID)

  subplots_event_aux <- df |>
    inner_join(parcelas_event_parent) |>
    mutate(replica = paste0("Q", subplot)) |>
    unite(c("parentEventID", "replica"),
      col = "eventID", remove = FALSE, sep = "_"
    ) |>
    mutate(
      eventDate = "",
      samplingProtocol = "Quadrat count",
      sampleSizeValue = 0.25,
      sampleSizeUnit = "m^2",
      footprintSRS = "epsg:25830",
      countryCode = "ES",
      stateProvinde = "AL",
      municipality = "Cabo de Gata",
      location = "Amoladeras"
    ) |>
    rename(
      footprintWKT = wkt,
      fieldNotes = name_trat
    ) |>
    relocate(footprintWKT, .after = sampleSizeUnit) |>
    relocate(c(parcela:tratamient, subplot, replica, fieldNumber, fieldNotes), .after = location) |>
    dplyr::select(-bloque, -tratamient)

  return(subplots_event_aux)
}
### Transect event aux
genera_event_transect_aux <- function(df, parcelas_event_aux) {
  parcelas_event_parent <- parcelas_event_aux |>
    dplyr::select(eventID, parcela, fieldNumber) |>
    rename(parentEventID = eventID)

  transectos_event_aux <- df |>
    inner_join(parcelas_event_parent) |>
    unite(c("parentEventID", "transecto"),
      col = "eventID", remove = FALSE, sep = "_"
    ) |>
    mutate(
      eventDate = "",
      samplingProtocol = "Point Quadrat Transect",
      sampleSizeValue = 2,
      sampleSizeUnit = "m",
      footprintSRS = "epsg:25830",
      countryCode = "ES",
      stateProvinde = "AL",
      municipality = "Cabo de Gata",
      location = "Amoladeras"
    ) |>
    rename(
      footprintWKT = wkt,
      fieldNotes = name_trat
    ) |>
    relocate(footprintWKT, .after = sampleSizeUnit) |>
    relocate(c(parcela, transecto, fieldNumber, fieldNotes), .after = location) |>
    dplyr::select(-bloque, -tratamient)
}

## Dicc event
genera_event_dic <- function(parcelas_event_aux,
                             subplots_event_aux,
                             transectos_event_aux) {
  parcelas_event <- parcelas_event_aux |>
    dplyr::select(-parcela)

  transectos_event <- transectos_event_aux |>
    dplyr::select(-parcela, -transecto)

  subplots_event <- subplots_event_aux |>
    dplyr::select(-parcela, -subplot, -replica)

  dicc_eventos <- bind_rows(
    parcelas_event,
    subplots_event,
    transectos_event
  )

  return(
    list(
      dicc_eventos = dicc_eventos,
      parcelas_event = parcelas_event,
      transectos_event = transectos_event,
      subplots_event = subplots_event
    )
  )
}


## Transect events
genera_event_transects <- function(aux_transecto) {
  event_transectos <- aux_transecto |>
    dplyr::select(eventID, parentEventID, eventDate) |>
    mutate(
      samplingProtocol = "Point Quadrat Transect",
      sampleSizeValue = 2,
      sampleSizeUnit = "m",
      footprintSRS = "epsg:25830",
      footprintWKT = "",
      countryCode = "",
      stateProvinde = "",
      municipality = "",
      location = ""
    )
  return(event_transectos)
}

genera_event_abundance <- function(raw) {
  event_abundance <- raw |>
    mutate(subreplicate = case_when(
      cuadrante == "Norte" ~ "QN",
      cuadrante == "Este" ~ "QE",
      cuadrante == "Sur" ~ "QS",
      cuadrante == "Oeste" ~ "QW"
    )) |>
    mutate(aux = "CSIC-EEZ:SERPAM:AMOLADERAS") |>
    mutate(aux_date = gsub("-", "", fecha)) |>
    unite("parentEventID", c("aux", "etiqueta", "subreplicate"), remove = FALSE) |>
    unite("eventID", c("parentEventID", "aux_date"), remove = FALSE) |>
    rename(eventDate = aux_date) |>
    mutate(
      samplingProtocol = "Quadrat count",
      sampleSizeValue = 0.25,
      sampleSizeUnit = "m^2",
      footprintWKT = "",
      footprintSRS = "",
      countryCode = "",
      stateProvinde = "",
      municipality = "",
      location = ""
    ) |>
    dplyr::select(-etiqueta, -anio_seg, -cuadrante, -n_individuos, -subreplicate, -aux, -fecha)

  return(event_abundance)
}


######################################################
# Prepare ExtendedMeasurementOrFact
######################################################

genera_emof_abundance <- function(raw) {
  emof_abundances <- raw |>
    rename(measurementValue = n_individuos) |> # abundance values
    mutate(measurementDeterminedDate = gsub("-", "", fecha)) |> # format Date
    mutate(subreplicate = case_when(
      cuadrante == "Norte" ~ "QN",
      cuadrante == "Este" ~ "QE",
      cuadrante == "Sur" ~ "QS",
      cuadrante == "Oeste" ~ "QW"
    )) |>
    mutate(eventID = paste(etiqueta, subreplicate, measurementDeterminedDate, sep = "_")) |> # Generate eventID
    mutate(eventID = paste("CSIC-EEZ:SERPAM:AMOLADERAS", eventID, sep = "_")) |> # Add SERPAM y AMOLADERAS
    mutate(measurementID = paste(eventID, "A01")) |> # Add variable code from dicc_variables
    mutate(
      measurementType = "abundance",
      measurementUnit = "number of individuals",
      measurementMethod = "direct count in quadrats of 50 x 50 cm",
      measurementRemarks = "https://vocabs.lter-europe.net/envthes/en/page/21541"
    ) |>
    dplyr::select(
      measurementID,
      eventID,
      measurementType,
      measurementValue,
      measurementUnit,
      measurementMethod,
      measurementDeterminedDate,
      measurementRemarks
    )

  return(emof_abundances)
}

genera_emof_transects <- function(aux_transecto, dic_variables) {
  emof_transects <- aux_transecto |>
    pivot_longer(-c(eventID, parentEventID, eventDate)) |>
    mutate(id_var = case_when(
      name == "n_especies" ~ "V20",
      name == "i_shannon_ln" ~ "V17",
      name == "rec_total" ~ "V06",
      name == "rec_vegetal" ~ "V03",
      name == "musgo_liquen" ~ "V28",
      name == "desnudo" ~ "V24"
    )) |>
    inner_join(dic_variables, by = c("id_var" = "id")) |>
    unite("measurementID", c(eventID, id_var), remove = FALSE) |>
    dplyr::select(
      measurementID,
      eventID,
      parentEventID,
      measurementType,
      measurementValue = value,
      measurementUnit,
      measurementMethod,
      measurementDeterminedDate = eventDate,
      measurementRemarks
    )
  return(emof_transects)
}


genera_emof_sps <- function(occurrences_transectos, dic_variables){
  emof_sps <- occurrences_transectos |>
    mutate(aux = "CSIC-EEZ:SERPAM:AMOLADERAS") |>
    mutate(transecto = paste0("T", transecto)) |>
    mutate(aux_date = gsub("-", "", fecha)) |>
    unite("eventID", c("aux", "etiqueta", "transecto", "aux_date"), remove = FALSE) |>
    rename(eventDate = aux_date) |>
    dplyr::select(-zona, -etiqueta, -transecto, -anio_seg, -porcent, -tratamientos, -bloques, -tipo_vegetacion, -aux) |>
    group_by(eventID) |>
    mutate(idocc = str_pad(row_number(eventID), 2, pad = "0")) |>
    unite("occurrenceID", c("eventID", "idocc"), sep = "_", remove = FALSE) |>
    mutate(aux_var = "V09") |>
    unite("measurementID", c("occurrenceID", "aux_var"), remove = FALSE) |>
    inner_join(dic_variables, c("aux_var" = "id")) |>
    dplyr::select(
      measurementID,
      eventID,
      measurementType,
      measurementValue = rec_veg,
      measurementUnit,
      measurementMethod,
      measurementDeterminedDate = eventDate,
      measurementRemarks
    )
  return(emof_sps)
}


genera_emof <- function(emof_abundances,
                        emof_transects,
                        emof_sps){

  emof <- bind_rows(
    emof_abundances,
    emof_sps,
    (emof_transects |> dplyr::select(-parentEventID))
  )

  return(emof)
}


##################
# prints sql
##################

print_sql <- function(sql_path) {
  x <- read_file(sql_path)
  glue::glue(x)
}




######################################################
# Occurrences Taxa
######################################################

prepare_taxaToResolve <- function(raw_sps) {
  taxaToResolve <- raw_sps |>
    arrange(nombre_cien) |>
    dplyr::select(nombre_cien) |>
    unique() |>
    pull()

  return(taxaToResolve)
}


check_new_taxa <- function(taxaToResolve, path) {
  if (length(list.files(path, pattern = "uniqueTaxa")) > 0) {
    existingTaxa <- read.csv(paste0(path, "uniqueTaxa.csv"))
    names(existingTaxa)[1] <- "taxa"


    # Taxa in taxaToResolve not included in existingTaxa
    new_taxa <- setdiff(taxaToResolve, existingTaxa$taxa)

    if (length(new_taxa) > 0) {
      new_rows <- data.frame(taxa = new_taxa)
      updatedExistingTaxa <- rbind(existingTaxa, new_rows)

      write.csv(updatedExistingTaxa,
        file = paste0(path, "uniqueTaxa.csv"),
        row.names = FALSE
      )

      return(updatedExistingTaxa)
    } else {
      return(existingTaxa)
    }
  } else {
    write.csv(taxaToResolve,
      file = paste0(path, "uniqueTaxa.csv"),
      row.names = FALSE
    )
    return(taxaToResolve)
  }
}


get_potential_taxa <- function(uniqueTaxa, path) {
  if (length(list.files(path, pattern = "potential_names.xlsx")) > 0) {
    p <- readxl::read_excel(path = paste0(path, "potential_names.xlsx"))

    # Remove Indeterminado
    uniqueTaxa <- uniqueTaxa[!grepl("Indeterminado", uniqueTaxa$taxa), ]

    new_uniqueTaxa <- setdiff(uniqueTaxa, unique(p$taxa_consulted))


    if (length(new_uniqueTaxa) > 0) {
      new_p <- taxize::get_gbifid_(new_uniqueTaxa)

      new_potential_taxa <-
        purrr::imap_dfr(new_p, ~ mutate(.x, taxa_consulted = .y)) |>
        mutate(selected = 0) |>
        relocate(taxa_consulted, scientificname, selected)


      potential_names <- bind_rows(p, new_potential_taxa)

      writexl::write_xlsx(potential_names, path = paste0(path, "potential_names.xlsx"))
    }
  } else {
    p <- taxize::get_gbifid_(uniqueTaxa)

    potential_taxa <- purrr::imap_dfr(p, ~ mutate(.x, taxa_consulted = .y)) |>
      mutate(selected = 0) |>
      relocate(taxa_consulted, scientificname, selected)

    writexl::write_xlsx(potential_taxa, path = paste0(path, "potential_names.xlsx"))
  }
}


get_validated_taxonomy <- function(file){
  x <- readxl::read_excel(file) |>
    filter(selected > 0) |>
    dplyr::select(
      taxa_consulted,
      scientificname,
      kingdom, phylum, order, family, class, genus
    )
  return(x)
  }



## Occurence abundance
genera_occ_abundance <- function(event_abundance, taxa_validated) {
  andro_occ <- event_abundance |>
    mutate(idocc = "01") |>
    mutate(taxa_consulted = "Androcymbium europaeum") |>
    unite("occurrenceID", c("eventID", "idocc"), sep = "_", remove = FALSE) |>
    inner_join(taxa_validated, by = "taxa_consulted") |>
    mutate(
      basisOfRecord = "Occurrence",
      institutionCode = "CSIC-EEZ",
      collectionCode = "SERPAM",
      datasetName = "AMOLADERAS",
      ownerInstitutionCode = "AMOLADERAS",
      language = "es"
    ) |>
    dplyr::select(occurrenceID, eventID, basisOfRecord, institutionCode, collectionCode,
                  datasetName, ownerInstitutionCode, language, scientificName = scientificname,
                  kingdom, phylum, class, order, family, genus)

  return(andro_occ)
}

## Occurence sps
genera_occ_sps <- function(occurrences_transectos, taxa_validate){
    occ_sps <- occurrences_transectos |>
      mutate(aux = "CSIC-EEZ:SERPAM:AMOLADERAS") |>
      mutate(transecto = paste0("T", transecto)) |>
      mutate(aux_date = gsub("-", "", fecha)) |>
      unite("eventID", c("aux", "etiqueta", "transecto", "aux_date"), remove = FALSE) |>
      rename(eventDate = aux_date) |>
      dplyr::select(-zona, -etiqueta, -transecto, -anio_seg, -porcent, -tratamientos, -bloques, -tipo_vegetacion, -aux) |>
      group_by(eventID) |>
      mutate(idocc = str_pad(row_number(eventID), 2, pad = "0")) |>
      unite("occurrenceID", c("eventID", "idocc"), sep = "_", remove = FALSE) |>
      inner_join(taxa_validate, c("nombre_cien" = "taxa_consulted")) |>
      mutate(basisOfRecord = "Occurrence",
             institutionCode = "CSIC-EEZ",
             collectionCode = "SERPAM",
             datasetName = "AMOLADERAS",
             ownerInstitutionCode = "AMOLADERAS",
             language = "es",
             eventID) |>
      dplyr::select(
        occurrenceID, basisOfRecord, institutionCode, collectionCode, datasetName, ownerInstitutionCode, language,
        scientificName = scientificname, kingdom:genus)
    return(occ_sps)

}


genera_occ <- function(occ_abundances,
                        occ_sps){
  occ <- bind_rows(
    occ_abundances,
    occ_sps
  )
  return(occ)
}

genera_events <- function(event_abundance,
                          event_transects,
                          dicc_eventos){
  events <- bind_rows(
    dicc_eventos,
    event_abundance,
    event_transects
  )
  return(events)
}







