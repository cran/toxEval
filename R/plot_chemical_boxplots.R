
#' @export
#' @param site_counts This describes how to calculate the left-side counts.
#' Default is "count" which is number of sites with detections. "frequency" 
#' would calculate a percentage of detections. This assumes all 
#' non-detects have been included as 0 for a value. "none" is the
#' final option which can be to remove those labels. Custom labels
#' could then be constructed after this function is run. 
#' @param ... Additional group_by arguments. This can be handy for creating facet graphs.
#' @rdname plot_tox_boxplots
plot_chemical_boxplots <- function(chemical_summary, ...,
                                   manual_remove = NULL,
                                   mean_logic = FALSE,
                                   sum_logic = TRUE,
                                   plot_ND = TRUE,
                                   font_size = NA,
                                   title = NA,
                                   x_label = NA,
                                   palette = NA,
                                   hit_threshold = NA,
                                   site_counts = "count") {
  
  cbValues <- c(
    "#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33", "#A65628",
    "#DCDA4B", "#999999", "#00FFFF", "#CEA226", "#CC79A7", "#4E26CE",
    "#FFFF00", "#78C15A", "#79AEAE", "#FF0000", "#00FF00", "#B1611D",
    "#FFA500", "#F4426e", "#800000", "#808000"
  )

  if (nrow(chemical_summary) == 0) {
    stop("No rows in the chemical_summary data frame")
  }

  match.arg(site_counts, choices = c("count", "frequency", "none"))
  
  if (!plot_ND) {
    if ("meanEAR" %in% names(chemical_summary)) {
      chemical_summary <- chemical_summary[chemical_summary$meanEAR > 0, ]
    } else {
      chemical_summary <- chemical_summary[chemical_summary$EAR > 0, ]
    }
  }

  if (length(unique(chemical_summary$Class)) > length(cbValues)) {
    n <- length(unique(chemical_summary$Class))

    if (n > 20 && n < 30) {
      cbValues <- c(
        RColorBrewer::brewer.pal(n = 12, name = "Set3"),
        RColorBrewer::brewer.pal(n = 8, name = "Set2"),
        RColorBrewer::brewer.pal(n = max(c(3, n - 20)), name = "Set1")
      )
    } else if (n <= 20) {
      cbValues <- c(
        RColorBrewer::brewer.pal(n = 12, name = "Set3"),
        RColorBrewer::brewer.pal(n = max(c(3, n - 12)), name = "Set2")
      )
    } else {
      cbValues <- colorRampPalette(RColorBrewer::brewer.pal(11, "Spectral"))(n)
    }
  }

  single_site <- length(unique(chemical_summary$site)) == 1

  # Since the graph is rotated...
  if (is.na(x_label)) {
    y_label <- fancyLabels(category = "Chemical", mean_logic, sum_logic, single_site)
  } else {
    y_label <- x_label
  }

  if (single_site) {
    if ("meanEAR" %in% names(chemical_summary)) {
      message("meanEAR values should not be used in a single site boxplot")
      chemical_summary <- chemical_summary %>%
        dplyr::rename(EAR = meanEAR)

      if (!("date" %in% names(chemical_summary))) {
        chemical_summary$date <- 1
      }
    }

    # Single site order:
    orderColsBy <- chemical_summary %>%
      dplyr::mutate(logEAR = log(EAR)) %>%
      dplyr::group_by(chnm, Class, ...) %>%
      dplyr::summarise(median = stats::median(logEAR[!is.na(logEAR)], na.rm = TRUE)) %>%
      dplyr::arrange(median) %>%
      dplyr::ungroup()

    class_order <- orderColsBy %>%
      dplyr::group_by(Class, ...) %>%
      dplyr::summarise(max_med = max(median, na.rm = TRUE)) %>%
      dplyr::ungroup() %>%
      dplyr::arrange(max_med) %>%
      dplyr::mutate(Class = as.character(Class)) %>%
      dplyr::select(Class) %>%
      dplyr::distinct() %>%
      dplyr::pull(Class)

    orderedLevels <- chemical_summary %>%
      dplyr::mutate(logEAR = log(EAR)) %>%
      dplyr::group_by(chnm, Class, ...) %>%
      dplyr::summarise(median = stats::median(logEAR[!is.na(logEAR)])) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(
        Class = factor(Class, levels = rev(class_order)),
        chnm = as.character(chnm)
      ) %>%
      dplyr::arrange(Class, dplyr::desc(median)) %>%
      dplyr::select(chnm) %>%
      dplyr::distinct() %>%
      dplyr::pull(chnm)

    chemical_summary$Class <- factor(as.character(chemical_summary$Class), levels = rev(class_order))
    chemical_summary$chnm <- factor(as.character(chemical_summary$chnm), levels = rev(orderedLevels))

    countNonZero <- chemical_summary %>%
      dplyr::group_by(...) %>%
      dplyr::mutate(
        ymin = min(EAR[!is.na(EAR)], na.rm = TRUE),
        ymax = max(EAR[!is.na(EAR)], na.rm = TRUE)
      ) %>%
      dplyr::group_by(chnm, Class, ymin, ymax, ...) %>%
      dplyr::summarize(
        nonZero = as.character(length(unique(endPoint[!is.na(EAR)]))),
        percentDet = format(sum(!is.na(EAR))/(sum(!is.na(EAR)) + sum(is.na(EAR))), digits = 4),
        hits = as.character(sum(EAR[!is.na(EAR)] > hit_threshold))
      ) %>%
      dplyr::ungroup()

    countNonZero$hits[countNonZero$hits == "0"] <- ""
    
    if(site_counts == "count"){
      label <- "# Endpoints" 
      countNonZero$lab <- countNonZero$nonZero
    } else if(site_counts == "frequency") {
      label <- "% Detection"
      countNonZero$lab <- countNonZero$percentDet
    } else {
      label <- ""
      countNonZero$lab <- ""
    }
    

    pretty_logs_new <- prettyLogs(chemical_summary$EAR[!is.na(chemical_summary$EAR)])

    chemical_summary$EAR[chemical_summary$EAR == 0] <- NA

    toxPlot_All <- ggplot(data = chemical_summary)

    if (!all(is.na(palette))) {
      toxPlot_All <- toxPlot_All +
        geom_boxplot(aes(x = chnm, y = EAR, fill = chnm),
          lwd = 0.1, outlier.size = 1, na.rm = TRUE
        ) +
        scale_fill_manual(values = palette) +
        theme(legend.position = "none")
    } else {
      toxPlot_All <- toxPlot_All +
        geom_boxplot(aes(x = chnm, y = EAR, fill = Class),
          lwd = 0.1, outlier.size = 1, na.rm = TRUE
        )
    }
  } else {
    if ("EAR" %in% names(chemical_summary)) {
      graph_data <- graph_chem_data(
        chemical_summary = chemical_summary, ...,
        manual_remove = manual_remove,
        mean_logic = mean_logic,
        sum_logic = sum_logic
      )
    } else {
      graph_data <- chemical_summary
    }

    graph_data$meanEAR[graph_data$meanEAR == 0] <- NA
    pretty_logs_new <- prettyLogs(graph_data$meanEAR[!is.na(graph_data$meanEAR)])

    countNonZero <- graph_data %>%
      dplyr::group_by(...) %>%
      dplyr::mutate(
        ymin = min(meanEAR[!is.na(meanEAR)], na.rm = TRUE),
        ymax = max(meanEAR[!is.na(meanEAR)], na.rm = TRUE)
      ) %>%
      dplyr::group_by(chnm, Class, ymin, ymax, ...) %>%
      dplyr::summarize(
        nonZero = as.character(sum(!is.na(meanEAR))),
        percentDet = format(sum(!is.na(meanEAR))/(sum(!is.na(meanEAR)) + sum(is.na(meanEAR))), digits = 4),
        hits = as.character(sum(meanEAR[!is.na(meanEAR)] > hit_threshold))
      ) %>%
      dplyr::ungroup()

    countNonZero$hits[countNonZero$hits == "0"] <- ""
    
    if(site_counts == "count"){
      label <- "# Sites" 
      countNonZero$lab <- countNonZero$nonZero
    } else if(site_counts == "frequency") {
      label <- "% Detection"
      countNonZero$lab <- countNonZero$percentDet
    } else {
      label <- ""
      countNonZero$lab <- ""
    }
    

    toxPlot_All <- ggplot(data = graph_data)

    if (!all(is.na(palette))) {
      toxPlot_All <- toxPlot_All +
        geom_boxplot(aes(x = chnm, y = meanEAR, fill = Class),
          lwd = 0.1, outlier.size = 1, na.rm = TRUE
        ) +
        scale_fill_manual(values = palette) +
        theme(legend.position = "none")
    } else {
      toxPlot_All <- toxPlot_All +
        geom_boxplot(aes(x = chnm, y = meanEAR, fill = Class),
          lwd = 0.1, outlier.size = 1, na.rm = TRUE
        )
    }
  }

  toxPlot_All <- toxPlot_All +
    theme_bw() +
    scale_x_discrete(drop = TRUE) +
    geom_hline(
      yintercept = hit_threshold, linetype = "dashed",
      color = "black", na.rm = TRUE
    ) +
    theme(
      axis.text = element_text(color = "black"),
      axis.title.y = element_blank(),
      panel.background = element_blank(),
      plot.background = element_rect(fill = "transparent", colour = NA),
      strip.background = element_rect(fill = "transparent", colour = NA),
      strip.text.y = element_blank(),
      panel.border = element_blank(),
      axis.ticks = element_blank(),
      plot.title = element_text(hjust = 0.5)
    )

  if (isTRUE(y_label == "")) {
    toxPlot_All <- toxPlot_All +
      scale_y_log10(
        labels = fancyNumbers,
        breaks = pretty_logs_new
      ) +
      theme(axis.title.x = element_blank())
  } else {
    toxPlot_All <- toxPlot_All +
      scale_y_log10(y_label,
        labels = fancyNumbers,
        breaks = pretty_logs_new
      )
  }

  if (all(is.na(palette))) {
    toxPlot_All <- toxPlot_All +
      scale_fill_manual(values = cbValues, drop = FALSE) +
      guides(fill = guide_legend(ncol = 6)) +
      theme(
        legend.position = "bottom",
        legend.justification = "left",
        legend.background = element_rect(fill = "transparent", colour = "transparent"),
        legend.title = element_blank(),
        legend.key.height = unit(1, "line")
      )
  }

  if (!is.na(font_size)) {
    toxPlot_All <- toxPlot_All +
      theme(
        axis.text = element_text(size = font_size),
        axis.title = element_text(size = font_size)
      )
  }

  toxPlot_All <- toxPlot_All +
    coord_flip(clip = "off")

  labels_df <- countNonZero %>%
    dplyr::select(-chnm, -Class, -nonZero, -hits, -percentDet, -lab) %>%
    dplyr::distinct() %>%
    dplyr::mutate(
      x = Inf,
      label = label,
      hit_label = "# Hits"
    )

  if(site_counts != ""){
    toxPlot_All_withLabels <- toxPlot_All +
      geom_text(
        data = countNonZero, 
        aes(x = chnm, label = lab, y = ymin),
        size = ifelse(is.na(font_size), 2, 0.30 * font_size),
        position = position_nudge(y = -0.05)
      ) +
      geom_text(
        data = labels_df,
        aes(x = x, y = ymin, label = label),
        position = position_nudge(y = -0.05),
        size = ifelse(is.na(font_size), 3, 0.30 * font_size)
      )
  }


  if (!is.na(hit_threshold)) {
    toxPlot_All_withLabels <- toxPlot_All_withLabels +
      geom_text(
        data = countNonZero, aes(x = chnm, y = ymax, label = hits),
        size = ifelse(is.na(font_size), 2, 0.30 * font_size),
        position = position_nudge(y = 0.05)
      ) +
      geom_text(
        data = labels_df,
        aes(x = x, y = ymax, label = hit_label),
        position = position_nudge(y = 0.05),
        size = ifelse(is.na(font_size), 3, 0.30 * font_size)
      )
  }

  if (!all(is.na(title))) {
    toxPlot_All_withLabels <- toxPlot_All_withLabels +
      ggtitle(title)

    if (!is.na(font_size)) {
      toxPlot_All_withLabels <- toxPlot_All_withLabels +
        theme(plot.title = element_text(size = font_size))
    }
  }

  if (!is.na(hit_threshold)) {
    toxPlot_All_withLabels <- toxPlot_All_withLabels +
      geom_text(
        data = data.frame(x = Inf, y = hit_threshold, label = "Threshold", stringsAsFactors = FALSE),
        aes(x = x, y = y, label = label),
        size = ifelse(is.na(font_size), 3, 0.30 * font_size)
      )
  }

  return(toxPlot_All_withLabels)
}

#' @export
#' @param chemical_summary Data frame from \code{\link{get_chemical_summary}}.
#' @param manual_remove Vector of categories to remove.
#' @param mean_logic Logical. \code{TRUE} displays the mean sample from each site,
#' \code{FALSE} displays the maximum sample from each site.
#' @param sum_logic Logical. \code{TRUE} sums the EARs in a specified grouping,
#' \code{FALSE} does not. \code{FALSE} may be better for traditional benchmarks as
#' opposed to ToxCast benchmarks.
#' @param ... Additional group_by arguments. This can be handy for creating facet graphs.
#' @rdname graph_data_prep
graph_chem_data <- function(chemical_summary, ...,
                            manual_remove = NULL,
                            mean_logic = FALSE,
                            sum_logic = TRUE) {

  if (!sum_logic) {
    graphData <- chemical_summary %>%
      dplyr::group_by(site, chnm, Class, ...) %>%
      dplyr::summarise(meanEAR = ifelse(mean_logic, mean(EAR, na.rm = TRUE), max(EAR, na.rm = TRUE))) %>%
      dplyr::ungroup()
  } else {
    graphData <- chemical_summary %>%
      dplyr::group_by(site, date, chnm, ...) %>%
      dplyr::summarise(sumEAR = sum(EAR, na.rm = TRUE)) %>%
      dplyr::ungroup() %>%
      dplyr::group_by(site, chnm, ...) %>%
      dplyr::summarise(meanEAR = ifelse(mean_logic, mean(sumEAR, na.rm = TRUE), max(sumEAR, na.rm = TRUE))) %>%
      dplyr::ungroup() %>%
      dplyr::left_join(dplyr::distinct(dplyr::select(chemical_summary, chnm, Class)), by = "chnm")
  }

  if (!is.null(manual_remove)) {
    graphData <- dplyr::filter(graphData, !(chnm %in% manual_remove))
  }

  return(graphData)
}
