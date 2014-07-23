<ui:composition xmlns="http://www.w3.org/1999/xhtml" xmlns:f="http://java.sun.com/jsf/core"
	xmlns:p="http://primefaces.org/ui" xmlns:h="http://java.sun.com/jsf/html"
	xmlns:ui="http://java.sun.com/jsf/facelets" template="/template/main.xhtml">

	<ui:define name="body">
		<h:form>
{% for field in page.fields %}{% if field.is_table == 'true' %}
			<p:dataTable id="list" var="bean" value="#{ {{page.controller.name | uncapitalize}}.{{field.name}} }">
				<f:facet name="header">#{messages['{{page.name | property_key}}.label.{{field.name | property_key}}']}</f:facet>
				{% for column in field.columns %}
				<p:column>
					<f:facet name="header">#{messages['{{page.name | property_key}}.{{field.name | property_key}}.{{column | property_key}}']}</f:facet>
					<h:outputText value="#{bean.{{column}}}" />
				</p:column>{% endfor %}

			</p:dataTable>
			{% else %}
			<h:outputLabel value="#{messages['{{page.name | property_key}}.label.{{field.name | property_key}}']}" for="{{field.name}}" styleClass="text-input" />
			<h:outputText id="{{field.name}}" value="#{ {{page.controller.name | uncapitalize}}.{{field.name}}}" />
			<p:message for="{{field.name}}" />			
			{% endif %}{% endfor %}
{% for operation in page.controller.operations %}
			<h:commandButton value="#{messages['{{page.name | property_key}}.action.{{operation.name | property_key}}']}" action="#{ {{page.controller.name | uncapitalize}}.{{operation.name}} }" />{% endfor %}
		</h:form>
	</ui:define>
</ui:composition>		