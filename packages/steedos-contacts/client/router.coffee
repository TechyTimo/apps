checkUserSigned = (context, redirect) ->
	if !Meteor.userId()
		FlowRouter.go '/steedos/sign-in';

contactsRoutes = FlowRouter.group
	prefix: '/contacts',
	name: 'contactsRoutes',
	triggersEnter: [ checkUserSigned ],

contactsRoutes.route '/', 
	action: (params, queryParams)->
		BlazeLayout.render 'contactsLayout',
			main: "org_main"

contactsRoutes.route '/orgs', 
	action: (params, queryParams)->
		Session.set('contact_showBooks', false)
		BlazeLayout.render 'contactsLayout',
			main: "org_main"

contactsRoutes.route '/books', 
	action: (params, queryParams)->
		Session.set('contact_showBooks', true)
		BlazeLayout.render 'contactsLayout',
			main: "book_main"
