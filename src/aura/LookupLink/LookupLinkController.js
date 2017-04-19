/**
 * Created by pavel on 15.04.2017.
 */
({
    showRelatedRecord:function(cmp,evt){
        var value = cmp.get('v.value');
        var navEvt = $A.get("e.force:navigateToSObject");

        navEvt.setParams({
          "recordId": value.exactValue,
        });
        navEvt.fire();

    }
})