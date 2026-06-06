package org.testcharmtraining.spec;

import org.testcharm.jfactory.Spec;
import org.testcharmtraining.entity.UserRole;
import org.testcharmtraining.entity.WmsUser;

public class Users {

    public static class 用户 extends Spec<WmsUser> {
        @Override
        public void main() {
            property("role").is(用户角色.class);
        }
    }

    public static class 用户角色 extends Spec<UserRole> {
    }
}
