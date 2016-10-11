Template.opinion_modal.helpers({
    opinions: function() {
        var opinions = [];
        var o = db.steedos_keyvalues.findOne({
            user: Meteor.userId(),
            key: 'flow_opinions',
            'value.workflow': {
                $exists: true
            }
        });
        if (o) {
            opinions = o.value.workflow;
        }
        return opinions;
    },

    flow_comment: function() {
        return Session.get('flow_comment');
    },

    active: function(opinion) {
        return opinion == Session.get('flow_selected_opinion');
    },

    not_selected_opinion: function() {
        return !Session.get('flow_selected_opinion');
    }
})

Template.opinion_modal.events({

    'click .list-group-item': function(event, template) {
        Session.set('flow_selected_opinion', event.target.dataset.opinion);
    },

    'dblclick .list-group-item': function(event, template) {
        var so = event.target.dataset.opinion,
            c = Session.get('flow_comment'),
            new_c;
        new_c = c ? (c + so) : so;

        Session.set('flow_selected_opinion', so);
        Session.set('flow_comment', new_c)
    },

    'click #instance_flow_opinions_to': function(event, template) {
        var so = Session.get('flow_selected_opinion');
        if (so) {
            var c = Session.get('flow_comment'),
                new_c;
            new_c = c ? (c + so) : so;
            Session.set('flow_comment', new_c)
        }
    },

    'click #instance_flow_opinions_plus': function(event, template) {
        swal({
            title: "请输入批示",
            type: "input",
            showCancelButton: true,
            closeOnConfirm: false,
            inputPlaceholder: "请输入批示",
            confirmButtonText: t('OK'),
            cancelButtonText: t('Cancel')
        }, function(inputValue) {
            if (inputValue === false) return false;
            if (inputValue === "") {
                swal.showInputError("You need to write something!");
                return false
            }

            var opinions = [];
            var o = db.steedos_keyvalues.findOne({
                user: Meteor.userId(),
                key: 'flow_opinions',
                'value.workflow': {
                    $exists: true
                }
            });

            if (o) {
                opinions = o.value.workflow;
                opinions.unshift(inputValue);
            } else {
                opinions = [inputValue];
            }

            Meteor.call('setKeyValue', 'flow_opinions', {
                workflow: opinions
            }, function(error, result) {
                if (error) {
                    swal({
                        title: "Error!",
                        type: "error",
                        text: error,
                        closeOnConfirm: true,
                        confirmButtonText: t('OK')
                    });
                }

                if (result == true) {
                    swal({
                        title: "Nice!",
                        type: "success",
                        closeOnConfirm: true,
                        confirmButtonText: t('OK')
                    });
                }

            });


        });
    },

    'click #instance_flow_opinions_minus': function(event, template) {
        var opinions = [];
        var o = db.steedos_keyvalues.findOne({
            user: Meteor.userId(),
            key: 'flow_opinions',
            'value.workflow': {
                $exists: true
            }
        });
        if (o) {
            opinions = o.value.workflow;
            var index = opinions.indexOf(Session.get('flow_selected_opinion'));
            if (index > -1) {
                opinions.splice(index, 1);

                Meteor.call('setKeyValue', 'flow_opinions', {
                    workflow: opinions
                }, function(error, result) {
                    Session.set('flow_selected_opinion', undefined);

                    if (error) {
                        swal({
                            title: "Error!",
                            type: "error",
                            text: error,
                            closeOnConfirm: true,
                            confirmButtonText: t('OK')
                        });
                    }

                    if (result == true) {
                        swal({
                            title: "Nice!",
                            type: "success",
                            closeOnConfirm: true,
                            confirmButtonText: t('OK')
                        });
                    }

                });
            }
        }
    },

    'click #instance_flow_opinions_up': function(event, template) {
        var selected = Session.get('flow_selected_opinion');
        var opinions = [];
        var o = db.steedos_keyvalues.findOne({
            user: Meteor.userId(),
            key: 'flow_opinions',
            'value.workflow': {
                $exists: true
            }
        });
        if (o) {
            var opinions = o.value.workflow;
            var index = opinions.indexOf(selected);
            if (index == 0) return;
            var f = opinions[index - 1];
            opinions[index - 1] = selected;
            opinions[index] = f;
            Meteor.call('setKeyValue', 'flow_opinions', {
                workflow: opinions
            }, function(error, result) {

                if (error) {
                    swal({
                        title: "Error!",
                        type: "error",
                        text: error,
                        closeOnConfirm: true,
                        confirmButtonText: t('OK')
                    });
                }

            });
        }
    },

    'click #instance_flow_opinions_down': function(event, template) {
        var selected = Session.get('flow_selected_opinion');
        var opinions = [];
        var o = db.steedos_keyvalues.findOne({
            user: Meteor.userId(),
            key: 'flow_opinions',
            'value.workflow': {
                $exists: true
            }
        });
        if (o) {
            var opinions = o.value.workflow;
            var index = opinions.indexOf(selected);
            if (index == (opinions.length - 1)) return;
            var f = opinions[index + 1];
            opinions[index + 1] = selected;
            opinions[index] = f;
            Meteor.call('setKeyValue', 'flow_opinions', {
                workflow: opinions
            }, function(error, result) {

                if (error) {
                    swal({
                        title: "Error!",
                        type: "error",
                        text: error,
                        closeOnConfirm: true,
                        confirmButtonText: t('OK')
                    });
                }

            });
        }
    },

    'change #instance_flow_comment': function(event, template) {
        Session.set('flow_comment', event.target.value);
    },

    'click #opinion_modal_ok': function(event, template) {
        $("#suggestion").val(Session.get('flow_comment'));
        Modal.hide(template);
    }
})