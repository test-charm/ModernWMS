package org.testcharmtraining.spec;

import org.testcharm.jfactory.Spec;
import org.testcharmtraining.DALMockServer;

public class ResponseBuilders {
    public static class DefaultResponseBuilder extends Spec<DALMockServer.ResponseBuilder> {
        @Override
        public void main() {
            property("code").value(200);
            property("times").value(0);
            property("delayResponse").value(0);
        }
    }
}
