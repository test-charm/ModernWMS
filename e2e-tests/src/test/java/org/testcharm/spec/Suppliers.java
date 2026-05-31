package org.testcharm.spec;

import com.github.leeonky.jfactory.Spec;
import org.testcharm.entity.Supplier;

import java.time.LocalDateTime;

public class Suppliers {
    public static class 供应商 extends Spec<Supplier> {
        @Override
        public void main() {
            property("id").ignore();
            property("creator").value("e2e-supplier");
            property("createTime").value(LocalDateTime.of(2024, 1, 1, 0, 0));
            property("lastUpdateTime").value(LocalDateTime.of(2024, 1, 1, 0, 0));
            property("valid").value(true);
            property("tenantId").value(9001L);
        }
    }
}
