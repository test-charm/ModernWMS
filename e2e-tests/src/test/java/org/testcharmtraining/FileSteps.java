package org.testcharmtraining;

import io.cucumber.java.Before;
import io.cucumber.java.zh_cn.那么;
import org.springframework.beans.factory.annotation.Autowired;
import org.testcharm.io.TempDirectory;

import static org.testcharm.dal.Assertions.expect;

public class FileSteps {

    @Autowired
    private TempDirectory backendWwwroot;

    @Before
    public void cleanBackendWwwroot() {
        backendWwwroot.clean();
    }

    @那么("会生成如下文件:")
    public void 会生成如下文件(String expression) {
        expect(backendWwwroot.root()).should(expression);
    }
}
