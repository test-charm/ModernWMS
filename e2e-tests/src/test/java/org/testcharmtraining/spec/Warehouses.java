package org.testcharmtraining.spec;

import org.testcharm.jfactory.Spec;
import org.testcharmtraining.entity.Warehouse;

import static org.testcharmtraining.ContextWrapper.getCurrentUserTenantId;

public class Warehouses {
    public static class 仓库 extends Spec<Warehouse> {
        @Override
        public void main() {
            property("valid").defaultValue(true);
            property("tenantId").defaultValue(getCurrentUserTenantId());
        }
    }
}
