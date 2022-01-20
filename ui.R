library(shiny)


shinyUI(
    fluidPage(

        includeCSS("styles.css"),

        titlePanel(
            "MapMaker",
            windowTitle = "MapMaker"
        ),

        hr(),

        fluidRow(
            column(3,
                fileInput("user_file", label = "File"),
                actionButton("choice", "incorporate external information"),
            ),
            column(4,
                selectInput("columns", "Select Columns", choices = NULL)
            ),
            column(3,
                selectInput(
                    "color", 
                    "Select color", 
                    choices = c(
                        "Blues", "Greens", "Greys", "Oranges", "Purples",
                        "Reds", "viridis", "magma", "plasma", "inferno",
                        "cividis"
                    )
                ),
                checkboxInput("log_values", "Log scale", FALSE),
                downloadButton("image_download", "Download")
            ),
        ),

        hr(),

        # Saída de plot
        plotOutput("map_plot", width = "1280px", height = "720px"),

        hr(),

        # Rodapé do aplicativo, contém aviso de direitos autorais, entre outros.
        div(
            p(
                paste(
                    "Copyright 2019-",
                    format(Sys.Date(), "%Y"),
                    ". All rights reserved.",
                    sep = ""
                ),
            ),
            class = "footer"
        )
    )
)
