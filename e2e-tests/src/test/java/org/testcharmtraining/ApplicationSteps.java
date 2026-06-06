package org.testcharmtraining;

import io.cucumber.java.Before;
import io.cucumber.spring.CucumberContextConfiguration;
import lombok.SneakyThrows;
import org.hibernate.Session;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootContextLoader;
import org.springframework.test.context.ContextConfiguration;
import org.testcharm.cucumber.restful.RestfulStep;
import org.testcharm.dal.Assertions;
import org.testcharm.jfactory.JFactory;
import org.testcharm.util.Sneaky;

import javax.annotation.PostConstruct;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.PersistenceUnit;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Consumer;

import static org.testcharm.extensions.dal.TokenExtension.md5;

@ContextConfiguration(classes = {CucumberConfiguration.class}, loader = SpringBootContextLoader.class)
@CucumberContextConfiguration
public class ApplicationSteps {

    @Autowired
    private JFactory jFactory;

    @PersistenceUnit
    private EntityManagerFactory entityManagerFactory;

    @Value("${testcharm.dal.dumpinput:true}")
    private boolean dalDumpInput;

    private final String LOGIN_USERNAME = "e2e-login-hook-user";
    private final String LOGIN_PASSWORD = "hook-secret";

    @Before
    public void disableDALDump() {
        Assertions.dumpInput(dalDumpInput);
    }

    private void cleanLoginTestData() {
        executeDB(entityManager -> entityManager.unwrap(Session.class).doWork(connection -> Sneaky.run(() -> {
            try (Statement stmt = connection.createStatement()) {
                stmt.execute("SET FOREIGN_KEY_CHECKS=0");
                stmt.executeUpdate("DELETE FROM `supplier`");
                stmt.executeUpdate("DELETE FROM `user`");
                stmt.executeUpdate("DELETE FROM `userrole`");
                stmt.executeUpdate("ALTER TABLE `supplier` AUTO_INCREMENT = 1");
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
    public void initRestfulStep() {
        restfulStep.setBaseUrl("http://127.0.0.1:10085");
        restfulStep.setJFactory(jFactory);
    }

    @SneakyThrows
    @Before("@api-login-tenantId-9001")
    public void apiLogin() {
        jFactory.spec("用户")
                .property("userName", LOGIN_USERNAME)
                .property("authString", md5(LOGIN_PASSWORD))
                .property("role.tenantId", 9001L)
                .create();

        Map<String, String> loginRequest = new HashMap<>();
        loginRequest.put("user_name", LOGIN_USERNAME);
        loginRequest.put("password", LOGIN_PASSWORD);

        restfulStep.postObjectInJson("/login", loginRequest);
        restfulStep.header("Authorization", "Bearer " + restfulStep.response("body.json.data.access_token"));
    }

}
