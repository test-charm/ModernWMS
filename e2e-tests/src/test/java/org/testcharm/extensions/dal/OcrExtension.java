package org.testcharm.extensions.dal;

import lombok.SneakyThrows;
import org.testcharm.cucumber.restful.RestfulStep;
import org.testcharm.dal.DAL;
import org.testcharm.dal.runtime.Extension;
import org.testcharm.jfactory.JFactory;

import java.io.File;
import java.nio.file.Files;

public class OcrExtension implements Extension {
    @Override
    public void extend(DAL dal) {
        dal.getRuntimeContextBuilder().registerStaticMethodExtension(OcrExtension.class);
    }

    @SneakyThrows
    public static String ocr(File file) {
        return ocr(Files.readAllBytes(file.toPath()));
    }

    @SneakyThrows
    public static String ocr(byte[] data) {
        var restfulStep = new RestfulStep();
        restfulStep.header("Accept", "application/json");
        restfulStep.file("image", RestfulStep.UploadFile.content(data));
        restfulStep.setJFactory(new JFactory());
        restfulStep.postForm("http://ocr.tool.net:58884/tesseract", """
                {
                    options: '{"languages": ["eng"]}'
                    @file: image
                }
                """);
        return restfulStep.response("body.json.data.stdout.trim");
    }
}
