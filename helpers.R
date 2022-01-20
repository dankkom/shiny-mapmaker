library(dplyr)
library(readxl)
library(rgdal)
library(tmap)


load.geometry <- function(region.level) {
    print(paste("load.geometry", region.level))
    n <- strsplit(region.level, ":")[[1]][1]
    m <- strsplit(region.level, ":")[[1]][2]
    if (n == "UF") {
        filepath <- "BRUFE250GC_SIR.json"
    } else if (n == "MU") {
        filepath <- "BRMUE250GC_SIR.json"
    } else if (n == "SP") {
        filepath <- "sp_mun.json"
    }
    geo <- readOGR(
        filepath,
        use_iconv = TRUE,
        encoding = "utf-8",
        p4s = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84"
    )
    if (m == "NAME") {
        colnames(geo@data) <- sub("^NM_.*", "Key", colnames(geo@data))
    } else if (m == "CODE") {
        colnames(geo@data) <- sub("^CD_GEOC.*", "Key", colnames(geo@data))
    }
    geo
}


make.map <- function(geo.data, columns, color, log_values) {
    if (log_values) {
        style = "log10_pretty"
    } else {
        style = "cont"
    }
    tm_shape(geo.data) +
        tm_polygons(
            col = columns,
            style = style,
            palette = color,
            border.alpha = 0.1) +
        tm_scale_bar(position = c("right", "top")) +
        tm_layout(
            outer.margins = c(0, 0, 0, 0),
            inner.margins = c(0, 0, 0, 0)
        )
}


load.userdata <- function(datapath) {
    user.data <- read_excel(
        datapath,
        na = c("...", "..", ".", "#N/A", "-", "X", "")
    )
    names(user.data)[1] <- "Key"
    user.data[["Key"]] <- as.factor(
        toupper(
            as.character(user.data[["Key"]])
        )
    )
    user.data
}


summarise.userdata <- function(userdata, func=mean) {
    userdata %>%
        group_by(Key) %>%
        summarise_all(func)
}


load.regions.table <- function(filepath) {
    regions.table <- read_excel(filepath)
    regions.table <- regions.table %>% mutate_all(toupper)
    regions.table
}


identify.region.level <- function(userdata, regions.table) {
    region.level <- "UNKNOWN"

    unique.keys <- unique(userdata[["Key"]])
    n.keys <- length(unique.keys)

    if (n.keys <= 27) {
        if (length(setdiff(unique.keys, regions.table[["UF"]])) == 0) {
            region.level <- "UF:CODE"
        } else if (length(setdiff(unique.keys, regions.table[["Nome_UF"]])) == 0) {
            region.level <- "UF:NAME"
        } else if (length(setdiff(unique.keys, regions.table[["Sigla_UF"]])) == 0) {
            region.level <- "UF:SG"
        }
    }

    if (length(setdiff(unique.keys, regions.table[["Código Município Completo"]])) == 0) {
        region.level <- "MU:CODE"
    } else if (length(setdiff(unique.keys, regions.table[["Nome_Município"]])) == 0) {
        region.level <- "MU:NAME"
    } else if (length(setdiff(unique.keys, regions.table[["Nome_Município_SG"]])) == 0) {
        region.level <- "MU:NAME:SG"
    }

    sp <- filter(regions.table, UF == "35")
    if (length(setdiff(unique.keys, sp[["Código Município Completo"]])) == 0) {
        region.level <- "SP:CODE"
    } else if (length(setdiff(unique.keys, sp[["Nome_Município"]])) == 0) {
        region.level <- "SP:NAME"
    } else if (length(setdiff(unique.keys, sp[["Nome_Município_SG"]])) == 0) {
        region.level <- "SP:NAME:SG"
    }

    region.level
}


join.data <- function(g, d, func=mean) {
    merge(g, summarise.userdata(d, func = func), by = "Key")
}
