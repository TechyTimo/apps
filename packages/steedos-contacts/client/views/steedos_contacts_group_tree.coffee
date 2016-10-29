Template.steedos_contacts_group_tree.helpers 
  is_disabled: ->
    return !Session.get("contacts_groupId") || Session.get("contacts_groupId")=='root'


Template.steedos_contacts_group_tree.onRendered ->
  $(document.body).addClass('loading')
  console.log "loaded_organizations ok..."

  this.autorun ()->
    if Steedos.subsSpace.ready("address_groups")
      $("#steedos_contacts_group_tree").on('changed.jstree', (e, data) ->
            if data.selected.length
              # console.log 'The selected node is: ' + data.instance.get_node(data.selected[0]).text
              Session.set("contact_showBooks", true)
              Session.set("contacts_groupId", data.selected[0])
            return
          ).jstree
                core: 
                    themes: { "stripes" : true, "variant" : "large" },
                    data:  (node, cb) ->
                      Session.set("contacts_groupId", node.id)
                      cb(ContactsManager.getBookNode(node))
                          
                plugins: ["wholerow", "search"]

  $(document.body).removeClass('loading');


Template.steedos_contacts_group_tree.events
  'click #search-btn': (event, template) ->
    console.log 'click search-btn'
    $('#steedos_contacts_group_tree').jstree(true).search($("#search-key").val())

  'click #steedos_contacts_group_tree_add_btn': (event, template) ->
    AdminDashboard.modalNew 'address_groups', {}, ()->
      $.jstree.reference('#steedos_contacts_group_tree').refresh()

  'click #steedos_contacts_group_tree_edit_btn': (event, template) ->
    AdminDashboard.modalEdit 'address_groups', Session.get('contacts_groupId'), ()->
      $.jstree.reference('#steedos_contacts_group_tree').refresh()

  'click #steedos_contacts_group_tree_remove_btn': (event, template) ->
    AdminDashboard.modalDelete 'address_groups', Session.get('contacts_groupId'), ()->
      $.jstree.reference('#steedos_contacts_group_tree').refresh()