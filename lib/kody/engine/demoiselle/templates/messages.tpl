{% for class in classes %}
{{class.lower_camel_case_name}}.label = {{class.name}}
{{class.lower_camel_case_name}}.list.table.title = Lista de {{class.name}}s
{{class.lower_camel_case_name}}.label.id = ID
{% for attribute in class.attributes %}
{{class.lower_camel_case_name}}.label.{{attribute.name}} = {{attribute.name | capitalize_first}}{% endfor %}
{% endfor %}