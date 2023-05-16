
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Monitoring data on the effect of domestic livestock and rabbits on *Androcymbium europaeum* pastures

This repo contains a workflow used to generate a dataset to be included
into GBIF rpository. The workflow was done using R wth `target` and
`tarchetypes` pkgs. You can see here:

``` mermaid
graph LR
  subgraph legend
    direction LR
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- x0a52b03877696646([""Outdated""]):::outdated
    x0a52b03877696646([""Outdated""]):::outdated --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- xf0bce276fe2b9d3e>""Function""]:::none
    xf0bce276fe2b9d3e>""Function""]:::none --- x5bffbffeae195fc9{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    xc33f6fb96dae4e3d>"print_sql"]:::uptodate --> x2152700dcfaffb47(["sql_riqueza"]):::uptodate
    xc33f6fb96dae4e3d>"print_sql"]:::uptodate --> xc1cca4783688b5cb(["sql_desnudo"]):::uptodate
    xa52ec9401425a86e(["event_abundance"]):::uptodate --> x832f5b298abde48b(["combine_events"]):::uptodate
    xd7fe5822c6d5409e(["event_dic"]):::uptodate --> x832f5b298abde48b(["combine_events"]):::uptodate
    x072865fb25808582(["event_transects"]):::uptodate --> x832f5b298abde48b(["combine_events"]):::uptodate
    xdc8501922250f648>"genera_events"]:::uptodate --> x832f5b298abde48b(["combine_events"]):::uptodate
    x69ee2610bff788d5>"genera_event_transects"]:::uptodate --> x072865fb25808582(["event_transects"]):::uptodate
    x20ad172d7f28f9cb(["prepara_tr"]):::uptodate --> x072865fb25808582(["event_transects"]):::uptodate
    xc33f6fb96dae4e3d>"print_sql"]:::uptodate --> xc70ed158bed1f117(["sql_musgo_liquen"]):::uptodate
    x99468b1f1b6b3c5d(["emof_abundances"]):::uptodate --> x415581bbb5c024a8(["report_emof"]):::uptodate
    xf1e832c5607d75ce(["emof_transects"]):::uptodate --> x415581bbb5c024a8(["report_emof"]):::uptodate
    x920006cc5ad4af29(["file_dic_variables"]):::uptodate --> x415581bbb5c024a8(["report_emof"]):::uptodate
    xe5bf712ffa3cf9cc(["prepara_variables"]):::uptodate --> x415581bbb5c024a8(["report_emof"]):::uptodate
    x3c64086fd9a9cf01(["sql_abundance"]):::uptodate --> x415581bbb5c024a8(["report_emof"]):::uptodate
    xc1cca4783688b5cb(["sql_desnudo"]):::uptodate --> x415581bbb5c024a8(["report_emof"]):::uptodate
    x176f1cb70bb9e3b2(["sql_diversidad"]):::uptodate --> x415581bbb5c024a8(["report_emof"]):::uptodate
    xc70ed158bed1f117(["sql_musgo_liquen"]):::uptodate --> x415581bbb5c024a8(["report_emof"]):::uptodate
    x4e8a2800cd6b89ed(["sql_rec_total"]):::uptodate --> x415581bbb5c024a8(["report_emof"]):::uptodate
    x5ae7ac95bb54383a(["sql_rec_vegetal"]):::uptodate --> x415581bbb5c024a8(["report_emof"]):::uptodate
    x2152700dcfaffb47(["sql_riqueza"]):::uptodate --> x415581bbb5c024a8(["report_emof"]):::uptodate
    x3a8f779fd66c62b0>"read_transects_data"]:::uptodate --> xae88a44758d5d1fd(["read_tr_desnudo"]):::uptodate
    x87210fd9f0bb47ca(["existingTaxa"]):::uptodate --> x290c27495d88c724(["potential_taxa"]):::uptodate
    x76bdfa040b15406f>"get_potential_taxa"]:::uptodate --> x290c27495d88c724(["potential_taxa"]):::uptodate
    x00cd3e53e66a8656>"genera_wkt"]:::uptodate --> x017317243c9baf65(["wkt_parcelas"]):::uptodate
    xdca35d5bc9886a6b(["geo_parcelas"]):::uptodate --> x017317243c9baf65(["wkt_parcelas"]):::uptodate
    xa52ec9401425a86e(["event_abundance"]):::uptodate --> xb57c27916351bfa6(["occ_abundances"]):::uptodate
    x7a49490f874e129d>"genera_occ_abundance"]:::uptodate --> xb57c27916351bfa6(["occ_abundances"]):::uptodate
    x8e52ae8c3afc7bfc(["taxonomy_valid"]):::uptodate --> xb57c27916351bfa6(["occ_abundances"]):::uptodate
    x96898cd6ed89230b>"genera_event_abundance"]:::uptodate --> xa52ec9401425a86e(["event_abundance"]):::uptodate
    x1e5a6403ddb91e66(["raw_densidad"]):::uptodate --> xa52ec9401425a86e(["event_abundance"]):::uptodate
    x03cb39451a3fd4aa(["file_densidad"]):::uptodate --> x1e5a6403ddb91e66(["raw_densidad"]):::uptodate
    x0b1d40b781263c9d>"read_abundance"]:::uptodate --> x1e5a6403ddb91e66(["raw_densidad"]):::uptodate
    xbab19bece9a49ac9>"genera_emof_transects"]:::uptodate --> xf1e832c5607d75ce(["emof_transects"]):::uptodate
    x20ad172d7f28f9cb(["prepara_tr"]):::uptodate --> xf1e832c5607d75ce(["emof_transects"]):::uptodate
    xe5bf712ffa3cf9cc(["prepara_variables"]):::uptodate --> xf1e832c5607d75ce(["emof_transects"]):::uptodate
    x99468b1f1b6b3c5d(["emof_abundances"]):::uptodate --> x2eef08cba3c7d5de(["combine_emof"]):::uptodate
    x4c8afe54a98b6434(["emof_sps"]):::uptodate --> x2eef08cba3c7d5de(["combine_emof"]):::uptodate
    xf1e832c5607d75ce(["emof_transects"]):::uptodate --> x2eef08cba3c7d5de(["combine_emof"]):::uptodate
    x76cc4671e87eddc3>"genera_emof"]:::uptodate --> x2eef08cba3c7d5de(["combine_emof"]):::uptodate
    xeef052802404f1ba(["event_parcelas_aux"]):::uptodate --> x9036b01156386f8b(["event_subplot_aux"]):::uptodate
    x952007ca132762eb>"genera_event_subplot_aux"]:::uptodate --> x9036b01156386f8b(["event_subplot_aux"]):::uptodate
    xa62eab2ac45ccff4(["wkt_subplots"]):::uptodate --> x9036b01156386f8b(["event_subplot_aux"]):::uptodate
    x41f8e1683172e427>"check_new_taxa"]:::uptodate --> x87210fd9f0bb47ca(["existingTaxa"]):::uptodate
    xebb7990628f73124(["taxaToResolve"]):::uptodate --> x87210fd9f0bb47ca(["existingTaxa"]):::uptodate
    x741a5cbe3c2daa1e(["combina_tr"]):::uptodate --> x20ad172d7f28f9cb(["prepara_tr"]):::uptodate
    x6857653ec5510350>"prepare_transects"]:::uptodate --> x20ad172d7f28f9cb(["prepara_tr"]):::uptodate
    xc33f6fb96dae4e3d>"print_sql"]:::uptodate --> x4e8a2800cd6b89ed(["sql_rec_total"]):::uptodate
    x3a8f779fd66c62b0>"read_transects_data"]:::uptodate --> xd364d0470e7ef128(["read_tr_div"]):::uptodate
    xb57c27916351bfa6(["occ_abundances"]):::uptodate --> xa16dff654df1ef36(["report_occurences"]):::uptodate
    xc33f6fb96dae4e3d>"print_sql"]:::uptodate --> x176f1cb70bb9e3b2(["sql_diversidad"]):::uptodate
    xf300c1ce28aec4e4>"genera_event_parcelas_aux"]:::uptodate --> xeef052802404f1ba(["event_parcelas_aux"]):::uptodate
    x017317243c9baf65(["wkt_parcelas"]):::uptodate --> xeef052802404f1ba(["event_parcelas_aux"]):::uptodate
    xeef052802404f1ba(["event_parcelas_aux"]):::uptodate --> xc669c4a39d8bd823(["event_transect_aux"]):::uptodate
    xcfa3ff7f90a23eca>"genera_event_transect_aux"]:::uptodate --> xc669c4a39d8bd823(["event_transect_aux"]):::uptodate
    xcd9f62bcf316cad2(["wkt_transectos"]):::uptodate --> xc669c4a39d8bd823(["event_transect_aux"]):::uptodate
    x4330aa211db74749>"genera_emof_sps"]:::uptodate --> x4c8afe54a98b6434(["emof_sps"]):::uptodate
    x24befd0cd3dfbd21(["occurrences_transectos"]):::uptodate --> x4c8afe54a98b6434(["emof_sps"]):::uptodate
    xe5bf712ffa3cf9cc(["prepara_variables"]):::uptodate --> x4c8afe54a98b6434(["emof_sps"]):::uptodate
    x3a8f779fd66c62b0>"read_transects_data"]:::uptodate --> xe190917a5a92610e(["read_tr_riq"]):::uptodate
    xae88a44758d5d1fd(["read_tr_desnudo"]):::uptodate --> x741a5cbe3c2daa1e(["combina_tr"]):::uptodate
    xd364d0470e7ef128(["read_tr_div"]):::uptodate --> x741a5cbe3c2daa1e(["combina_tr"]):::uptodate
    x38b4f861c9b02d50(["read_tr_musgo"]):::uptodate --> x741a5cbe3c2daa1e(["combina_tr"]):::uptodate
    x835ebf616149aa51(["read_tr_rec_tot"]):::uptodate --> x741a5cbe3c2daa1e(["combina_tr"]):::uptodate
    x44ed6427bbcca087(["read_tr_rec_veg"]):::uptodate --> x741a5cbe3c2daa1e(["combina_tr"]):::uptodate
    xe190917a5a92610e(["read_tr_riq"]):::uptodate --> x741a5cbe3c2daa1e(["combina_tr"]):::uptodate
    x3a8f779fd66c62b0>"read_transects_data"]:::uptodate --> x38b4f861c9b02d50(["read_tr_musgo"]):::uptodate
    xd653ca3e9c9d33f0>"genera_occ_sps"]:::uptodate --> xa6a31767d743a47a(["occ_sps"]):::uptodate
    x24befd0cd3dfbd21(["occurrences_transectos"]):::uptodate --> xa6a31767d743a47a(["occ_sps"]):::uptodate
    x8e52ae8c3afc7bfc(["taxonomy_valid"]):::uptodate --> xa6a31767d743a47a(["occ_sps"]):::uptodate
    x6af5206652622a72>"genera_occ"]:::uptodate --> x716b6fcc30a9a345(["combine_occ"]):::uptodate
    xb57c27916351bfa6(["occ_abundances"]):::uptodate --> x716b6fcc30a9a345(["combine_occ"]):::uptodate
    xa6a31767d743a47a(["occ_sps"]):::uptodate --> x716b6fcc30a9a345(["combine_occ"]):::uptodate
    xc33f6fb96dae4e3d>"print_sql"]:::uptodate --> x5ae7ac95bb54383a(["sql_rec_vegetal"]):::uptodate
    xc33f6fb96dae4e3d>"print_sql"]:::uptodate --> x3c64086fd9a9cf01(["sql_abundance"]):::uptodate
    x2eef08cba3c7d5de(["combine_emof"]):::uptodate --> xe20878433fe1bf74(["export_csvs"]):::uptodate
    x832f5b298abde48b(["combine_events"]):::uptodate --> xe20878433fe1bf74(["export_csvs"]):::uptodate
    x716b6fcc30a9a345(["combine_occ"]):::uptodate --> xe20878433fe1bf74(["export_csvs"]):::uptodate
    x99468b1f1b6b3c5d(["emof_abundances"]):::uptodate --> xe20878433fe1bf74(["export_csvs"]):::uptodate
    x4c8afe54a98b6434(["emof_sps"]):::uptodate --> xe20878433fe1bf74(["export_csvs"]):::uptodate
    xf1e832c5607d75ce(["emof_transects"]):::uptodate --> xe20878433fe1bf74(["export_csvs"]):::uptodate
    xa52ec9401425a86e(["event_abundance"]):::uptodate --> xe20878433fe1bf74(["export_csvs"]):::uptodate
    xd7fe5822c6d5409e(["event_dic"]):::uptodate --> xe20878433fe1bf74(["export_csvs"]):::uptodate
    x072865fb25808582(["event_transects"]):::uptodate --> xe20878433fe1bf74(["export_csvs"]):::uptodate
    xb57c27916351bfa6(["occ_abundances"]):::uptodate --> xe20878433fe1bf74(["export_csvs"]):::uptodate
    xa6a31767d743a47a(["occ_sps"]):::uptodate --> xe20878433fe1bf74(["export_csvs"]):::uptodate
    xeef052802404f1ba(["event_parcelas_aux"]):::uptodate --> xc0c99df44193f78d(["report_events"]):::uptodate
    x9036b01156386f8b(["event_subplot_aux"]):::uptodate --> xc0c99df44193f78d(["report_events"]):::uptodate
    x00cd3e53e66a8656>"genera_wkt"]:::uptodate --> xa62eab2ac45ccff4(["wkt_subplots"]):::uptodate
    x9c161f6f5364737a(["geo_subplots"]):::uptodate --> xa62eab2ac45ccff4(["wkt_subplots"]):::uptodate
    x3a8f779fd66c62b0>"read_transects_data"]:::uptodate --> x44ed6427bbcca087(["read_tr_rec_veg"]):::uptodate
    x24befd0cd3dfbd21(["occurrences_transectos"]):::uptodate --> xebb7990628f73124(["taxaToResolve"]):::uptodate
    x897acc821a4b7e54>"prepare_taxaToResolve"]:::uptodate --> xebb7990628f73124(["taxaToResolve"]):::uptodate
    x6e95a40ece32b8d2>"get_validated_taxonomy"]:::uptodate --> x8e52ae8c3afc7bfc(["taxonomy_valid"]):::uptodate
    x920006cc5ad4af29(["file_dic_variables"]):::uptodate --> xe5bf712ffa3cf9cc(["prepara_variables"]):::uptodate
    x3ec7a2cd9a817739>"prepare_variables_dicc"]:::uptodate --> xe5bf712ffa3cf9cc(["prepara_variables"]):::uptodate
    x00cd3e53e66a8656>"genera_wkt"]:::uptodate --> xcd9f62bcf316cad2(["wkt_transectos"]):::uptodate
    x62e24a006268ef52(["geo_transectos"]):::uptodate --> xcd9f62bcf316cad2(["wkt_transectos"]):::uptodate
    x3a8f779fd66c62b0>"read_transects_data"]:::uptodate --> x835ebf616149aa51(["read_tr_rec_tot"]):::uptodate
    xeef052802404f1ba(["event_parcelas_aux"]):::uptodate --> xd7fe5822c6d5409e(["event_dic"]):::uptodate
    x9036b01156386f8b(["event_subplot_aux"]):::uptodate --> xd7fe5822c6d5409e(["event_dic"]):::uptodate
    xc669c4a39d8bd823(["event_transect_aux"]):::uptodate --> xd7fe5822c6d5409e(["event_dic"]):::uptodate
    x5d9546561a06f2ac>"genera_event_dic"]:::uptodate --> xd7fe5822c6d5409e(["event_dic"]):::uptodate
    x505ed9035a9b6b3a(["file_occ_transectos"]):::uptodate --> x24befd0cd3dfbd21(["occurrences_transectos"]):::uptodate
    x01279f0248051ba4>"read_occurrences_tr"]:::uptodate --> x24befd0cd3dfbd21(["occurrences_transectos"]):::uptodate
    x99468b1f1b6b3c5d(["emof_abundances"]):::uptodate --> x7bf683264c3e9bc5(["report_abundance"]):::uptodate
    xa52ec9401425a86e(["event_abundance"]):::uptodate --> x7bf683264c3e9bc5(["report_abundance"]):::uptodate
    x3c64086fd9a9cf01(["sql_abundance"]):::uptodate --> x7bf683264c3e9bc5(["report_abundance"]):::uptodate
    x36df08c0cfe652c9>"genera_emof_abundance"]:::uptodate --> x99468b1f1b6b3c5d(["emof_abundances"]):::uptodate
    x1e5a6403ddb91e66(["raw_densidad"]):::uptodate --> x99468b1f1b6b3c5d(["emof_abundances"]):::uptodate
    x612fea3437c58ef5(["report_network"]):::uptodate --> x612fea3437c58ef5(["report_network"]):::uptodate
    x2a664312aaa15e57{{"mapped"}}:::outdated --> x2a664312aaa15e57{{"mapped"}}:::outdated
    xe430b33a25d7faf7{{"parameters_transects"}}:::uptodate --> xe430b33a25d7faf7{{"parameters_transects"}}:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 113 stroke-width:0px;
  linkStyle 114 stroke-width:0px;
  linkStyle 115 stroke-width:0px;
```

## Credits

- **Data Set**: Ana Belén Robles Cruz, María Eugenia Ramos-Font,
  Mauro J. Tognetti Barbieri, Antonio J. Pérez-Luque, Clara Montoya
  Román, Claudia Tribaldos Anda. 2023.

- **repository & code:** [Antonio J.
  Pérez-Luque](https://github.com/ajpelu)
