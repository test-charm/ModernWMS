package org.testcharmtraining.spec;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.testcharm.jfactory.Spec;
import org.testcharmtraining.entity.Category;

import static org.testcharmtraining.ContextWrapper.getCurrentUserTenantId;

public class Categories {
    public static class 商品类别 extends Spec<Category> {
        @Override
        public void main() {
            property("valid").value(true);
            property("tenantId").value(getCurrentUserTenantId());
        }
    }

    public static class 商品类别创建请求 extends Spec<CategoryCreateRequest> {
        @Override
        public void main() {
            property("parentId").value(0);
            property("valid").value(true);
        }
    }

    public static class 商品类别修改请求 extends Spec<CategoryUpdateRequest> {
        @Override
        public void main() {
            property("parentId").value(0);
            property("valid").value(true);
        }
    }

    @Getter
    @Setter
    public static class CategoryCreateRequest {
        @JsonProperty("category_name")
        private String categoryName;

        @JsonProperty("parent_id")
        @JsonInclude(JsonInclude.Include.NON_NULL)
        private Integer parentId;

        @JsonProperty("is_valid")
        private boolean valid;
    }

    @Getter
    @Setter
    public static class CategoryUpdateRequest extends CategoryCreateRequest {
        private int id;
    }
}
