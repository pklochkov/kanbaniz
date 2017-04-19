/**
 * Created by pavel on 02.04.2017.
 */
({
    doInit:function(cmp, evt, helper){
        console.log('doInit');
        helper.init(cmp);
    },

    onBoardCardDropped:function(cmp, evt, helper){
       console.log('onBoardCardDropped');
       console.log(evt);
       var params = evt.getParams();
       var model =  cmp.get('v.model');
       helper.updateColumn(cmp, {
           id:+params.modelid,
           status:params.column
       }, model);
       cmp.set('v.columns',helper.getObjectsByColumns(cmp.get('v.columnNames'), model));
    },

    onRecordUpdate:function(cmp, evt, helper){
        console.log(evt);
        var params = evt.getParams();
        if(params.action == 'ok'){
           cmp.find("editRecord").saveRecord();
        }
        cmp.set('v.recordEditModal', false);
    },

    onCardEdit:function(cmp, evt, helper){
        console.log(evt);
        var params = evt.getParams();
        var model = cmp.get('v.model');
        if(params.modelid){
            cmp.set('v.editRecordId',model[params.modelid].recordId);
            cmp.find("editRecord").setRecordId(model[params.modelid].recordId);
            cmp.set('v.recordEditModal',true);
        }else{
          console.log(params);
        }
    }

})