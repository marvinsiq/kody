<ui:composition xmlns="http://www.w3.org/1999/xhtml" xmlns:f="http://java.sun.com/jsf/core"
	xmlns:p="http://primefaces.org/ui" xmlns:h="http://java.sun.com/jsf/html"
	xmlns:ui="http://java.sun.com/jsf/facelets" template="/template/main.xhtml">

	<ui:define name="body">
		<h:form prependId="false">
			<p:toolbar>
				<p:toolbarGroup align="left">
					<p:commandButton value="#{messages['button.save']}" action="#{ {{class.lower_camel_case_name}}EditMB.insert}"
						rendered="#{! {{class.lower_camel_case_name}}EditMB.updateMode}" ajax="false" />
					<p:commandButton value="#{messages['button.save']}" action="#{ {{class.lower_camel_case_name}}EditMB.update}"
						rendered="#{ {{class.lower_camel_case_name}}EditMB.updateMode}" ajax="false" />
					<p:commandButton value="#{messages['button.delete']}" onclick="confirmation.show()"
						rendered="#{ {{class.lower_camel_case_name}}EditMB.updateMode}" type="button" immediate="true" ajax="false" />
					<p:confirmDialog message="#{messages['label.confirm.delete']}" showEffect="bounce" hideEffect="explode"
						header="#{messages['label.dialog.delete']}" severity="alert" widgetVar="confirmation">
						<h:commandButton value="#{messages['button.dialog.yes']}" action="#{ {{class.lower_camel_case_name}}EditMB.delete}" immediate="true"
							ajax="false" />
						<h:commandButton value="#{messages['button.dialog.no']}" onclick="confirmation.hide()" type="button" />
					</p:confirmDialog>
				</p:toolbarGroup>
			</p:toolbar>

			<br />

			<p:fieldset legend="#{messages['{{class.lower_camel_case_name}}.label']}" toggleable="true" toggleSpeed="500">
				<h:panelGrid id="fields" columns="3">
					<h:outputLabel value="#{messages['{{class.lower_camel_case_name}}.label.id']}: " for="id" styleClass="text-input" />
					<h:outputText id="id" value="#{ {{class.lower_camel_case_name}}EditMB.bean.id}" />
					<p:message for="id" />

					{% for attribute in class.attributes %}
					<h:outputLabel value="#{messages['{{class.lower_camel_case_name}}.label.{{attribute.name}}']}: " for="{{attribute.name}}" styleClass="text-input" />
					<h:inputText id="{{attribute.name}}" value="#{ {{class.lower_camel_case_name}}EditMB.bean.{{attribute.name}}}"
						title="#{messages['{{class.lower_camel_case_name}}.label.{{attribute.name}}']}" />
					<p:message for="{{attribute.name}}" />
					{% endfor %}
				</h:panelGrid>
			</p:fieldset>
		</h:form>
	</ui:define>
</ui:composition>