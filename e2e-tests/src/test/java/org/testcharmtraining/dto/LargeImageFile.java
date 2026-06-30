package org.testcharmtraining.dto;

import lombok.Getter;
import lombok.Setter;
import org.testcharm.io.VirtualFile;

@Getter
@Setter
public class LargeImageFile implements VirtualFile {

    private String name;

    @Override
    public byte[] binary() {
        return new byte[6 * 1024 * 1024];
    }
}
