/**
 * Created by pavel on 17.04.2017.
 */
({
    setRecord:function(cmp, evt, helper){
        var params = evt.getParam('arguments');
        var recordId = params.recordId;
        $A.createComponent(
            'c:RecordEdit',
            {
                'recordId':recordId,
            },
            function(newCmp,status,message){
                console.log(status);
                console.log(message);
                if(status =='SUCCESS'){
                    var container = cmp.get('v.body');
                    container[0] = (newCmp);
                    cmp.set('v.body',container);
                }
            }
        );
    },
    saveRecord:function(cmp, evt, helper){
        var body = cmp.get('v.body')
        var recordEdit = body[0];// body[0];

        recordEdit.saveRecord();
    }
})