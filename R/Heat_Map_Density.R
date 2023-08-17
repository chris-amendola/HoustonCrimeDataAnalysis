library("palmerpenguins")

ggplot( penguins
       ,aes(flipper_length_mm
            ,bill_length_mm
            ,fill=species)) +
  geom_hdr( xlim = c(160, 240)
           ,ylim = c(30, 70)) +
  geom_point(shape = 21)