package org.testcharmtraining.entity;

import lombok.Getter;
import lombok.Setter;
import lombok.experimental.Accessors;

import javax.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Accessors(chain = true)
@Table(name = "userrole")
public class UserRole implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "role_name")
    private String roleName;
    @Column(name = "is_valid")
    private boolean valid;
    private LocalDateTime createTime;
    private LocalDateTime lastUpdateTime;
    @Column(name = "tenant_id")
    private long tenantId;

    @OneToMany(mappedBy = "role", cascade = CascadeType.ALL)
    private List<WmsUser> users = new ArrayList<>();
}
