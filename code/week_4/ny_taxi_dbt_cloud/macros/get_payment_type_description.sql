{#
    This macro returns the description of the payment_type.
#}

{# Define the macro name and arguments #}
{% macro get_payment_type_description(payment_type) -%}

    {# The SQL code that will be injected during compilation. #}
    case cast( {{ payment_type }} as integer )
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
        else 'EMPTY'
    end

{%- endmacro %}