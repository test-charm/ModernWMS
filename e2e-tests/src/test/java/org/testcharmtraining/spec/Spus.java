package org.testcharmtraining.spec;

import org.testcharm.jfactory.Spec;
import org.testcharmtraining.entity.Spu;

import static org.testcharmtraining.ContextWrapper.getCurrentUserTenantId;

public class Spus {
    public static class 商品 extends Spec<Spu> {
        @Override
        public void main() {
            property("spuCode").defaultValue("default-spu-code");
            property("spuName").defaultValue("default-spu-name");
            property("spuDescription").defaultValue("default-spu-description");
            property("supplierId").defaultValue(1);
            property("supplierName").defaultValue("default-supplier");
            property("brand").defaultValue("default-brand");
            property("origin").defaultValue("default-origin");
            property("lengthUnit").defaultValue((byte) 1);
            property("volumeUnit").defaultValue((byte) 0);
            property("weightUnit").defaultValue((byte) 1);
            property("creator").defaultValue("e2e-login-hook-user");
            property("valid").defaultValue(true);
            property("tenantId").defaultValue(getCurrentUserTenantId());
        }
    }
}
