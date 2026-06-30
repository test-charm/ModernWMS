package org.testcharmtraining;

import lombok.SneakyThrows;
import org.mockserver.client.MockServerClient;
import org.mockserver.model.HttpRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.testcharm.io.TempDirectory;
import org.testcharm.jfactory.CompositeDataRepository;
import org.testcharm.jfactory.DataRepository;
import org.testcharm.jfactory.JFactory;
import org.testcharm.jfactory.MemoryDataRepository;
import org.testcharm.jfactory.repo.JPADataRepository;
import org.testcharmtraining.dto.TextImageFile;

import javax.persistence.EntityManagerFactory;
import javax.persistence.PersistenceUnit;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
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
    public JFactory factorySet(DALMockServer dalMockServer, TempDirectory backendWwwroot) {
        return new EntityFactory(
                new CompositeDataRepository(new MemoryDataRepository())
                        .registerByPackage("org.testcharmtraining.entity", new JPADataRepository(entityManagerFactory.createEntityManager()))
                        .registerByType(HttpRequest.class, new MockServerDataRepository(dalMockServer))
                        .registerByType(TextImageFile.class, new TextImageFileDataRepository(backendWwwroot))
        );
    }

    @Bean
    public TempDirectory backendWwwroot() {
        return new TempDirectory(Path.of("/tmp/atdd-v2/wwwroot"));
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

    public static class TextImageFileDataRepository extends MemoryDataRepository {
        private final TempDirectory backendWwwroot;

        public TextImageFileDataRepository(TempDirectory backendWwwroot) {
            this.backendWwwroot = backendWwwroot;
        }

        @SneakyThrows
        @Override
        public void save(Object object) {
            super.save(object);
            var file = (TextImageFile) object;
            Files.createDirectory(backendWwwroot.root().resolve("sku_images"));
            backendWwwroot.write(Path.of("sku_images", file.getName()).toString(), file.getContent().getBytes());
        }
    }
}
