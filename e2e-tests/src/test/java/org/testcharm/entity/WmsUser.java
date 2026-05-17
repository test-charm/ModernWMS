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
@Table(name = "user")
public class WmsUser {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String userNum;
    private String userName;
    private String contactTel;
    private String userRole;
    private String sex;
    @Column(name = "is_valid")
    private boolean valid;
    private String authString;
    private String email;
    private String creator;
    private LocalDateTime createTime;
    private LocalDateTime lastUpdateTime;
    private long tenantId;
}
