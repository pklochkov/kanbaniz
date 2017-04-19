/**
 * Created by pavel on 04.04.2017.
 */

public with sharing class BoardController {
    private static final Map<Schema.SObjectType, Schema.SObjectField[]> defaultsStandardObjectMap = new Map<SObjectType, SObjectField[]>{
            Task.sObjectType => new Schema.SObjectField[]{
                    Task.Id,
                    Task.Subject,
                    Task.OwnerId,
                    Task.Status
            }
    };

    public class CardDynamicField {
        public CardDynamicField(Schema.DescribeFieldResult field,
                Object value,
                Map<Schema.SObjectType, Map<Id, SObject>> context) {
            this.label = field.getLabel();
            this.value = new BoardController.DynamicFieldValue(value, field, context);
        }

        @AuraEnabled
        public String label;

        @AuraEnabled
        public DynamicFieldValue value;
    }
    public class DynamicFieldValue {
        public DynamicFieldValue(Object value,
                Schema.DescribeFieldResult field,
                Map<Schema.SObjectType, Map<Id, SObject>> context
        ) {
            System.debug('context ' + context);
            Schema.DisplayType fieldType = field.getType();
            System.debug('fieldType ' + fieldType);
            this.fieldType = String.valueOf(fieldType);
            if (Schema.DisplayType.REFERENCE == fieldType) {
                this.exactValue = String.valueOf(value);
                Id relatedId = Id.valueOf(this.exactValue);
                Map<Id, SObject> objectMap = context.get(relatedId.getSobjectType());
                SObject obj = objectMap.get(relatedId);
                this.displayValue = String.valueOf(obj.get('name'));
                System.debug('this.displayValue ' + this.displayValue);
            } else {
                this.fieldType = String.valueOf(fieldType);

                //if (value instanceof String) {
                this.displayValue = String.valueOf(value);
                this.exactValue = String.valueOf(value);
//            } if (value instanceof Id) {
//
//            }
            }
        }

        public Object getSObjectFieldValue() {
            return this.exactValue;
        }

        @AuraEnabled
        public String fieldType;
        @AuraEnabled
        public String displayValue;
        @AuraEnabled
        public String exactValue;
    }

    public abstract class EditCard {
        public String recordId;

        public String type;

        public String name;

        public String status;

        public String grouping;
    }

    public class Card extends BoardController.EditCard {
        public Card(SObject obj,
                BoardController.CardRequest request,
                Schema.SObjectField[] objectFields,
                Map<Schema.SObjectType, Map<Id, SObject>> context) {
            this.values = new List<BoardController.CardDynamicField>();

            this.recordId = obj.Id;
            this.type = String.valueOf(obj.getSObjectType());

            for (Schema.SObjectField field :objectFields) {
                if (String.valueOf(field).equalsIgnoreCase(request.columnField)) {
                    this.status = String.valueOf(obj.get(field));
                } else if (String.valueOf(field).equalsIgnoreCase(request.groupingField)) {
                    this.grouping = String.valueOf(obj.get(field));
                } else if (String.valueOf(field).equalsIgnoreCase('name')) {
                    this.name = String.valueOf(obj.get(field));
                } else if (field == Task.Subject) {
                    this.name = String.valueOf(obj.get(Task.Subject));
                } else {
                    Schema.DescribeFieldResult fieldResult = field.getDescribe();
                    this.values.add(new BoardController.CardDynamicField(fieldResult,
                            obj.get(field), context));
                }
            }
        }
//
        @AuraEnabled
        public String recordId;

        @AuraEnabled
        public String type;

        @AuraEnabled
        public String name;

        @AuraEnabled
        public String status;

        @AuraEnabled
        public String grouping;

        @AuraEnabled
        public List<CardDynamicField> values;
    }

    public class CardRequest {
        @AuraEnabled
        public String sObjectName;

        @AuraEnabled
        public String columnField;

        @AuraEnabled
        public String groupingField;

        @AuraEnabled
        public String fieldsString;

        @AuraEnabled
        public String relationField;

        @AuraEnabled
        public String recordId;
    }

    public class SaveCardRequest {
        BoardController.CardRequest options;
        BoardController.EditCard[] cards;
    }

    private static Schema.SObjectField[] getQueryFields(CardRequest request, Schema.DescribeSObjectResult objectType) {
        Map<String, Schema.SObjectField> fieldMap = objectType.fields.getMap();

        Schema.SObjectField[] result = new List<Schema.SObjectField>();
        if (result == null) {
            result = new List<Schema.SObjectField>();
        }

        Set<String> splitedNames = new Set<String>{
                'id', 'name', 'ownerid'
        };

        if (String.isNotBlank(request.fieldsString)) {
            splitedNames.addAll(request.fieldsString.split(';'));
        }

        if (String.isNotBlank(request.columnField)) {
            splitedNames.add(request.columnField);
        }

        if (String.isNotBlank(request.groupingField)) {
            splitedNames.add(request.groupingField);
        }


        for (String fieldName:splitedNames) {
            String clearName = fieldName.trim().toLowerCase();
            if (String.isNotBlank(clearName)) {
                Schema.SObjectField field = fieldMap.get(clearName);
                if (field != null) {
                    result.add(field);
                }
            }
        }
        System.debug('fields ' + result);
        return result;
    }

    private static Object instantiateType(String typeName) {
        return Type.forName(typeName).newInstance();
    }

    private static Schema.SObjectType getSObjectType(CardRequest request) {
        if (request == null
                || String.isBlank(request.sObjectName)
                || String.valueOf(Task.sObjectType).equalsIgnoreCase(request.sObjectName)) {
            return Task.sObjectType;
        } else {
            return ((SObject) BoardController.instantiateType(request.sObjectName)).getSObjectType();
//TODO : Exception here if type not found;
        }
    }

    private static Map<Schema.SObjectType, Set<Id>> getRelatedRecordIdsMap(Schema.SObjectField[] fields, SObject[] values) {
        Map<Schema.SObjectType, Set<Id>> result = new Map<Schema.SObjectType, Set<Id>>();
        Map<Schema.SObjectField, Schema.SObjectType[]> fieldToSObjectTypeMap = new Map<SObjectField, SObjectType[]>();
        for (Schema.SObjectField field:fields) {
            Schema.DescribeFieldResult fieldInfo = field.getDescribe();
            if (fieldInfo.getType() == Schema.DisplayType.REFERENCE) {
                fieldToSObjectTypeMap.put(field, fieldInfo.getReferenceTo());
            }
        }

        for (SObject obj:values) {
            for (Schema.SObjectField field:fieldToSObjectTypeMap.keySet()) {
                Id refValue = Id.valueOf(String.valueOf(obj.get(field)));
                for (Schema.SObjectType objectType:fieldToSObjectTypeMap.get(field)) {
                    Set<Id> recordIds = result.get(objectType);
                    if (recordIds == null) {
                        recordIds = new Set<Id>{
                                refValue
                        };
                        result.put(objectType, recordIds);
                    } else {
                        recordIds.add(refValue);
                    }
                }
            }
        }
        return result;
    }

    private static Map<Schema.SObjectType, Map<Id, SObject>> getRelatedRecords(Map<Schema.SObjectType, Set<Id>> sObjectTypeIdMap) {
        Map<Schema.SObjectType, Map<Id, SObject>> result = new Map<SObjectType, Map<Id, SObject>>();
        String[] recFields = new String []{
                'id', 'name'
        };
        for (Schema.SObjectType objectType:sObjectTypeIdMap.keySet()) {
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            Map<Id, SObject> recordMap = QueryBuilder.qSelect(recFields)
                    .qFrom(objectType)
                    .qWhere(new QueryCriterion(fieldMap.get('id'), sObjectTypeIdMap.get(objectType)))
                    .qMap();
            result.put(objectType, recordMap);
        }
        return result;
    }

    @AuraEnabled
    public static Card[] getAvailableCards(String requestStr) {
        CardRequest request = (CardRequest) JSON.deserialize(requestStr, CardRequest.class);
        System.debug('request ' + request);
        Schema.SObjectType objectType = BoardController.getSObjectType(request);
        Schema.DescribeSObjectResult describeObjectResult = objectType.getDescribe();
        Schema.SObjectField[] objectFields = BoardController.getQueryFields(request, describeObjectResult);
        Schema.SObjectField parentField = describeObjectResult
                .fields
                .getMap()
                .get(request.relationField.toLowerCase());
        List<Card> cards = new List<Card>();
        Set<Id> recordIds = new Set<Id>();
        SObject[] values = QueryBuilder.qSelect(objectFields)
                .qFrom(objectType)
                .qWhere(new QueryCriterion(parentField, request.recordId)).qList();
        Map<Schema.SObjectType, Set<Id>> recIdsBySObjectTypes = BoardController.getRelatedRecordIdsMap(objectFields, values);
        Map<Schema.SObjectType, Map<Id, SObject>> objectTypeRecordMap = BoardController.getRelatedRecords(recIdsBySObjectTypes);

        for (SObject obj: values) {
            recordIds.add(obj.Id);
            cards.add(new Card(obj, request, objectFields, objectTypeRecordMap));
        }

        System.debug('cards ' + cards);
        return cards;
    }


    @AuraEnabled
    public static List<String> getAvailableStatuses(String requestStr) {
        CardRequest request = (CardRequest) JSON.deserialize(requestStr, CardRequest.class);
        System.debug('request ' + request);
        Schema.SObjectType objectType = BoardController.getSObjectType(request);
        List<String> statuses = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();

        Schema.SObjectField field = fieldMap.get(request.columnField.trim().toLowerCase());
        Schema.DescribeFieldResult fr = field.getDescribe();

        for (Schema.PicklistEntry pr:fr.getPicklistValues()) {
            statuses.add(pr.getValue());
        }

        return statuses;
    }

    @AuraEnabled
    public static String updateCards(String requestStr) {
        SaveCardRequest cardRequest = (SaveCardRequest) JSON.deserialize(requestStr, SaveCardRequest.class);
        System.debug('saveCardRequest ' + cardRequest);
        SObject[] instances = new List<SObject>();
        for (EditCard card:cardRequest.cards) {
            SObject instance = (SObject) BoardController.instantiateType(cardRequest.options.sObjectName);
            instance.Id = card.recordId;
            instance.put(cardRequest.options.columnField, card.status);
            instances.add(instance);
        }

        update instances;

        return 'OK';
    }
}