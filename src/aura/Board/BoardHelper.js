/**
 * Created by pavel on 02.04.2017.
 */
({
    getCardRequest:function(cmp){
        var recordId = cmp.get('v.recordId');
        var sObjectName = cmp.get('v.sObjectName');
        var columnField = cmp.get('v.columnField');
        var groupingField = cmp.get('v.groupingField');
        var fieldsString = cmp.get('v.cardFields');
        console.log(fieldsString);
        return {
           relationField: cmp.get('v.relationField'),
           recordId:recordId,
           sObjectName:sObjectName || 'Task',
           columnField:columnField || 'status',
           groupingField:null,
           fieldsString: fieldsString || 'subject;status'
       };
    },

    fetchModel:function(cmp,options){
        var getAvailableCards = cmp.get('c.getAvailableCards');
        getAvailableCards.setParams(options);
        getAvailableCards.setCallback(this,function(res){
            switch(res.getState()){
                case 'SUCCESS':{
                    var objects = res.getReturnValue();
                    var model = this.refreshObjectModel(objects);
                    console.log(model);
                    cmp.set('v.model',model);
                } break;
            }
        });
        return getAvailableCards;
    },

    fetchContent:function(cmp,options){
        var getAvailableStatuses = cmp.get('c.getAvailableStatuses');
        getAvailableStatuses.setParams(options);
        getAvailableStatuses.setCallback(this,function(res){
            switch(res.getState()){
                case 'SUCCESS':{
                  var columnNames = res.getReturnValue();
                  cmp.set('v.columnNames', columnNames);
                  var objects = cmp.get('v.model');
                  cmp.set('v.columns', this.getObjectsByColumns(columnNames, objects));
                } break;
            }
        });
        return getAvailableStatuses;
    },

    init:function(cmp){
        var cardRequest = {
            requestStr: JSON.stringify(this.getCardRequest(cmp))
        };
        console.log(cardRequest);

        var getAvailableCards = this.fetchModel(cmp,cardRequest);
        var getAvailableStatuses = this.fetchContent(cmp,cardRequest);

        $A.enqueueAction(getAvailableCards);
        $A.enqueueAction(getAvailableStatuses);
    },

    refreshObjectModel :function(objects){
        var i = 1;
        var self = this;
        var objectModel = {};
        objects.forEach(function(item){
            item.id = i++;
            objectModel[item.id] = item;
        });
        return objectModel;
    },

    getObjectsByColumns:function(columnNames, model){
        var columns = [];
        var objects = [];
        for(var key in model){
            objects.push(model[key]);
        }
        columnNames.forEach(function(item){
            columns.push({
                name:item,
                cards:objects.filter(function(obj){
                    return obj.status == item;
                })
            })
        })
        return columns;
    },

    updateColumn:function(cmp, item, model){
        model[item.id].status = item.status;
        var updateAction = cmp.get('c.updateCards');
        var options = this.getCardRequest(cmp);
        var updateCallOptions = {
            options:options,
            cards : [model[item.id]]
        }

        updateAction.setParams({
            requestStr:JSON.stringify(updateCallOptions)
        })

        updateAction.setCallback(this,function(res){
            switch(res.getState()){
                case 'SUCCESS':{
                    var result = res.getReturnValue();
                    console.log(result);
                } break;
            }
        })
        $A.enqueueAction(updateAction);
    }
})