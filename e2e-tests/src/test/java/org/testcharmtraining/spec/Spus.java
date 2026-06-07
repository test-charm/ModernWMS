package org.testcharmtraining.spec;

import org.testcharm.jfactory.Spec;
import org.testcharmtraining.entity.Spu;

import static org.testcharmtraining.ContextWrapper.getCurrentUserTenantId;

public class Spus {
    public static class 商品 extends Spec<Spu> {
        @Override
        public void main() {
            property("tenantId").defaultValue(getCurrentUserTenantId());
            property("category").is(Categories.商品类别.class);
        }
    }
}
