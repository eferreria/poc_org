connection: "ef-bq"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

datagroup: default_datagroup {
  sql_trigger: select extract(month from current_date) ;;

}

explore: org {}
