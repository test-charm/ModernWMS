package org.testcharmtraining.spec;

import lombok.Getter;
import lombok.Setter;
import org.testcharm.jfactory.Spec;
import org.testcharmtraining.entity.Supplier;

import java.util.List;

public class Suppliers {
    public static class 供应商 extends Spec<Supplier> {
        @Override
        public void main() {
            property("creator").value("e2e-supplier");
            property("valid").value(true);
            property("tenantId").value(9001L);
        }
    }

    public static class 供应商查询请求 extends Spec<SupplierQueryRequest> {
        @Override
        public void main() {
            property("pageIndex").value(1);
            property("pageSize").value(20);
            property("sqlTitle").value("");
        }
    }

    @Getter
    @Setter
    public static class SupplierQueryRequest {
        private int pageIndex, pageSize;
        private String sqlTitle;
        private List<SearchObject> searchObjects;

        @Getter
        @Setter
        public static class SearchObject {
            private String name, text, value;
            private int operator;
        }
    }
}
