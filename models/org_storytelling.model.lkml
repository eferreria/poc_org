connection: "looker_private_demo" #for gcpl234
# connection: "ef-bq"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

datagroup: default_datagroup {
  sql_trigger: select extract(month from current_date) ;;

}

explore: org {}


explore: order_items {
  join: inventory_items {
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    type: left_outer
    relationship: many_to_one
  }

  join: users {
    sql_on: ${order_items.user_id} = ${users.id} ;;
    type: left_outer
    relationship: many_to_one
  }

  join: products {
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    type: left_outer
    relationship: many_to_one
  }
}
