package org.testcharmtraining.entity;

import lombok.Getter;
import lombok.Setter;
import lombok.experimental.Accessors;

import javax.persistence.*;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

@Getter
@Setter
@Entity
@Accessors(chain = true)
@Table(name = "sku")
public class Sku implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    private Spu spu;

    @Column(name = "sku_code")
    private String skuCode;

    @Column(name = "sku_name")
    private String skuName;

    @Column(name = "bar_code")
    private String barCode;

    @Column(name = "image_url")
    private String imageUrl;

    private BigDecimal weight;

    @Column(name = "lenght")
    private BigDecimal lenght;

    private BigDecimal width;
    private BigDecimal height;
    private BigDecimal volume;
    private String unit;
    private BigDecimal cost;
    private BigDecimal price;
    private Instant createTime;
    private Instant lastUpdateTime;

    @OneToMany(mappedBy = "sku")
    private List<SkuSafetyStock> skuSafetyStocks;
}
