package org.testcharm.entity;

import lombok.Getter;
import lombok.Setter;
import lombok.experimental.Accessors;

import javax.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Accessors(chain = true)
@Table(name = "user")
public class WmsUser implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String userNum;
    private String userName;
    private String contactTel;
    private String sex;
    @Column(name = "is_valid")
    private boolean valid;
    private String authString;
    private String email;
    private String creator;
    private LocalDateTime createTime;
    private LocalDateTime lastUpdateTime;
    @Transient
    private String derivedUserRole;
    @Transient
    private long derivedTenantId;

    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumns({
            @JoinColumn(name = "user_role", referencedColumnName = "role_name", insertable = false, updatable = false),
            @JoinColumn(name = "tenant_id", referencedColumnName = "tenant_id", insertable = false, updatable = false)
    })
    private UserRole role;

    @Access(AccessType.PROPERTY)
    @Column(name = "user_role")
    public String getUserRole() {
        return role != null ? role.getRoleName() : derivedUserRole;
    }

    public void setUserRole(String userRole) {
        this.derivedUserRole = userRole;
    }

    @Access(AccessType.PROPERTY)
    @Column(name = "tenant_id")
    public long getTenantId() {
        return role != null ? role.getTenantId() : derivedTenantId;
    }

    public void setTenantId(long tenantId) {
        this.derivedTenantId = tenantId;
    }
}
