package org.testcharm.spec;

import com.github.leeonky.jfactory.Spec;
import org.testcharm.TestConstants;
import org.testcharm.entity.UserRole;
import org.testcharm.entity.WmsUser;

import java.time.LocalDateTime;

public class Users {

    private static final LocalDateTime DEFAULT_TIME = LocalDateTime.of(2024, 1, 1, 0, 0);

    public static class 用户 extends Spec<WmsUser> {
        @Override
        public void main() {
            property("id").ignore();
            property("user_num").dependsOn("user_name", value -> value);
            property("contact_tel").value("13000000000");
            property("user_role").value(TestConstants.LOGIN_ROLE_NAME);
            property("sex").value("male");
            property("valid").value(true);
            property("creator").value(TestConstants.TEST_CREATOR);
            property("create_time").value(DEFAULT_TIME);
            property("last_update_time").value(DEFAULT_TIME);
            property("tenant_id").value(TestConstants.LOGIN_TENANT_ID);
            property("email").value("");
        }
    }

    public static class 用户角色 extends Spec<UserRole> {
        @Override
        public void main() {
            property("id").ignore();
            property("role_name").value(TestConstants.LOGIN_ROLE_NAME);
            property("valid").value(true);
            property("create_time").value(DEFAULT_TIME);
            property("last_update_time").value(DEFAULT_TIME);
            property("tenant_id").value(TestConstants.LOGIN_TENANT_ID);
        }
    }
}
