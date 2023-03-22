view: org {
derived_table: {
  sql:
    select *
    , ROUND(RAND()*10) as fte_rand
    , ROUND(RAND()*1000,0) as job_code_rand
    from `looker-private-demo.thelook.users`
    where city is not null and state is not null and country = 'USA'
    ;;
  #   datagroup_trigger: core_default_datagroup
  }
  # sql_table_name: `looker-private-demo.thelook.users`;;
  # drill_fields: [id]

  dimension: id {
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
    type: string
    hidden: yes
    sql: ${TABLE}.state ;;
  }


  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: INITCAP(${TABLE}.first_name) ;;
  }

  dimension: gender {
    hidden: yes
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: INITCAP(${TABLE}.last_name) ;;
  }
  dimension: full_name {
    type: string
    sql: ${last_name} || ', ' || ${first_name} ;;
  }

  dimension: worker_type {
    type: string
    sql:
    case when ${core_dev_fte} = 1 OR ${core_prod_fte} = 1 or ${ma_one_time_fte} = 1 then 'Employee' else 'Contingent Worker' end
    ;;
  }

  dimension: contingent_worker_supplier {
    type: string
    sql:
    case when ${core_dev_fte} = 1 OR ${core_prod_fte} = 1 or ${ma_one_time_fte} = 1 then '' else 'Nationwide Contract Workers' end
    ;;
  }

  dimension: company {
    type: number
    sql: right(cast(abs(farm_fingerprint(concat(${country}, ${contingent_worker_supplier}))) as string),3) ;;
  }

  dimension: division {
    type: number
    sql: right(cast(abs(farm_fingerprint(${state})) as string),1) ;;
  }

  dimension: cost_center {
    type: number
    sql: right(cast(abs(farm_fingerprint(${city})) as string),5) ;;
  }

  dimension_group: reduction {
    type: time
    timeframes: [raw, date, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  dimension: business_line {
    type: string
    sql: ${country} || ' LOB' ;;
  }

  dimension: product_line {
    type: string
    sql: 'State of ' || ${state} || ' Product Line' ;;
  }

  dimension: platform {
    type: string
    sql: 'City of ' || ${city} || ' Platform' ;;
  }

  dimension: job_profile {
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
    label: "Core PROD (COGS) FTE"
    sql:  case when ${fte_rand} >= 0 and ${fte_rand} < 5 then 1 else 0 end  ;;
  }

  dimension: core_prod_cte {
    label: "Core PROD (COGS) CTE"
    sql:  case when ${fte_rand} >= 5 and ${fte_rand} < 4 then 1 else 0 end  ;;
  }

  dimension: core_dev_fte {
    sql:  case when ${fte_rand} >= 4 and ${fte_rand} < 7 then 1 else 0 end  ;;
    label: "Core DEV (PI) FTE"
  }

  dimension: core_dev_cte {
    sql:  case when ${fte_rand} >= 7 and ${fte_rand} < 8 then 1 else 0 end  ;;
    label: "Core DEV (PI) CTE"
  }

  dimension: ma_one_time_fte  {
    sql:  case when ${fte_rand} >= 8 and ${fte_rand} < 9 then 1 else 0 end  ;;
    label: "M&A One Time FTE"
  }

  dimension: ma_one_time_cte  {
    sql:  case when ${fte_rand} >= 9 and ${fte_rand} < 10 then 1 else 0 end  ;;
    label: "M&A One Time CTE"
  }

  dimension: fte_rand {
    hidden: yes
    type: number
    sql: ${TABLE}.fte_rand ;;
  }


  measure: count {
    type: count
    # drill_fields: [detail*]
  }

  measure: total_one_time{
    label: "Total One Time FTE & CTE"
    type: sum
    sql: ${ma_one_time_cte} + ${ma_one_time_fte} ;;
  }

  measure: total_core_prod {
    label: "Total Core PROD (COGS)"
    type: sum
    sql: ${core_prod_cte} + ${core_prod_fte} ;;
  }

  measure: total_core_dev {
    label: "Total Core DEV (PI)"
    type: sum
    sql: ${core_dev_cte} + ${core_dev_fte} ;;
  }

  measure: total_core {
    type: number
    sql: ${total_core_dev} + ${total_core_prod} ;;

  }

  measure: total_one_time_core {
    label: " Total One Time + Total Core"
    type: number
    sql: ${total_one_time} + ${total_core} ;;
  }




# Total One Time FTE & CTE  Sum: M&A One Time FTE + M&A One Time CTE
# Total Core PROD (COGS)  Sum: Core PROD (COGS) FTE + Core PROD (COGS) CTE
# Total Core DEV (PI) Sum: Core DEV (PI) FTE + Core DEV (PI) CTE
# Total Core  Sum: Total Core PROD (COGS) + Total Core DEV (PI)
# Total One Time + Total Core Sum: Total Core + Total One Time FTE & CTE
  # ----- Sets of fields for drilling ------

}
