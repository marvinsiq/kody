<ui:composition xmlns="http://www.w3.org/1999/xhtml" xmlns:f="http://java.sun.com/jsf/core"
	xmlns:p="http://primefaces.org/ui" xmlns:h="http://java.sun.com/jsf/html"
	xmlns:ui="http://java.sun.com/jsf/facelets" template="/template/main.xhtml">

	<ui:define name="body">
		<h:form>
{% for field in page.fields %}
			<h:outputLabel value="#{messages['{{page.name}}.label.{{field.name}}']}" for="{{field.name}}" styleClass="text-input" />
			<h:outputText id="{{field.name}}" value="#{ {{page.controller.name | uncapitalize}}.{{field.name}}}" />
			<p:message for="{{field.name}}" />
{% endfor %}
{% for operation in page.controller.operations %}
			<h:commandButton value="#{messages['{{page.name}}.command.{{operation.name}}']}" action="#{ {{page.controller.name | uncapitalize}}.{{operation.name}} }" />{% endfor %}
		</h:form>
	</ui:define>
</ui:composition>		