/**
* FlashMessageSpec.cfc
*/
component extends="testbox.system.BaseSpec"{
	
	function run(){
		describe( "Basic flash message creation", function(){

			beforeEach(function() {
				flashStorage = getMockBox().createEmptyMock("tests.resources.empty")
							       .$(method = "put", callLogging = true)
							       .$(method = "get", returns = [])
							       .$(method = "exists", returns = false);

				flash = new models.FlashMessage(
					flashStorage = flashStorage,
					config = {
						flashKey = "elpete_flashmessage",
						containerTemplatePath = "",
						messageTemplatePath = ""
					}
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
				expect( flashStorage.$times(1, "get") ).toBeTrue();

				flashStorage.$(method = "get", returns = [ { message = "Test message one", type = "default" } ]);
				flash.message("Test message two");
				expect( flashStorage.$times(1, "get") ).toBeTrue();

				expect( flashStorage.$times(3, "put") ).toBeTrue();

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
				expect( flashStorage.$times(1, "get") ).toBeTrue();

				flashStorage.$(method = "get", returns = [ { message = "Test message", type = "error" } ]);
				flash.myCustomType("Test message again");
				expect( flashStorage.$times(1, "get") ).toBeTrue();

				expect( flashStorage.$times(3, "put") ).toBeTrue();

				expect( flashStorage.$callLog().put[3].value ).toBeArray().toHaveLength(2);
				expect(	flashStorage.$callLog().put[3].value[1] )
					.toBe({ message="Test message", type="error" });
				expect(	flashStorage.$callLog().put[3].value[2] )
					.toBe({ message="Test message again", type="myCustomType" });
			});

			
		});

		describe( "Render contents", function(){

			beforeEach(function() {
				flashStorage = getMockBox().createEmptyMock("tests.resources.empty")
							       .$(method = "put")
							       .$(method = "exists", returns = false);

				flash = new models.FlashMessage(
					flashStorage = flashStorage,
					config = {
						flashKey = "elpete_flashmessage",
						containerTemplatePath = "/views/_templates/FlashMessageContainer.cfm",
						messageTemplatePath = "/views/_templates/FlashMessage.cfm"
					}
				);
			});

			it( "can render out its contents", function(){
				flashStorage.$(method = "get", returns = [ { message = "Test message", type = "default" } ]);
				var htmlString = flash.render();
				expect(	Trim(REReplace(htmlString, "\s{2,}", " ", "all" ))).toBe('<div class="flash-messages"> <div class="alert alert-default"> <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button> Test message </div> </div>');
			});
		
		});

		describe( "Test Helpers", function() {
		
			beforeEach(function() {
				flashStorage = getMockBox().createEmptyMock("tests.resources.empty")
							       .$(method = "put")
							       .$(method = "get", returns = [])
							       .$(method = "exists", returns = false);

				var config = {
						flashKey = "elpete_flashmessage",
						containerTemplatePath = "",
						messageTemplatePath = ""
				};

				flash = new models.FlashMessage(
					flashStorage = flashStorage,
					config = config
				);

				testUtils = new models.TestUtils(
					flashStorage = flashStorage,
					config = config
				);
			});

			it( "can return all of the messages currently in the queue", function(){
				flashStorage.$(method = "get", returns = [
					{ message = "Test message", type = "default" },
					{ message = "Test error message", type = "error" }
				]);


				expect(testUtils.getMessages()).toBeArray().toHaveLength(2).toBe([
					{ message = "Test message", type = "default" },
					{ message = "Test error message", type = "error" }
				]);
			});

			it( "can verify a message exists", function() {
				flashStorage.$(method = "get", returns = [ { message = "Test message", type = "default" } ] );

				expect(testUtils.messageExists("Test message")).toBeTrue();
				expect(testUtils.messageExists("Another message")).toBeFalse();
			});

			it( "can verify a message exists with a specfic type", function(){
				flashStorage.$(method = "get", returns = [ { message = "Test error message", type = "error" } ] );

				expect(testUtils.messageExists("Test error message", "error")).toBeTrue();
				expect(testUtils.messageExists("Test error message", "warning")).toBeFalse();
			});
		
		});

	}
	
}
