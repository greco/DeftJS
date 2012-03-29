###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.mvc.ViewController
###
describe( 'Deft.mvc.ViewController', ->
	
	describe( 'Configuration', ->
		
		it( 'should be configurable with a reference to the view it controls', ->
			view = Ext.create( 'Ext.container.Container' )
		
			viewController = Ext.create( 'Deft.mvc.ViewController', 
				view: view
			)
		
			expect( viewController.getView() ).toBe( view )
		)
		
		it( 'should throw an error if created without being configured for a view', ->
			expect( ->
				Ext.create( 'Deft.mvc.ViewController' )
			).toThrow( new Error( 'Error constructing ViewController: the configured \'view\' is not an Ext.Component.' ) )
		)
		
		it( 'should throw an error if created and configured with a non-Ext.Component as the view', ->
			expect( ->
				Ext.create( 'Deft.mvc.ViewController',
					view: new Object()
				)
			).toThrow( new Error( "Error constructing ViewController: the configured 'view' is not an Ext.Component." ) )
		)
	)
	
	describe( 'Creation of getters and event listeners using the \'control\' property', ->
		
		beforeEach( ->
			Ext.define( 'ExampleComponent',
				extend: 'Ext.Component'
				alias: 'widget.example'
				
				initComponent: ( config ) ->
					@addEvents(
						exampleevent: true
					)
					return @callParent( arguments )
					
				fireExampleEvent: ( value ) ->
					@fireEvent( 'exampleevent', value )
					return
			)
			
			Ext.define( 'ExampleView',
				extend: 'Ext.container.Container'
				
				renderTo: 'componentTestArea'
				items: [
					{
						xtype: 'example'
						itemId: 'example'
					}
				]
				
				initComponent: ( config ) ->
					@addEvents(
						exampleevent: true
					)
					
					return @callParent( arguments )
					
				fireExampleEvent: ( value ) ->
					@fireEvent( 'exampleevent', value )
					return
			)
			
			Ext.DomHelper.append( Ext.getBody(), '<div id="componentTestArea" style="visibility: hidden"></div>' )
		)
		
		afterEach( ->
			Ext.get( 'componentTestArea' ).remove()
		)
		
		it( 'should attach view controller scoped event listeners to events for the view', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					view:
						exampleevent: 'onExampleViewExampleEvent'
				
				onExampleViewExampleEvent: ( event ) ->
					return
			)
			
			spyOn( ExampleViewController.prototype, 'onExampleViewExampleEvent' ).andCallFake( ( value ) ->
				expect( @ ).toBe( viewController )
				expect( value ).toBe( 'expected value' )
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			expect( viewController.getView() ).toBe( view )
			expect( view.hasListener( 'exampleevent' ) ).toBe( true )
			
			view.fireExampleEvent( 'expected value' )
			
			expect( viewController.onExampleViewExampleEvent ).toHaveBeenCalled()
			expect( viewController.onExampleViewExampleEvent.callCount ).toBe( 1 )
		)
		
		it( 'should throw an error when attaching a non-existing view controller scoped event listener for the view', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					view:
						exampleevent: 'onExampleViewExampleEvent'
			)
			
			view = Ext.create( 'ExampleView' )
			
			expect( ->
				viewController = Ext.create( 'ExampleViewController', 
					view: view
				)
			).toThrow( 'Error adding \'exampleevent\' listener: the specified handler \'onExampleViewExampleEvent\' is not a Function or does not exist.' )
		)
		
		it( 'should create a view controller getter for a view component referenced implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: true
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
			expect( viewController.getExample() ).toBe( component )
		)
		
		it( 'should throw an error when referencing a non-existent component implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					doesntexist: true
			)
			
			view = Ext.create( 'ExampleView' )
			
			expect( ->
				viewController = Ext.create( 'ExampleViewController', 
					view: view
				)
			).toThrow( 'Error locating component: no component found with an itemId of \'doesntexist\'.' )
		)
		
		it( 'should create a view controller getter for a view component referenced implicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: "#example"
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
			expect( viewController.getExample() ).toBe( component )
		)
		
		it( 'should throw an error when referencing a non-existent component implicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: '#doesntexist'
			)
			
			view = Ext.create( 'ExampleView' )
			
			expect( ->
				viewController = Ext.create( 'ExampleViewController', 
					view: view
				)
			).toThrow( 'Error locating component: no component found matching \'#doesntexist\'.' )
		)
		
		it( 'should create a view controller getter for a view component referenced explicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: 
						selector: "#example"
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
			expect( viewController.getExample() ).toBe( component )
		)
		
		it( 'should throw an error when referencing a non-existent component explicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: 
						selector: '#doesntexist'
			)
			
			view = Ext.create( 'ExampleView' )
			
			expect( ->
				viewController = Ext.create( 'ExampleViewController', 
					view: view
				)
			).toThrow( 'Error locating component: no component found matching \'#doesntexist\'.' )
		)
		
		it( 'should create a view controller getter and attach view controller scoped event listeners to events for a view component referenced implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						exampleevent: 'onExampleComponentExampleEvent'
				
				onExampleComponentExampleEvent: ->
					return
			)
			
			spyOn( ExampleViewController.prototype, 'onExampleComponentExampleEvent' ).andCallFake( ( value ) ->
				expect( @ ).toBe( viewController )
				expect( value ).toBe( 'expected value' )
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
			expect( viewController.getExample() ).toBe( component )
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			
			component.fireExampleEvent( 'expected value' )
			
			expect( viewController.onExampleComponentExampleEvent ).toHaveBeenCalled()
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 1 )
		)
		
		it( 'should throw an error when attaching a non-existing view controller scoped event listener for a view component referenced implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						exampleevent: 'onExampleComponentExampleEvent'
			)
			
			view = Ext.create( 'ExampleView' )
			
			expect( ->
				viewController = Ext.create( 'ExampleViewController', 
					view: view
				)
			).toThrow( 'Error adding \'exampleevent\' listener: the specified handler \'onExampleComponentExampleEvent\' is not a Function or does not exist.' )
		)
		
		it( 'should create a view controller getter and attach view controller scoped event listeners to events for a view component referenced by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						selector: '#example'
						listeners:
							exampleevent: 'onExampleComponentExampleEvent'
				
				onExampleComponentExampleEvent: ->
					return
			)
			
			spyOn( ExampleViewController.prototype, 'onExampleComponentExampleEvent' ).andCallFake( ( value ) ->
				expect( @ ).toBe( viewController )
				expect( value ).toBe( 'expected value' )
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
			expect( viewController.getExample() ).toBe( component )
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			
			component.fireExampleEvent( 'expected value' )
			
			expect( viewController.onExampleComponentExampleEvent ).toHaveBeenCalled()
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 1 )
		)
		
		it( 'should throw an error when attaching a non-existing view controller scoped event listener for a view component referenced implicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						selector: '#example'
						listeners:
							exampleevent: 'onExampleComponentExampleEvent'
			)
			
			view = Ext.create( 'ExampleView' )
			
			expect( ->
				viewController = Ext.create( 'ExampleViewController', 
					view: view
				)
			).toThrow( 'Error adding \'exampleevent\' listener: the specified handler \'onExampleComponentExampleEvent\' is not a Function or does not exist.' )
		)
	)
)