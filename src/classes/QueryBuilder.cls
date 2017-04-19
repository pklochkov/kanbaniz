/**
 * Created by pavel on 15.04.2017.
 */

public with sharing class QueryBuilder {
    private static final String queryTemplate = 'SELECT {0} FROM {1} {2}';

    private Set<String> queryFields = new Set<String>();
    private String objectType = '';
    private String wherePart = '';
    private Integer limitNum;
    private Map<String, Object> valueMap;

    private QueryBuilder(Object[] queryFields) {
        for (Object queryField:queryFields) {
            this.queryFields.add(String.valueOf(queryField));
        }
        System.debug('this.queryFields ' + this.queryFields);
    }

    public static QueryBuilder qSelect(Object[] queryFields) {
        return new QueryBuilder(queryFields);
    }

    public QueryBuilder qFrom(Object type) {
        this.objectType = String.valueOf(type);
        return this;
    }

    public QueryBuilder qWhere(String whereMap) {
        String wherePart = whereMap;
        if (String.isBlank(wherePart)) {
            this.wherePart = '';
        } else {
            if (wherePart.trim().startsWithIgnoreCase('where')) {
                this.wherePart = ' ' + wherePart;
            } else {
                this.wherePart = ' where ' + wherePart;
            }
        }
        System.debug('this.wherePart ' + this.wherePart);
        return this;
    }

    public QueryBuilder qWhere(QueryCriterion criterion) {
        return this.qWhere(criterion.toString());
    }


    private String formLimitPart(Integer limitNum) {
        this.limitNum = limitNum;
        String limitPart = limitNum == null ? '' : (' LIMIT ' + limitNum);
        System.debug('limitPart ' + limitPart);
        return limitPart;
    }

    public SObject[] qList() {
        return this.qList(null);
    }

    public SObject[] qList(Integer limitNum) {
        Map<String, Object> values = this.valueMap;
        String query = String.format(
                QueryBuilder.queryTemplate,
                new String[]{
                        String.join(new List<String>(this.queryFields), ','),
                        this.objectType,
                        this.wherePart,
                        this.formLimitPart(limitNum)
                }
        );
        System.debug('query ' + query);
        return Database.query(query);
    }

    public Map<Id, SObject> qMap() {
        return this.qMap(null);
    }

    public Map<Id, SObject> qMap(Integer limitNum) {
        return new Map<Id, SObject>(this.qList(limitNum));
    }
}