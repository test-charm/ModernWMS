package org.testcharm;

import com.github.leeonky.jfactory.CompositeDataRepository;
import com.github.leeonky.jfactory.DataRepository;
import com.github.leeonky.jfactory.JFactory;
import com.github.leeonky.jfactory.MemoryDataRepository;
import com.github.leeonky.jfactory.repo.JPADataRepository;
import lombok.SneakyThrows;
import org.mockserver.client.MockServerClient;
import org.mockserver.model.HttpRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.persistence.EntityManagerFactory;
import javax.persistence.PersistenceUnit;
import java.net.URL;
import java.util.Collection;

@Configuration
public class Factories {

    @PersistenceUnit
    private EntityManagerFactory entityManagerFactory;

    @SneakyThrows
    @Bean
    public MockServerClient createMockServerClient(@Value("${mock-server.endpoint}") String endpoint) {
        URL url = new URL(endpoint);
        return new MockServerClient(url.getHost(), url.getPort()) {
            @Override
            public void close() {
            }
        };
    }

    @Bean
    public JFactory factorySet(DALMockServer dalMockServer) {
        return new EntityFactory(
                new CompositeDataRepository(new MemoryDataRepository())
                        .registerByPackage("org.testcharm.entity", new JPADataRepository(entityManagerFactory.createEntityManager()))
                        .registerByType(HttpRequest.class, new MockServerDataRepository(dalMockServer))
        );
    }

    public static class MockServerDataRepository implements DataRepository {
        private final DALMockServer dalMockServer;

        public MockServerDataRepository(DALMockServer dalMockServer) {
            this.dalMockServer = dalMockServer;
        }

        @Override
        public <T> Collection<T> queryAll(Class<T> type) {
            return (Collection<T>) dalMockServer.requests();
        }

        @Override
        public void clear() {

        }

        @Override
        public void save(Object object) {

        }
    }
}
