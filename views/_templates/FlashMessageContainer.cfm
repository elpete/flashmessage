<cfoutput>
    <div class="flash-messages">
        <cfloop array="#flashMessages#" index="flashMessage">
            <cfinclude template="#flashMessageTemplatePath#" runOnce="false" />
        </cfloop>
    </div>
</cfoutput>