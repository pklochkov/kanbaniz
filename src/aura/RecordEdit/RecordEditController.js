/**
 * Created by pavel on 18.04.2017.
 */
({
    saveRecord:function(cmp, evt, helper){
        var recordEdit = cmp.find('editorOfRecord');// body[0];
        console.log(recordEdit);
        var recordSaveEvent = recordEdit.get('e.recordSave');
        console.log(recordSaveEvent);
        recordSaveEvent.fire();
    }
})