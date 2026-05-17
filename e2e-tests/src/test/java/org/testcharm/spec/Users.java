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
            property("userNum").dependsOn("userName", value -> value);
            property("contactTel").value("13000000000");
            property("sex").value("male");
            property("valid").value(true);
            property("creator").value(TestConstants.TEST_CREATOR);
            property("createTime").value(DEFAULT_TIME);
            property("lastUpdateTime").value(DEFAULT_TIME);
            property("email").value("");
            property("role").is(用户角色.class);
        }
    }

    public static class 用户角色 extends Spec<UserRole> {
        @Override
        public void main() {
            property("id").ignore();
            property("valid").value(true);
            property("createTime").value(DEFAULT_TIME);
            property("lastUpdateTime").value(DEFAULT_TIME);
        }
    }
}
