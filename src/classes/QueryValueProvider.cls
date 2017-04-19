/**
 * Created by pavel on 15.04.2017.
 */

public with sharing class QueryValueProvider {
    private static final Map<String, Set<Schema.DisplayType>> soqlTypeConversionMap = new Map<String, Set<Schema.DisplayType>>{
            'quoted' => new Set<Schema.DisplayType>{
                    Schema.DisplayType.ENCRYPTEDSTRING,
                    Schema.DisplayType.TEXTAREA,
                    Schema.DisplayType.STRING,
                    Schema.DisplayType.EMAIL,
                    Schema.DisplayType.REFERENCE,
                    Schema.DisplayType.ID,
                    Schema.DisplayType.URL
            }
    };

    public static String escapeValue(String valStr) {
        String value = String.isBlank(valStr) ? 'null' : String.valueOf(valStr).trim();
        return String.escapeSingleQuotes(value);
    }
    private static String leadZero(Integer d) {
        if (d < 10) {
            return '0' + d;
        }
        return String.valueOf(d);
    }

    public static String soqlDate(Date d, Time t) {
        String result = QueryValueProvider.leadZero(d.year()) + '-'
                + QueryValueProvider.leadZero(d.month()) + '-'
                + QueryValueProvider.leadZero(d.day());
        if (t != null) {
            result += 'T' + QueryValueProvider.leadZero(t.hour()) + ':'
                    + QueryValueProvider.leadZero(t.minute()) + ':'
                    + QueryValueProvider.leadZero(t.second()) + 'Z';
        }
        return result;
    }

    public static String getSOQLTypedValue(Schema.DisplayType fieldType, Object val) {
        System.debug('fieldType ' + fieldType);
        if (val == null) {
            return 'null';
        }

        if (val instanceof String) {
            if (soqlTypeConversionMap.get('quoted').contains(fieldType)) {
                return ('\'' + QueryValueProvider.escapeValue(String.valueOf(val).trim()) + '\'');
            }
            return QueryValueProvider.escapeValue(String.valueOf(val).trim());
        }

        if (val instanceof Date) {
            Boolean includeDate = fieldType == Schema.DisplayType.DATETIME;
            Time t = null;
            if (includeDate) {
                t = Time.newInstance(0, 0, 0, 0);
            }
            return QueryValueProvider.soqlDate((Date) val, t);
        }

        if (val instanceof Datetime) {
            Boolean includeDate = fieldType == Schema.DisplayType.DATETIME;
            Datetime dt = (Datetime) val;
            Time t = null;
            if (includeDate) {
                t = dt.time();
            }
            return QueryValueProvider.soqlDate(dt.date(), t);
        }
        if (val instanceof List<Object>) {
            List<String> parts = new List<String>();
            for (Object item:(List<Object>) val) {
                parts.add(QueryValueProvider.getSOQLTypedValue(fieldType, item));
            }

            return '(' + String.join(parts, ',') + ')';
        }
        if (val instanceof Set<Id>) {
            List<String> parts = new List<String>();
            for (Id item:(Set<Id>) val) {
                parts.add(QueryValueProvider.getSOQLTypedValue(fieldType, item));
            }
            return '(' + String.join(parts, ',') + ')';
        }
        return QueryValueProvider.escapeValue(String.valueOf(val));
    }
}