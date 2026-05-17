package org.testcharm.spec;

import com.github.leeonky.jfactory.Spec;
import org.testcharm.entity.UserRole;
import org.testcharm.entity.WmsUser;

public class Users {

    public static class 用户 extends Spec<WmsUser> {
        @Override
        public void main() {
            property("id").ignore();
            property("role").is(用户角色.class);
        }
    }

    public static class 用户角色 extends Spec<UserRole> {
        @Override
        public void main() {
            property("id").ignore();
        }
    }
}
