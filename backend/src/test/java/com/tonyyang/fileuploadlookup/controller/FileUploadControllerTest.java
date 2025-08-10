package com.tonyyang.fileuploadlookup.controller;

import com.tonyyang.fileuploadlookup.model.FileMetadata;
import com.tonyyang.fileuploadlookup.service.FileMetadataService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(FileUploadController.class)
class FileUploadControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private FileMetadataService fileMetadataService;

    @Test
    @DisplayName("GET /api/files should return list of files")
    void listFiles_shouldReturnFiles() throws Exception {
        FileMetadata a = new FileMetadata();
        a.setFilename("a.txt");
        a.setUploadTime("2024-01-01T00:00:00Z");
        a.setS3Url("https://bucket.s3.amazonaws.com/uploads/a.txt");
        a.setSize(10);

        FileMetadata b = new FileMetadata();
        b.setFilename("b.txt");
        b.setUploadTime("2024-01-02T00:00:00Z");
        b.setS3Url("https://bucket.s3.amazonaws.com/uploads/b.txt");
        b.setSize(20);

        List<FileMetadata> list = Arrays.asList(a, b);
        when(fileMetadataService.listFiles()).thenReturn(list);

        mockMvc.perform(get("/api/files").accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$[0].filename").value("a.txt"))
                .andExpect(jsonPath("$[1].filename").value("b.txt"));
    }

    @Test
    @DisplayName("POST /api/files/upload should accept multipart and return success message")
    void uploadFile_shouldSucceed() throws Exception {
        MockMultipartFile file = new MockMultipartFile(
                "file", "test.txt", MediaType.TEXT_PLAIN_VALUE, "hello".getBytes());

        doNothing().when(fileMetadataService).handleUpload(any());

        mockMvc.perform(multipart("/api/files/upload").file(file))
                .andExpect(status().isOk())
                .andExpect(content().string("File uploaded to S3 and metadata saved on DynamoDB"));
    }

    @Test
    @DisplayName("DELETE /api/files/delete/{filename} should return ok")
    void deleteFile_shouldSucceed() throws Exception {
        doNothing().when(fileMetadataService).deleteFile("test.txt");

        mockMvc.perform(delete("/api/files/delete/{filename}", "test.txt"))
                .andExpect(status().isOk())
                .andExpect(content().string("File deleted successfully."));
    }
}