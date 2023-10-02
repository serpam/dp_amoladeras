library(tidyverse)
library(gbifexplorer)
library(patchwork)

occ <- read_csv("data/dwca/occ.csv")[-1]

df <- taxonomic_cov(occ, "all")

## plot families

ord <- barplot_freq1(df$order, sort_by = "freq",
                    show_n = TRUE, label_color = "black", hjusttexto = - 0.2) +
  ggtitle("Order") +
  ylim(c(0,38))

ggsave(plot = ord,
       filename = here::here("doc/assets/cov_taxo_order.png"),
       height = 15, width = 15, units = "cm",
       dpi = 1200, device = "png")

fam <- barplot_freq1(df$family, sort_by = "freq", show_n = TRUE,
                    limit_freq = .1, label_color = "black", hjusttexto = - 0.2) +
  ggtitle("Family") + ylim(c(0,38))



ggsave(plot = fam,
       filename = here::here("doc/assets/cov_taxo_fam.png"),
       height = 15, width = 15, units = "cm",
       dpi = 1200, device = "png")




barplot_freq1 <- function(data, sort_by = c("freq", "name"),
         decreasing = TRUE, flip = TRUE,
         limit_freq = NULL,
         top = NULL,
         bar_color = "steelblue",
         show_n = FALSE,
         label_color = "white",
         hjusttexto = 1.5,  ...) {

  if (!inherits(data, c("data.frame", "tbl_df", "tbl"))) {
    stop("Invalid 'data' argument. Must be a data.frame or tibble.")
  }

  if (missing(sort_by) || is.null(sort_by) || length(sort_by) == 0) {
    sort_by <- "freq"
  } else if (!is.character(sort_by) || !(sort_by %in% c("freq", "name"))) {
    stop("Invalid 'sort_by' argument. Must be either 'freq' or 'name'.")
  }


  var_name <- setdiff(names(data), c("freq", "n"))

  if (!is.null(limit_freq)) {
    data <- subset(data, freq >= limit_freq)
  }

  if (!is.null(top)) {
    data <- data[order(-data$freq), ]
    data <- data[1:top, ]
  }


  if (sort_by == "freq") {
    g <- ggplot(data,
                aes(x = forcats::fct_reorder(!!sym(var_name), -freq, .desc = decreasing),
                    y = freq)) +
      geom_col(fill = bar_color, ...)
  } else if (sort_by == "name") {
    g <- ggplot(data,
                aes(x = forcats::fct_reorder(!!sym(var_name), !!sym(var_name), .desc = decreasing),
                    y = freq)) +
      geom_col(fill = bar_color, ...)
  }

  if (show_n) {
    g <- g + geom_text(aes(label = n), hjust = hjusttexto, colour = label_color, ...)
  }

  if (flip) {
    g <- g + coord_flip()
  }


  g <- g + xlab("") + ylab("% Records") + theme_bw()

  return(g)
}
