## ----tabIMAGE, echo=FALSE-----------------------------------------------------
knitr::include_graphics("tabs.png")

## ----updateIMAGE, echo=FALSE--------------------------------------------------
knitr::include_graphics("data.png")

## -----------------------------------------------------------------------------
library(toxEval)
library(ggplot2)

CAS <- c("1912-24-9")
default_id = c(5, 6, 11, 15, 18)

ACC_atrazine <- get_ACC(CAS) |> 
  dplyr::arrange(ACC_value) |> 
  dplyr::mutate(index = dplyr::row_number(),
                percent = 100*index/dplyr::n(),
                has_default_flag = colSums(sapply(flags, "%in%", x = default_id)) > 0)

ggplot() +
  geom_point(data = ACC_atrazine,
             aes(x = ACC_value, y = percent,
                 color = has_default_flag)) +
  xlab("ACC ug/L") +
  ylab("Percentile") +
  ggtitle("Individual ACC values for Atrazine") +
  geom_text(data = head(ACC_atrazine |> 
                          dplyr::filter(!has_default_flag),
                        n = 5),
            aes(y = percent, x = ACC_value,
                label = endPoint,
                color = has_default_flag), 
             size = 2, hjust = -0.2, show.legend = FALSE) +
  theme_bw() +
  scale_color_manual("Includes default\nflags for removal", 
                     values = c("blue", "grey80"))


