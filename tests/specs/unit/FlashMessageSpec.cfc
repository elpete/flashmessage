/**
* FlashMessageSpec.cfc
*/
component extends="testbox.system.BaseSpec"{
	
	function run(){
		describe( "Basic flash message creation", function(){

			beforeEach(function() {
				flashStorage = getMockBox().createEmptyMock("tests.resources.empty")
							       .$(method = "put", callLogging = true)
							       .$(method = "get", returns = []);

				flash = new models.FlashMessage(
					containerTemplatePath = "",
					messageTemplatePath = "",
					flashStorage = flashStorage
				);
			});

			it( "can be initialized", function() {
				expect(	flashStorage.$times(1, "put") ).toBeTrue();
			});

			it( "initializes the flash messages to an empty array", function() {
				expect(	flashStorage.$callLog().put[1].value ).toBeArray().toBeEmpty();
			});

			it( "can add a basic message", function() {
				flash.message("Test message");

				expect( flashStorage.$times(2, "put") ).toBeTrue();
				expect( flashStorage.$times(1, "get") ).toBeTrue();

				expect( flashStorage.$callLog().put[2].value ).toBeArray().toHaveLength(1);

				expect(	flashStorage.$callLog().put[2].value[1] )
					.toBe({ message="Test message", type="default" });
			});

			it( "can handle multiple messages", function() {
				flash.message("Test message one");
				flash.message("Test message two");

				expect( flashStorage.$times(3, "put") ).toBeTrue();
				expect( flashStorage.$times(2, "get") ).toBeTrue();

				expect( flashStorage.$callLog().put[3].value ).toBeArray().toHaveLength(2);

				expect(	flashStorage.$callLog().put[3].value[1] )
					.toBe({ message="Test message one", type="default" });
				expect( flashStorage.$callLog().put[3].value[2] )
					.toBe({ message="Test message two", type="default" });
			});

			it( "can specify a custom message type", function() {
				flash.message("Test message", "warning");

				expect( flashStorage.$times(2, "put") ).toBeTrue();
				expect( flashStorage.$times(1, "get") ).toBeTrue();

				expect( flashStorage.$callLog().put[2].value ).toBeArray().toHaveLength(1);

				expect(	flashStorage.$callLog().put[2].value[1] )
					.toBe({ message="Test message", type="warning" });
			});

			it( "can use shortcut methods for custom method types", function() {
				flash.error("Test message");
				flash.myCustomType("Test message again");

				expect( flashStorage.$times(3, "put") ).toBeTrue();
				expect( flashStorage.$times(2, "get") ).toBeTrue();

				expect( flashStorage.$callLog().put[2].value ).toBeArray().toHaveLength(2);
				expect(	flashStorage.$callLog().put[2].value[1] )
					.toBe({ message="Test message", type="error" });

				expect( flashStorage.$callLog().put[3].value ).toBeArray().toHaveLength(2);
				expect(	flashStorage.$callLog().put[3].value[2] )
					.toBe({ message="Test message again", type="myCustomType" });
			});

			
		});

		describe( "Render contents", function(){

			beforeEach(function() {
				flashStorage = getMockBox().createEmptyMock("tests.resources.empty")
							       .$(method = "put").$(method = "get", returns = []);

				flash = new models.FlashMessage(
					containerTemplatePath = "/views/_templates/FlashMessageContainer.cfm",
					messageTemplatePath = "/views/_templates/FlashMessage.cfm",
					flashStorage = flashStorage
				);
			});

			it( "can render out its contents", function(){
				flash.message("Test message");
				var htmlString = flash.render();
				// REReplace(htmlString, '> +<', '> <', 'all')
				expect(	Trim(REReplace(htmlString, "\s{2,}", " ", "all" ))).toBe('<div class="flash-messages"> <div class="alert alert-default"> <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button> Test message </div> </div>');
			});
		
		});

	}
	
}
