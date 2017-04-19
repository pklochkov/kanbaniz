/**
 * Created by pavel on 02.04.2017.
 */
({
    onDragEnter:function(cmp,evt){
        evt.preventDefault();
        console.log('onDragEnter');
        return true;
    },

    onDragOver:function(cmp,evt){
        evt.preventDefault();
        console.log('onDragOver');
        return true;
    },

    onDrop:function(cmp,evt){
        console.log('onDrop');
        var model = cmp.get('v.column')
        var dropEvent = cmp.getEvent('boardCardDropped');
        dropEvent.setParams({
            modelid:evt.dataTransfer.getData('modelid'),
            column: model.name
        })
        dropEvent.fire();
        return true;
    }
})