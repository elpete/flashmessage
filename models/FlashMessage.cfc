component name="FlashMessage" singleton {

    /**
     * @flashStorage.inject coldbox:flash
     * @config.inject coldbox:setting:flashmessage
     */
    public FlashMessage function init(any flashStorage, any config) {
        instance.flashKey = 'flashmessage';

        singleton.flashStorage = arguments.flashStorage;
        instance.containerTemplatePath = arguments.config.containerTemplatePath;
        instance.messageTemplatePath = arguments.config.messageTemplatePath;

        // Initialize our flash messages to an empty array if it hasn't ever been created
        if (! singleton.flashStorage.exists(instance.flashKey)) {
            setMessages([]);
        }

        return this;
    }


    public void function message(required string text, string type = "default") {
        appendMessage({ message: arguments.text, type = arguments.type });
    }

    public any function onMissingMethod(required string methodName, required struct methodArgs) {
        message(methodArgs[1], methodName);
    }

    public any function render() {
        var flashMessages = singleton.flashStorage.get(instance.flashKey, []);
        var flashMessageTemplatePath = instance.messageTemplatePath;
        savecontent variable="messagesHTML" {
            include "#instance.containerTemplatePath#";
        }

        setMessages([]);

        return messagesHTML;
    }


    private void function setMessages(required array messages) {
        singleton.flashStorage.put(
            name  = instance.flashKey,
            value = arguments.messages
        );
    }

    private void function appendMessage(required struct message) {
        var currentMessages = singleton.flashStorage.get(instance.flashKey);
        ArrayAppend(currentMessages, arguments.message);
        setMessages(currentMessages);
    }

}