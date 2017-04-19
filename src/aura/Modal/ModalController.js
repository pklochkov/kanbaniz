/**
 * Created by pavel on 16.04.2017.
 */
({
    doInit:function(cmp,event,helper){

    },

    onCNCButtonClick:function(cmp,event,helper){
        var event = cmp.getEvent('modalButtonPress');
        var params = {
            action:'cancel',
            modalId: cmp.get('v.modalId')
        }
        event.setParams(params);
        event.fire();
    },

    onOKButtonClick:function(cmp,event,helper){
        var event = cmp.getEvent('modalButtonPress');
        var params = {
            action:'ok',
            modalId: cmp.get('v.modalId')
        }
        event.setParams(params);
        event.fire();
    }
})