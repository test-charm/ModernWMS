package org.testcharmtraining.entity;

import lombok.Getter;
import lombok.Setter;
import lombok.experimental.Accessors;

import javax.persistence.*;
import java.io.Serializable;

@Getter
@Setter
@Entity
@Accessors(chain = true)
@Table(name = "sku_safety_stock")
public class SkuSafetyStock implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    private Sku sku;

    @ManyToOne
    private Warehouse warehouse;

    @Column(name = "safety_stock_qty")
    private int safetyStockQty;
}
