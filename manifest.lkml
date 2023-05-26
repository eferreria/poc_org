# project_name: "poc_org_storytelling"

# # Use local_dependency: To enable referencing of another project
# # on this instance with include: statements
#
# local_dependency: {
#   project: "name_of_other_project"
# }

visualization: {
  id: "treemap"
  label: "Tree Map"
  file: "visualizations/treemap.js"
}

visualization: {
  id: "force_directed"
  label: "Force Directed Graph"
  file: "visualizations/forced_directed.js"
}

# visualization: {
#   id: "org_chart"
#   label: "Org Chart"
#   file: "visualizations/custom_collapsible_tree_WIP.js"
# }


constant: VIS_LABEL {
  value: "Org Chart"
  export: override_optional
}

constant: VIS_ID {
  value: "org_chart"
  export:  override_optional
}

visualization: {
  id: "@{VIS_ID}"
  file: "visualizations/org_chart.js"
  label: "@{VIS_LABEL}"
}


visualization: {
  id: "eric_report_table_from_mkpl"
  file: "report_table.js"
  label: "Eric's Report Table"
}
