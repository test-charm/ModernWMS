package org.testcharm;

import com.github.leeonky.cucumber.restful.RestfulStep;
import com.github.leeonky.dal.Assertions;
import com.github.leeonky.jfactory.JFactory;
import com.github.leeonky.util.Sneaky;
import io.cucumber.java.Before;
import io.cucumber.spring.CucumberContextConfiguration;
import lombok.SneakyThrows;
import org.hibernate.Session;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootContextLoader;
import org.springframework.test.context.ContextConfiguration;

import javax.annotation.PostConstruct;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.PersistenceUnit;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Consumer;

@ContextConfiguration(classes = {CucumberConfiguration.class}, loader = SpringBootContextLoader.class)
@CucumberContextConfiguration
public class ApplicationSteps {

    @Autowired
    private JFactory jFactory;

    @PersistenceUnit
    private EntityManagerFactory entityManagerFactory;

    @Value("${testcharm.dal.dumpinput:true}")
    private boolean dalDumpInput;

    @Value("${testcharm.api.base-url}")
    private String baseUrl;

    @Value("${testcharm.api.login.user-name}")
    private String loginUserName;

    @Value("${testcharm.api.login.password}")
    private String loginPassword;

    @Before
    public void disableDALDump() {
        Assertions.dumpInput(dalDumpInput);
    }

    private void cleanLoginTestData() {
        executeDB(entityManager -> entityManager.unwrap(Session.class).doWork(connection -> Sneaky.run(() -> {
            try (Statement stmt = connection.createStatement()) {
                stmt.execute("SET FOREIGN_KEY_CHECKS=0");
                stmt.executeUpdate("DELETE FROM `user` WHERE `tenant_id` = " + TestConstants.LOGIN_TENANT_ID);
                stmt.executeUpdate("DELETE FROM `userrole` WHERE `tenant_id` = " + TestConstants.LOGIN_TENANT_ID);
                stmt.execute("SET FOREIGN_KEY_CHECKS=1");
            }
        })));
    }

    private void executeDB(Consumer<EntityManager> consumer) {
        EntityManager manager = entityManagerFactory.createEntityManager();
        EntityTransaction transaction = manager.getTransaction();
        transaction.begin();
        consumer.accept(manager);
        transaction.commit();
        manager.close();
    }

    @Before(order = 0)
    public void clearDB() {
        jFactory.getDataRepository().clear();
        cleanLoginTestData();
    }

    @Autowired
    private RestfulStep restfulStep;

    @PostConstruct
    public void setBaseUrl() {
        restfulStep.setBaseUrl(baseUrl);
    }

    @SneakyThrows
    @Before("@api-login")
    public void apiLogin() {
        jFactory.spec("用户")
                .property("userName", loginUserName)
                .property("authString", TestConstants.md5(loginPassword))
                .create();

        Map<String, String> loginRequest = new HashMap<>();
        loginRequest.put("user_name", loginUserName);
        loginRequest.put("password", loginPassword);

        RestfulStep loginRestfulStep = new RestfulStep();
        loginRestfulStep.setBaseUrl(baseUrl);
        loginRestfulStep.post("/login", loginRequest);
        restfulStep.header("Authorization", "Bearer " + loginRestfulStep.response("body.json.data.access_token"));
    }

}
