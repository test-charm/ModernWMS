package org.testcharmtraining.entity;

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
@Table(name = "category")
public class Category implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "category_name")
    private String categoryName;

    @Column(name = "parent_id")
    private int parentId;

    private String creator;
    private Instant createTime;
    private Instant lastUpdateTime;

    @Column(name = "is_valid")
    private boolean valid;

    @Column(name = "tenant_id")
    private long tenantId;
}
