package org.testcharm.entity;

import lombok.Getter;
import lombok.Setter;
import lombok.experimental.Accessors;

import javax.persistence.*;
import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Accessors(chain = true)
@Table(name = "userrole")
public class UserRole {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String roleName;
    @Column(name = "is_valid")
    private boolean valid;
    private LocalDateTime createTime;
    private LocalDateTime lastUpdateTime;
    private long tenantId;
}
