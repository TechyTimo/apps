checkUserSigned = (context, redirect) ->
	if !Meteor.userId()
		FlowRouter.go '/steedos/sign-in';

FlowRouter.notFound = 
	action: ()->
		if !Meteor.userId()
			BlazeLayout.render 'loginLayout',
				main: "not-found"
		else
			BlazeLayout.render 'masterLayout',
				main: "not-found"

FlowRouter.triggers.enter [
	()-> Session.set("router-path", FlowRouter.current().path)
	()-> 
		Tracker.autorun ->
			if Session.get "is_tap_loaded"
				appName = Steedos.getAppName()
				switch appName
					when 'workflow'
						title = "Steedos Workflow"
					when 'cms'
						title = "Steedos CMS"
					when 'emailjs'
						title = "Steedos Mail"
					when 'contacts'
						title = "Steedos Contacts"
					when 'portal'
						title = "Steedos Portal"
					when 'admin'
						title = "Steedos Admin"
					else
						title = "Steedos"
				if title
					Session.set "document_title", t(title)
]

FlowRouter.route '/', 
	action: (params, queryParams)->
		if (!Meteor.userId())
			FlowRouter.go "/steedos/sign-in";
		else
			# 登录最近关闭的URL
			lastUrl = localStorage.getItem('Steedos.lastURL:' + Meteor.userId())
			# 这时不能用lastUrl.startsWith，因为那样无法判断后面是否加了其他字符
			if lastUrl
				if /^\/?workflow\b/.test(lastUrl)
					FlowRouter.go "/workflow"
				else if /^\/?cms\b/.test(lastUrl)
					FlowRouter.go "/cms"
				else if /^\/?emailjs\b/.test(lastUrl)
					FlowRouter.go "/emailjs"
				else if /^\/?contacts\b/.test(lastUrl)
					FlowRouter.go "/contacts"
				else if /^\/?portal\b/.test(lastUrl)
					FlowRouter.go "/portal"
				else if /^\/?admin\b/.test(lastUrl)
					FlowRouter.go "/admin"
			else
				firstApp = Steedos.getSpaceFirstApp()
				if !firstApp
					# 这里等待db.apps加载完成后，找到并进入第一个spaceApps的路由，在apps加载完成前显示loading界面
					BlazeLayout.render 'steedosLoading'
					$("body").addClass('loading')
				else
					Steedos.openApp firstApp._id


# FlowRouter.route '/steedos', 
#   action: (params, queryParams)->
#       if !Meteor.userId()
#           FlowRouter.go "/steedos/sign-in";
#           return true
#       else
#           FlowRouter.go "/steedos/springboard";


FlowRouter.route '/steedos/logout', 
	action: (params, queryParams)->
		#AccountsTemplates.logout();
		Meteor.logout ()->
			Setup.logout();
			Session.set("spaceId", null);
			FlowRouter.go("/");


FlowRouter.route '/admin/profile', 
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		if Meteor.userId()
			BlazeLayout.render 'adminLayout',
				main: "profile"


FlowRouter.route '/steedos/springboard', 
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		if !Meteor.userId()
			FlowRouter.go "/steedos/sign-in";
			return true

		Steedos.setAppId(null);

		NavigationController.reset();
		
		BlazeLayout.render 'masterLayout',
			main: "springboard"


FlowRouter.route '/admin/spaces', 
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		if !Meteor.userId()
			FlowRouter.go "/steedos/sign-in";
			return true

		BlazeLayout.render 'masterLayout',
			main: "space_select"


FlowRouter.route '/admin/space/info', 
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		if !Meteor.userId()
			FlowRouter.go "/steedos/sign-in";
			return true

		BlazeLayout.render 'adminLayout',
			main: "space_info"

FlowRouter.route '/admin/customize_apps',
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		spaceId = Steedos.getSpaceId()
		if spaceId
			space = db.spaces.findOne(spaceId)
			if !space?.is_paid
				swal(t("steedos_customize_apps"), t("steedos_only_paid"), "error")
			else
				FlowRouter.go("/admin/view/apps")

FlowRouter.route '/designer', 
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		if !Meteor.userId()
			FlowRouter.go "/steedos/sign-in";
			return true
		
		url = Meteor.absoluteUrl("applications/designer/current/" + Steedos.getLocale() + "/"+ "?spaceId=" + Steedos.getSpaceId());
		
		Steedos.openWindow(url);
		
		FlowRouter.go "/designer/opened"

FlowRouter.route '/designer/opened', 
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		if !Meteor.userId()
			FlowRouter.go "/steedos/sign-in";
			return true

FlowRouter.route '/steedos/sso', 
	action: (params, queryParams)->
		returnurl = queryParams.returnurl

		Steedos.loginWithCookie ()->
			Meteor._debug("cookie login success");
			FlowRouter.go(returnurl);

FlowRouter.route '/steedos/about',
	action: (params, queryParams)->
		BlazeLayout.render 'adminLayout',
			main: "steedosAbout"


