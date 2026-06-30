package org.testcharmtraining.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.SneakyThrows;
import org.testcharm.io.VirtualFile;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;

@Getter
@Setter
public class TextImageFile implements VirtualFile {

    private String name;
    private String content;

    @Override
    public String getName() {
        return name;
    }

    @SneakyThrows
    @Override
    public byte[] binary() {
        BufferedImage image = new BufferedImage(200, 100, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        g.setColor(Color.white);
        g.fillRect(0, 0, 200, 100);
        g.setColor(Color.BLACK);
        g.setFont(new Font("TimesRoman", Font.PLAIN, 40));
        g.drawString(content, 10, 50);
        var outputStream = new ByteArrayOutputStream();
        ImageIO.write(image, "png", outputStream);
        return outputStream.toByteArray();
    }
}
