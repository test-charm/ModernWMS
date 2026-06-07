package org.testcharmtraining.spec;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.testcharm.jfactory.Spec;
import org.testcharmtraining.entity.Supplier;

import java.util.List;

import static org.testcharmtraining.ContextWrapper.getCurrentUserTenantId;

public class Suppliers {
    public static class 供应商 extends Spec<Supplier> {
        @Override
        public void main() {
            property("valid").value(true);
            property("tenantId").value(getCurrentUserTenantId());
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

    public static class 供应商创建请求 extends Spec<SupplierCreateRequest> {
        @Override
        public void main() {
            property("valid").value(true);
        }
    }

    public static class 供应商修改请求 extends Spec<SupplierUpdateRequest> {
        @Override
        public void main() {
            property("valid").value(true);
        }
    }

    public static class 供应商导入请求 extends Spec<SupplierImport> {

    }

    @Getter
    @Setter
    public static class SupplierQueryRequest {
        private int pageIndex, pageSize;
        private String sqlTitle;
        @JsonInclude(JsonInclude.Include.NON_NULL)
        private List<SearchObject> searchObjects;

        @Getter
        @Setter
        public static class SearchObject {
            private String name, text, value;
            private int operator;
        }
    }

    @Getter
    @Setter
    public static class SupplierCreateRequest extends SupplierImport {
        @JsonProperty("is_valid")
        private boolean valid;
    }

    @Getter
    @Setter
    public static class SupplierUpdateRequest extends SupplierCreateRequest {
        private int id;
    }

    @Getter
    @Setter
    public static class SupplierImport {
        @JsonProperty("supplier_name")
        private String supplierName;
        private String city, address, email, manager;
        @JsonProperty("contact_tel")
        private String contactTel;
    }
}
