package org.testcharmtraining.spec;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.testcharm.jfactory.Spec;
import org.testcharm.jfactory.Trait;
import org.testcharmtraining.entity.Category;
import org.testcharmtraining.entity.Spu;
import org.testcharmtraining.entity.Supplier;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import static org.testcharmtraining.ContextWrapper.getCurrentUserTenantId;

public class Spus {
    public static class 商品 extends Spec<Spu> {
        @Override
        public void main() {
            property("valid").defaultValue(true);
            property("tenantId").defaultValue(getCurrentUserTenantId());
            property("category").is(Categories.商品类别.class);
            property("supplier").is(Suppliers.供应商.class);
            property("skus").reverseAssociation("spu");
            property("skus[]").apply("规格");

            link("supplierName", "supplier.supplierName");
        }
    }

    public static class 商品查询请求 extends Spec<ProductQueryRequest> {
        @Override
        public void main() {
            property("pageIndex").value(1);
            property("pageSize").value(20);
            property("sqlTitle").value("");
        }
    }

    public static class 商品创建请求 extends Spec<ProductCreateRequest> {
        @Override
        public void main() {
            property("lengthUnit").value(1);
            property("volumeUnit").value(0);
            property("weightUnit").value(1);
            property("detailList[]").apply("商品规格请求");
        }

        @Trait
        public void 依赖已存在的() {
            property("category").is(Categories.商品类别.class);
            property("categoryId").dependsOn("category", (category) -> ((Category) category).getId());
            link("categoryName", "category.categoryName");

            property("supplier").is(Suppliers.供应商.class);
            property("supplierId").dependsOn("supplier", (supplier) -> ((Supplier) supplier).getId());
            link("supplierName", "supplier.supplierName");
        }
    }

    public static class 商品修改请求 extends Spec<ProductUpdateRequest> {
        @Override
        public void main() {
            property("lengthUnit").value(1);
            property("volumeUnit").value(0);
            property("weightUnit").value(1);
            property("detailList[]").apply("商品规格请求");
        }

        @Trait
        public void 依赖已存在的() {
            property("category").is(Categories.商品类别.class);
            property("categoryId").dependsOn("category", (category) -> ((Category) category).getId());
            link("categoryName", "category.categoryName");

            property("supplier").is(Suppliers.供应商.class);
            property("supplierId").dependsOn("supplier", (supplier) -> ((Supplier) supplier).getId());
            link("supplierName", "supplier.supplierName");
        }
    }

    public static class 商品导入请求 extends Spec<ProductImportRequest> {
        @Override
        public void main() {
            property("lengthUnit").value(1);
            property("volumeUnit").value(0);
            property("weightUnit").value(1);
        }
    }

    public static class 安全库存修改请求 extends Spec<SkuSafetyStockPutRequest> {
    }

    public static class 商品规格请求 extends Spec<ProductDetailRequest> {
        @Override
        public void main() {
            property("unit").value("EA");
        }
    }

    @Getter
    @Setter
    public static class ProductQueryRequest {
        private int pageIndex;
        private int pageSize;
        private String sqlTitle;
        @JsonInclude(JsonInclude.Include.NON_NULL)
        private List<SearchObject> searchObjects = new ArrayList<>();

        @Getter
        @Setter
        public static class SearchObject {
            private String name;
            private String text;
            private String value;
            private int operator;
        }
    }

    @Getter
    @Setter
    public static class ProductCreateRequest {
        @JsonProperty("spu_code")
        private String spuCode;

        @JsonProperty("spu_name")
        private String spuName;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        @JsonProperty("category_id")
        private Integer categoryId;

        @JsonProperty("category_name")
        private String categoryName;

        @JsonIgnore
        private Category category;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        @JsonProperty("spu_description")
        private String spuDescription;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        @JsonProperty("supplier_id")
        private Integer supplierId;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        @JsonProperty("supplier_name")
        private String supplierName;

        @JsonIgnore
        private Supplier supplier;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        private String brand;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        private String origin;

        @JsonProperty("length_unit")
        private Integer lengthUnit;

        @JsonProperty("volume_unit")
        private Integer volumeUnit;

        @JsonProperty("weight_unit")
        private Integer weightUnit;

        private List<ProductDetailRequest> detailList = new ArrayList<>();
    }

    @Getter
    @Setter
    public static class ProductUpdateRequest extends ProductCreateRequest {
        private int id;
    }

    @Getter
    @Setter
    public static class ProductImportRequest {
        @JsonProperty("spu_code")
        private String spuCode;

        @JsonProperty("spu_name")
        private String spuName;

        @JsonProperty("category_name")
        private String categoryName;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        @JsonProperty("spu_description")
        private String spuDescription;

        @JsonProperty("supplier_name")
        private String supplierName;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        private String brand;

        @JsonProperty("length_unit")
        private Integer lengthUnit;

        @JsonProperty("volume_unit")
        private Integer volumeUnit;

        @JsonProperty("weight_unit")
        private Integer weightUnit;

        private List<ProductDetailRequest> detailList = new ArrayList<>();
    }

    @Getter
    @Setter
    public static class ProductDetailRequest {
        private int id;

        @JsonProperty("sku_code")
        private String skuCode;

        @JsonProperty("sku_name")
        private String skuName;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        @JsonProperty("bar_code")
        private String barCode;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        @JsonProperty("image_url")
        private String imageUrl;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        private BigDecimal weight;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        private BigDecimal lenght;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        private BigDecimal width;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        private BigDecimal height;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        private BigDecimal volume;

        private String unit;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        private BigDecimal cost;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        private BigDecimal price;

        private List<SkuSafetyStockRequest> detailList = new ArrayList<>();
    }

    @Getter
    @Setter
    public static class SkuSafetyStockPutRequest {
        @JsonProperty("sku_id")
        private Integer skuId;

        private List<SkuSafetyStockRequest> detailList = new ArrayList<>();
    }

    @Getter
    @Setter
    public static class SkuSafetyStockRequest {
        private int id;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        @JsonProperty("sku_id")
        private Integer skuId;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        @JsonProperty("warehouse_id")
        private Integer warehouseId;

        @JsonInclude(JsonInclude.Include.NON_NULL)
        @JsonProperty("warehouse_name")
        private String warehouseName;

        @JsonProperty("safety_stock_qty")
        private Integer safetyStockQty;
    }
}
