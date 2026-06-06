package org.testcharm.extensions.message;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.module.SimpleModule;
import org.testcharm.message.Format;
import org.testcharm.message.MessageConverterExtension;
import org.testcharm.message.MessageConverterRegistry;
import org.testcharm.util.Sneaky;

public class MessageConverter implements MessageConverterExtension {
    @Override
    public void extend(MessageConverterRegistry messageConverterRegistry) {
        ObjectMapper objectMapper = new ObjectMapper();
        SimpleModule module = new SimpleModule();
        objectMapper.registerModule(module);
        messageConverterRegistry.register("RESTful-Step", Format.json(), new org.testcharm.message.MessageConverter() {
            @Override
            public String serialize(Object o) {
                return Sneaky.get(() -> objectMapper.writeValueAsString(o));
            }

            @Override
            public Object deserialize(String s) {
                return Sneaky.get(() -> objectMapper.readValue(s, Object.class));
            }
        });
    }
}
