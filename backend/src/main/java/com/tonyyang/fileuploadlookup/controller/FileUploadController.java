package com.tonyyang.fileuploadlookup.controller;

import com.tonyyang.fileuploadlookup.model.FileMetadata;
import com.tonyyang.fileuploadlookup.service.FileMetadataService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

import org.springframework.http.MediaType;

@RestController
@RequestMapping("/api/files") //定义所有接口以 /api/files 开头
@CrossOrigin // 允许跨域访问，方便前端调试
public class FileUploadController {

    private final FileMetadataService fileMetadataService;

    public FileUploadController(FileMetadataService fileMetadataService) {
        this.fileMetadataService = fileMetadataService;
    }

    //上传元数据接口（前端通过 JSON 发 metadata）
    @PostMapping(value = "/upload", consumes = "multipart/form-data")
    public ResponseEntity<String> uploadFile(@RequestParam("file") MultipartFile file) {
        try {
            fileMetadataService.handleUpload(file);
            return ResponseEntity.ok("File uploaded to S3 and metadata saved on DynamoDB");

        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to upload file:" + e.getMessage());
        }
    }

    @GetMapping("/")//Health Check
    public String healthCheck() {
        return "OK";
    }

    @DeleteMapping("/delete/{filename}")
    public ResponseEntity<String> deleteFile(@PathVariable String filename) {
        try {
            fileMetadataService.deleteFile(filename);
            return ResponseEntity.ok("File deleted successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Delete failed: " + e.getMessage());
        }
    }





}
