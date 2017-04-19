/**
 * Created by pavel on 15.04.2017.
 */

public with sharing class QueryCriterion {
    private Schema.DescribeFieldResult fieldInfo;
    private String logicConcat = null;
    private String field = null;
    private String op = '!=';
    private String value = 'null';
    private List<QueryCriterion> criterionChain = new List<QueryCriterion>();

    private QueryCriterion addCriterion(String op, QueryCriterion criterion) {
        criterion.logicConcat = op;
        criterionChain.add(criterion);
        return this;
    }


    public QueryCriterion(Schema.SObjectField field, String op, Object value) {
        this.fieldInfo = field.getDescribe();
        this.field = QueryValueProvider.escapeValue(String.valueOf(field));
        if (value instanceof List<Object> || value instanceof Set<Id>) {
            this.op = ' in ';
        } else {
            this.op = QueryValueProvider.escapeValue(op);
        }
        this.value = QueryValueProvider.getSOQLTypedValue(this.fieldInfo.getType(), value);
    }

    public QueryCriterion(Schema.SObjectField field) {
        this(field, '!=', 'null');
    }

    public QueryCriterion(Schema.SObjectField field, Object value) {
        this(field, '=', value);
    }


    public QueryCriterion qAnd(QueryCriterion criterion) {
        return this.addCriterion('AND', criterion);
    }

    public QueryCriterion qOr(QueryCriterion criterion) {
        return this.addCriterion('AND', criterion);
    }

    public override String toString() {
        String thisValue = String.join(new String[]{
                this.field, this.op, this.value
        }, '');
        List<String> parts = new List<String>();
        parts.add('(');
        parts.add(thisValue);
        for (QueryCriterion qc:this.criterionChain) {
            parts.add(' ' + qc.logicConcat + ' ');
            parts.add(qc.toString());
        }
        parts.add(')');
        String result = String.join(parts, '');
        System.debug('result ' + result);
        return result;
    }
}