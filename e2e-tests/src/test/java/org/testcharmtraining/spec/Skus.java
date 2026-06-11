package org.testcharmtraining.spec;

import org.testcharm.jfactory.Spec;
import org.testcharmtraining.entity.Sku;
import org.testcharmtraining.entity.SkuSafetyStock;

public class Skus {
    public static class 规格 extends Spec<Sku> {
        @Override
        public void main() {
            property("spu").is(Spus.商品.class);
            property("skuSafetyStocks").reverseAssociation("sku");
        }
    }

    public static class 规格安全库存 extends Spec<SkuSafetyStock> {
        @Override
        public void main() {
            property("sku").is(规格.class);
            property("warehouse").is(Warehouses.仓库.class);
            property("safetyStockQty").defaultValue(0);
        }
    }
}
