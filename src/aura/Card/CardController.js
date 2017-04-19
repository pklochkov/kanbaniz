/**
 * Created by pavel on 02.04.2017.
 */
({
    doInit:function(cmp){
        var model = cmp.get('v.model');
        var values = model.values;
        cmp.set('v.values',values);
        console.log(values);
    },

    onDragStart:function(cmp,evt){
        var model = cmp.get('v.model');
        console.log(model);
        evt.dataTransfer.setData('modelid', model.id);
        evt.effectAllowed = true;
        return true;
    }
})