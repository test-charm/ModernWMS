package org.testcharmtraining.entity;

import lombok.Getter;
import lombok.Setter;
import lombok.experimental.Accessors;

import javax.persistence.*;
import java.io.Serializable;
import java.time.Instant;
import java.util.List;

@Getter
@Setter
@Entity
@Accessors(chain = true)
@Table(name = "spu")
public class Spu implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "spu_code")
    private String spuCode;

    @Column(name = "spu_name")
    private String spuName;

    @ManyToOne
    private Category category;

    @Column(name = "spu_description")
    private String spuDescription;

//    @Column(name = "supplier_id")
//    private int supplierId;

    @ManyToOne
    private Supplier supplier;

    @Column(name = "supplier_name")
    private String supplierName;

    private String brand;
    private String origin;

    @Column(name = "length_unit")
    private byte lengthUnit;

    @Column(name = "volume_unit")
    private byte volumeUnit;

    @Column(name = "weight_unit")
    private byte weightUnit;

    private String creator;
    private Instant createTime;
    private Instant lastUpdateTime;

    @Column(name = "is_valid")
    private boolean valid;

    @Column(name = "tenant_id")
    private long tenantId;

    @OneToMany(mappedBy = "spu")
    private List<Sku> skus;

}
