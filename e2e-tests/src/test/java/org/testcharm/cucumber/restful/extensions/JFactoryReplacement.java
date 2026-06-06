package org.testcharm.cucumber.restful.extensions;

import org.testcharm.jfactory.JFactory;
import org.testcharm.util.BeanClass;
import org.testcharm.util.PropertyReader;
import org.testcharmtraining.ContextWrapper;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class JFactoryReplacement {

    public static String eval(String expression) {
        return String.valueOf(evalValue(expression));
    }

    public static Object evalValue(String v) {
        v = v.trim();
        Matcher matcher = Pattern.compile("([^\\.]*)\\.(.*)\\[(.*)\\]\\.(.*)").matcher(v);
        var jFactory = ContextWrapper.getContext().getBean(JFactory.class);
        if (matcher.find()) {
            Object object = jFactory.spec(matcher.group(1))
                    .property(matcher.group(2), matcher.group(3))
                    .query();
            BeanClass beanClass = BeanClass.create((Class) object.getClass());
            PropertyReader propertyReader = null;
            Object propertyValue = object;
            for (String prop : matcher.group(4).split("\\.")) {
                propertyReader = beanClass.getPropertyReader(prop);
                propertyValue = propertyReader.getValue(propertyValue);
                beanClass = propertyReader.getType();
            }
            return propertyValue;
        } else {
            matcher = Pattern.compile("([^\\.]*)\\.(.*)\\[(.*)\\]").matcher(v);
            if (matcher.find())
                return jFactory.spec(matcher.group(1))
                        .property(matcher.group(2), matcher.group(3))
                        .query();
            else
                throw new IllegalArgumentException("Cannot parse content " + v);
        }
    }

}
