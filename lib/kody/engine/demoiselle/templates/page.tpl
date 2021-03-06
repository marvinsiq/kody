<ui:composition xmlns="http://www.w3.org/1999/xhtml" xmlns:f="http://java.sun.com/jsf/core"
	xmlns:p="http://primefaces.org/ui" xmlns:h="http://java.sun.com/jsf/html"
	xmlns:ui="http://java.sun.com/jsf/facelets" template="/template/main.xhtml">

	<ui:define name="body">
		<h:form>
			<h1>#{messages['{{page.property_key}}']}</h1>
			<h:panelGrid id="fields" columns="3">
{% for field in page.fields %}{% if field.is_table != 'true' %}
			<p:outputLabel value="#{messages['{{field.property_key}}']}" for="{{field.name}}" styleClass="text-input" />
			<p:inputText id="{{field.name}}" value="#{ {{page.controller.name | uncapitalize}}.{{field.name}}}" />
			<p:message for="{{field.name}}" />			
			{% endif %}{% endfor %}</h:panelGrid>
{% for field in page.fields %}{% if field.is_table == 'true' %}
			<p:dataTable id="list" var="bean" value="#{ {{page.controller.name | uncapitalize}}.{{field.name}} }">
				<f:facet name="header">#{messages['{{field.property_key}}']}</f:facet>
				{% for column in field.columns %}
				<p:column>
					<f:facet name="header">#{messages['{{column.property_key}}']}</f:facet>
					<h:outputText value="#{bean.{{column.name}}}" />
				</p:column>{% endfor %}
{% for action in field.actions %}
				<p:column>
					<p:commandButton value="#{messages['{{field.property_key}}.{{action.property_key}}']}" action="#{ {{page.controller.name | uncapitalize}}.{{action.name}} }" />
				</p:column>{% endfor %}
			</p:dataTable>{% endif %}{% endfor %}			
{% for action in page.actions %}
			<p:commandButton value="#{messages['{{page.property_key}}.{{action.property_key}}']}" action="#{ {{page.controller.name | uncapitalize}}.{{action.name}} }" />{% endfor %}		
		</h:form>
	</ui:define>
</ui:composition>		