view: org {
derived_table: {
  sql:
    select *
    , ROUND(RAND()*10) as fte_rand
    , ROUND(RAND()*1000,0) as job_code_rand
    , ROUND(RAND()*4 + 1) as product_line
    , ROUND(RAND()*3 + 1) as business_line
    from `looker-private-demo.thelook.users`
    where city is not null and state is not null and country = 'USA'
    and EXTRACT(year from created_at) > 2021
    AND cast(right(cast(abs(farm_fingerprint(city)) as string),1) as numeric) > 5
    ;;
    # datagroup_trigger: default_datagroup
  }
  # sql_table_name: `looker-private-demo.thelook.users`;;
  # drill_fields: [id]

  dimension: id {
    group_label: "Employee Demographics"
    primary_key: yes
    type: number
    label: "Employee ID"
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    hidden: yes
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: city {
    type: string
    hidden: yes
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    hidden: yes
    sql: ${TABLE}.country ;;
  }

  dimension: state {
    group_label: "Employee Demographics"
    type: string
    map_layer_name: us_states
    # hidden: yes
    sql: ${TABLE}.state ;;
  }


  # dimension: email {
  #   group_label: "Employee Demographics"
  #   type: string
  #   sql: ${TABLE}.email ;;
  # }

  dimension: first_name {
    group_label: "Employee Demographics"
    type: string
    sql: INITCAP(${TABLE}.first_name) ;;
  }

  dimension: gender {
    group_label: "Employee Demographics"
    # hidden: yes
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    group_label: "Employee Demographics"
    type: string
    sql: INITCAP(${TABLE}.last_name) ;;
  }
  dimension: full_name {
    group_label: "Employee Demographics"
    type: string
    sql: ${last_name} || ', ' || ${first_name} ;;
  }

  dimension: worker_type {
    group_label: "Employee Demographics"
    type: string
    sql:
    case when ${core_dev_fte} = 1 OR ${core_prod_fte} = 1 or ${ma_one_time_fte} = 1 then 'Employee' else 'Contingent Worker' end
    ;;
  }

  dimension: contingent_worker_supplier {
    group_label: "Employee Demographics"
    type: string
    sql:
    case when ${core_dev_fte} = 1 OR ${core_prod_fte} = 1 or ${ma_one_time_fte} = 1 then '' else 'Nationwide Contract Workers' end
    ;;
  }

  dimension: funding_organization {
    group_label: "Company, Division & Cost Center"
    type: string
    sql:
    case ${division}
      when 0 then 'International'
      when 1 then 'Canada'
      when 2 then 'Technology'
      when 3 then 'Consumer Information Solutions'
      when 4 then 'EWS'
      when 5 then 'USIS'
    end
    ;;
  }

  dimension: company {
    group_label: "Company, Division & Cost Center"
    type: number
    sql: right(cast(abs(farm_fingerprint(${country})) as string),3) ;;
  }

  dimension: division {
    group_label: "Company, Division & Cost Center"
    type: number
    sql: round(cast(right(cast(abs(farm_fingerprint(${state})) as string),1) as numeric)/2) ;;
  }

  dimension: cost_center {
    group_label: "Company, Division & Cost Center"
    type: number
    sql: right(cast(abs(farm_fingerprint(${city})) as string),5) ;;
  }

  dimension_group: reduction {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  dimension: business_line {
    group_label: "Business, Product & Platform"
    type: string
    sql:
    case ${TABLE}.business_line
      when 1 then 'AI Consulting'
      when 2 then 'Blockchain Development'
      when 3 then 'Cybersecurity Consulting'
      else 'Data Analytics Services'
    end
    ;;
    drill_fields: [business_line, product_line, platform]
  }

  dimension: product_line {
    group_label: "Business, Product & Platform"
    type: string
    # sql: 'State of ' || ${state} || ' Product Line' ;;
    sql:
    case ${TABLE}.business_line
      when 1 then -- 'AI Consulting'
        case ${TABLE}.product_line
          when 1 then 'AI-powered customer service'
          when 2 then 'AI-powered fraud detection'
          when 3 then 'AI-powered marketing'
          when 4 then 'AI-powered sales'
          else 'AI-powered supply chain management'
        end
      when 2 then -- 'Blockchain Development'
        case ${TABLE}.product_line
          when 1 then 'Blockchain-based payment systems'
          when 2 then 'Blockchain-based asset management systems'
          when 3 then 'Blockchain-based supply chain management systems'
          when 4 then 'Blockchain-based identity management systems'
          else 'Blockchain-based voting systems'
        end
      when 3 then -- 'Cybersecurity Consulting'
        case ${TABLE}.product_line
          when 1 then 'Cybersecurity assessments'
          when 2 then 'Cybersecurity training'
          when 3 then 'Cybersecurity audits'
          when 4 then 'Cybersecurity compliance'
          else 'Cybersecurity incident response'
        end
      else  -- 'Data Analytics Services'
        case ${TABLE}.product_line
          when 1 then 'Data visualization'
          when 2 then 'Data mining'
          when 3 then 'Machine learning'
          when 4 then 'Natural language processing'
          else 'Text analytics'
        end
    end ;;
    drill_fields: [business_line, product_line, platform]
  }

  dimension: platform {
    group_label: "Business, Product & Platform"
    type: string
    # sql: 'Project ' || ${state} ;;
    sql: 'Project-'||${TABLE}.business_line||${TABLE}.product_line||CAST(ROUND(RAND()*1+1)AS string) ;;
    drill_fields: [business_line, product_line, platform]
  }

  dimension: job_profile {
    group_label: "Employee Demographics"
    type: string
    sql:
    case
      when ${job_code} < 1 then 'President'
      when ${job_code} < 4 then 'Vice President'
      when ${job_code} < 15 then 'Assistant Vice President'
      when ${job_code} < 30 then 'Director'
      when ${job_code} < 80 then 'Manager'
      when ${job_code} < 150 then 'Principal Core Staff'
      when ${job_code} < 400 then 'Senior Core Staff'
      else 'Core Staff'
    end
    ;;
  }

  dimension: job_family {
    hidden: yes
    type: string
    sql: right(${TABLE}.zip, 1) ;;
  }

  dimension: job_code {
    type: number
    hidden: yes
    # sql: SAFE_CAST(SUBSTR(${TABLE}.zip, 2, 2) AS numeric) ;;
    # sql: safe_cast(right(${TABLE}.zip, 3) as numeric);;
    sql: ${TABLE}.job_code_rand;;
  }

  dimension: core_prod_fte  {
    group_label: "CORE, PI & One Time"
    label: "Core PROD (COGS) FTE"
    sql:  case when ${fte_rand} >= 0 and ${fte_rand} < 6 then 1 else 0 end  ;;
  }

  dimension: core_prod_cte {
    group_label: "CORE, PI & One Time"
    label: "Core PROD (COGS) CTE"
    sql:  case when ${fte_rand} >= 6 and ${fte_rand} < 5 then 1 else 0 end  ;;
  }

  dimension: core_dev_fte {
    group_label: "CORE, PI & One Time"
    sql:  case when ${fte_rand} >= 5 and ${fte_rand} < 8 then 1 else 0 end  ;;
    label: "Core DEV (PI) FTE"
  }

  dimension: core_dev_cte {
    group_label: "CORE, PI & One Time"
    sql:  case when ${fte_rand} >= 8 and ${fte_rand} < 9 then 1 else 0 end  ;;
    label: "Core DEV (PI) CTE"
  }

  dimension: ma_one_time_fte  {
    group_label: "CORE, PI & One Time"
    sql:  case when ${fte_rand} >= 9 and ${fte_rand} < 10 then 1 else 0 end  ;;
    label: "M&A One Time FTE"
  }

  dimension: ma_one_time_cte  {
    group_label: "CORE, PI & One Time"
    sql:  case when ${fte_rand} >= 10 and ${fte_rand} < 11 then 1 else 0 end  ;;
    label: "M&A One Time CTE"
  }

  dimension: fte_rand {
    hidden: yes
    type: number
    sql: ${TABLE}.fte_rand ;;
  }

  dimension: dev_vs_cogs {
    group_label: "CORE, PI & One Time"
    label: "Dev vs COGS"
    type: string
    sql:
    case
      when coalesce(${core_prod_cte},0) + coalesce(${core_prod_fte},0) > 0 then 'COGS'
      when coalesce(${core_dev_cte},0) + coalesce(${core_dev_fte},0) > 0 then 'PI'
      else 'One Time (PI)'
    end
    ;;
  }

  parameter: business_product_platform {
    label: "Business, Product & Platform Selector"
    type: unquoted
    allowed_value: {
      label: "Business Line"
      value: "business_line"
    }
    allowed_value: {
      label: "Product Line"
      value: "product_line"
    }
    allowed_value: {
      label: "Platform"
      value: "platform"
    }
  }

  dimension: business_product_platform_selection {
    label: "User Selection (Business, Product, Platform)"
    sql:
    {% if business_product_platform._parameter_value == 'business_line'%} ${business_line}
    {% elsif business_product_platform._parameter_value == 'product_line' %} ${product_line}
    {% elsif business_product_platform._parameter_value == 'platform'%} ${platform}
    {% else %} ${business_line}
    {% endif %}
    ;;
    drill_fields: [business_line, product_line, platform]
  }

  parameter: time_series_selector {
    label: "Time Series Selector"
    type: unquoted
    allowed_value: { label: "Date" value: "date" }
    allowed_value: { label: "Week" value: "week" }
    allowed_value: { label: "Month" value: "month" }
    allowed_value: { label: "Year" value: "year" }
  }

  dimension: selected_time_series {
    sql:
    {% if time_series_selector._parameter_value == 'date' %} ${reduction_date}
    {% elsif time_series_selector._parameter_value == 'week' %} ${reduction_week}
    {% elsif time_series_selector._parameter_value == 'month' %} ${reduction_month}
    {% elsif time_series_selector._parameter_value == 'quarter' %} ${reduction_quarter}
    {% else %} ${reduction_year}
    {% endif %}
    ;;
  }

  parameter: measure_selector {
    type: unquoted
    label: "Measure Selector"
    allowed_value: { label: "Total Headcount" value: "total_hc"}
    allowed_value: { label:"Total One Time" value:"total_one_time"}
    allowed_value: { label:"Total Core Prod (COGS)" value:"total_core_prod"}
    allowed_value: { label:"Total Core DEV (PI)" value:"total_core_dev"}
    allowed_value: { label:"Total Core" value:"total_core"}
    allowed_value: { label: "Total One Time + Total Core" value: "total_one_time_core"}
    default_value: "total_one_time_core"
  }

  measure: dynamic_measure {
    label_from_parameter: measure_selector
    type: number
    sql:
    {% if measure_selector._parameter_value == 'total_hc' %} ${count}
    {% elsif measure_selector._parameter_value == 'total_one_time' %} ${total_one_time}
    {% elsif measure_selector._parameter_value == 'total_core_prod' %} ${total_core_prod}
    {% elsif measure_selector._parameter_value == 'total_core_dev' %} ${total_core_dev}
    {% elsif measure_selector._parameter_value == 'total_core' %} ${total_core}
    {% elsif measure_selector._parameter_value == 'total_one_time_core' %} ${total_one_time_core}
    {% else %} ${total_one_time_core}
    {% endif %}
    ;;
  }


  measure: count {
    label: "Total Headcount"
    # hidden: yes
    type: count
    # drill_fields: [detail*]
    drill_fields: [employee_details*]
  }

  measure: total_one_time{
    label: "Total One Time FTE & CTE"
    type: sum
    sql: ${ma_one_time_cte} + ${ma_one_time_fte} ;;
    drill_fields: [employee_details*]
  }

  measure: total_core_prod {
    label: "Total Core PROD (COGS)"
    type: sum
    sql: ${core_prod_cte} + ${core_prod_fte} ;;
    drill_fields: [employee_details*]
  }

  measure: total_core_dev {
    label: "Total Core DEV (PI)"
    type: sum
    sql: ${core_dev_cte} + ${core_dev_fte} ;;
    drill_fields: [employee_details*]
  }

  measure: total_core {
    type: number
    sql: ${total_core_dev} + ${total_core_prod} ;;
    drill_fields: [employee_details*]

  }

  measure: total_one_time_core {
    label: "Total One Time + Total Core"
    type: number
    sql: ${total_one_time} + ${total_core} ;;
    link: {
      label: "{% if business_product_platform._parameter_value == 'business_line'%}{{business_product_platform_selection._value}} Summary {%endif%}"
      url: "{% if business_product_platform._parameter_value == 'business_line'%}/dashboards/285?{{'Business Line'| url_encode}}={{business_product_platform_selection._value}} {%endif%}"
    }
    drill_fields: [employee_details*]
  }

  measure: total_cost_centers {
    type: count_distinct
    sql: ${cost_center} ;;
  }

  set: employee_details {
    fields: [cost_center, full_name, worker_type, job_profile]
  }




# Total One Time FTE & CTE  Sum: M&A One Time FTE + M&A One Time CTE
# Total Core PROD (COGS)  Sum: Core PROD (COGS) FTE + Core PROD (COGS) CTE
# Total Core DEV (PI) Sum: Core DEV (PI) FTE + Core DEV (PI) CTE
# Total Core  Sum: Total Core PROD (COGS) + Total Core DEV (PI)
# Total One Time + Total Core Sum: Total Core + Total One Time FTE & CTE
  # ----- Sets of fields for drilling ------

}
