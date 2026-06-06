package org.testcharm.entity;

import lombok.Getter;
import lombok.Setter;
import lombok.experimental.Accessors;

import javax.persistence.*;
import java.io.Serializable;
import java.time.Instant;

@Getter
@Setter
@Entity
@Accessors(chain = true)
@Table(name = "supplier")
public class Supplier implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "supplier_name")
    private String supplierName;
    private String city;
    private String address;
    private String email;
    private String manager;
    @Column(name = "contact_tel")
    private String contactTel;
    private String creator;
    private Instant createTime;
    private Instant lastUpdateTime;
    @Column(name = "is_valid")
    private boolean valid;
    @Column(name = "tenant_id")
    private long tenantId;
}
