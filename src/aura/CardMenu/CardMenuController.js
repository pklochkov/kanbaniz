/**
 * Created by pavel on 15.04.2017.
 */
({
    toggleMenu:function(cmp, evt, helper){
        var isOpen = cmp.get('v.isOpen') === true;
        helper.showMenu(cmp, !isOpen);
    },

    editRecord:function(cmp, evt, helper){
        console.log(cmp);
        console.log(evt);
        var value = cmp.get('v.model');
        var evt = cmp.getEvent('onCardEdit');

        evt.setParams({
          'modelid': value.id,
        });
        evt.fire();
        helper.showMenu(cmp, false);
    }
})