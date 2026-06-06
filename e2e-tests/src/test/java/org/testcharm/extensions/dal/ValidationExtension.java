package org.testcharm.extensions.dal;

import org.testcharm.dal.DAL;
import org.testcharm.dal.ast.opt.DALOperator;
import org.testcharm.dal.runtime.*;

import java.util.Collections;

public class ValidationExtension implements Extension {
    @Override
    public void extend(DAL dal) {
        dal.getRuntimeContextBuilder().registerOperator(Operators.MUL, new Operation<Object, Object>() {
            @Override
            public boolean match(Data<?> v1, DALOperator operator, Data<?> v2, RuntimeContextBuilder.DALRuntimeContext context) {
                return v1.instanceOf(String.class) && v2.instanceOf(Integer.class);
            }

            @Override
            public Object operate(Data<Object> v1, DALOperator operator, Data<Object> v2, RuntimeContextBuilder.DALRuntimeContext context) {
                return String.join("", Collections.nCopies((int) v2.value(), (String) v1.value()));
            }
        });
    }
}
