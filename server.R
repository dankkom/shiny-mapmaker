library(shiny)

source("helpers.R", encoding = "utf-8")


shinyServer(
    function(input, output, session) {
        userdata <- eventReactive(
            input$choice,
            {
                user_file <- input$user_file
                req(user_file)
                d <- load.userdata(user_file$datapath)
                regions.table <- load.regions.table("DTB_BRASIL_MUNICIPIO.xls")
                region.level <- identify.region.level(d, regions.table)
                g <- load.geometry(region.level)
                gd <- join.data(g, d)
                vars <- names(d)
                vars <- vars[!vars %in% c("Key")]
                updateSelectInput(
                    session,
                    "columns",
                    "Select Columns",
                    choices = vars
                )
                gd
            }
        )

        output$map_plot <- renderPlot(
            make.map(
                userdata(),
                input$columns,
                input$color,
                input$log_values
            )
        )

        output$image_download <- downloadHandler(
            filename = function() {
                paste(
                    "map",
                    format(Sys.time(), "%Y%m%d%H%M%S"),
                    ".png",
                    sep = ""
                )
            },
            content = function(file) {
                tmap_save(
                    make.map(
                        userdata(),
                        input$columns,
                        input$color,
                        input$log_values
                    ),
                    file
                )
            }
        )
    }
)
