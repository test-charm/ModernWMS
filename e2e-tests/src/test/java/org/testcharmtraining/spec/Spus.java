package org.testcharmtraining.spec;

import org.testcharm.jfactory.Spec;
import org.testcharmtraining.entity.Spu;

import static org.testcharmtraining.ContextWrapper.getCurrentUserTenantId;

public class Spus {
    public static class 商品 extends Spec<Spu> {
        @Override
        public void main() {
            property("spuCode").value("default-spu-code");
            property("spuName").value("default-spu-name");
            property("spuDescription").value("default-spu-description");
            property("supplierId").value(1);
            property("supplierName").value("default-supplier");
            property("brand").value("default-brand");
            property("origin").value("default-origin");
            property("lengthUnit").value((byte) 1);
            property("volumeUnit").value((byte) 0);
            property("weightUnit").value((byte) 1);
            property("creator").value("e2e-login-hook-user");
            property("valid").value(true);
            property("tenantId").value(getCurrentUserTenantId());
        }
    }
}
