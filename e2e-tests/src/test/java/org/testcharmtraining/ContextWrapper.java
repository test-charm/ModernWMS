package org.testcharmtraining;

import lombok.Getter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;
import org.testcharm.jfactory.JFactory;
import org.testcharmtraining.entity.WmsUser;

@Service
public class ContextWrapper {

    @Getter
    private static ApplicationContext context;

    @Autowired
    public ContextWrapper(ApplicationContext ac) {
        context = ac;
    }

    public static long getCurrentUserTenantId() {
        return context.getBean(JFactory.class).type(WmsUser.class).query().getTenantId();
    }
}
