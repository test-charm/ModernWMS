package org.testcharm.entity;

import lombok.Data;
import lombok.experimental.Accessors;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import java.time.LocalDateTime;

@Data
@Entity
@Accessors(chain = true)
@Table(name = "user")
public class WmsUser {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String user_num;
    private String user_name;
    private String contact_tel;
    private String user_role;
    private String sex;
    @Column(name = "is_valid")
    private boolean valid;
    private String auth_string;
    private String email;
    private String creator;
    private LocalDateTime create_time;
    private LocalDateTime last_update_time;
    private long tenant_id;
}
