package com.tonyyang.fileuploadlookup.service;
// 创建 Service 类：把 FileMetadata 写入 DynamoDB。

import com.tonyyang.fileuploadlookup.model.FileMetadata; //引入你刚创建的模型类存入DynamoDB
import org.springframework.stereotype.Service; //用于标记这个类为 Spring 的 Service 组件，会被自动注册到 Spring 容器

// 从 AWS SDK v2 引入的类：
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient; //DynamoDB 客户端，用来发请求
import software.amazon.awssdk.services.dynamodb.model.AttributeValue; //表示 DynamoDB 中的字段值
import software.amazon.awssdk.services.dynamodb.model.PutItemRequest; //表示要写入一个新 item 的请求

//S3
import software.amazon.awssdk.services.dynamodb.model.*;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

//Java 的 Map 用于构建 DynamoDB 中的一条记录（item）:
import java.io.IOException;
import java.util.*;


@Service // 表示这是一个业务逻辑类（service），会被 Spring Boot 自动注入和管理。
public class FileMetadataService {

    private final DynamoDbClient dynamoDbClient; // 用于和 DynamoDB 通信的客户端，设为成员变量以供整个类使用
    private final S3Client s3Client;

    public FileMetadataService(DynamoDbClient dynamoDbClient, S3Client s3Client) {
        this.dynamoDbClient = dynamoDbClient;
        this.s3Client = s3Client;
    }

    public String uploadFileToS3(MultipartFile file) throws IOException {

        String key = "uploads/" + file.getOriginalFilename();

        String bucketName = "tony-upload-bucket";
        PutObjectRequest putRequest = PutObjectRequest.builder()
                .bucket(bucketName)
                .key(key)
                .build();

        s3Client.putObject(putRequest, RequestBody.fromInputStream(file.getInputStream(), file.getSize()));

        return "https://" + bucketName + ".s3.amazonaws.com/" + key;
    }

    public void saveFileMetadata(FileMetadata metadata) {

        //创建一个键值对 Map，用来构建 DynamoDB 中的 item。DynamoDB 不接受普通的 Java 对象，而是接受 AttributeValue 类型的 map。
        Map<String,AttributeValue> item = new HashMap<>();

        // 把 Java 对象的属性转换为 DynamoDB 的字段：
        item.put("filename", AttributeValue.fromS(metadata.getFilename()));
        item.put("uploadTime", AttributeValue.fromS(metadata.getUploadTime()));
        item.put("s3Url", AttributeValue.fromS(metadata.getS3Url()));
        item.put("size", AttributeValue.fromN(Long.toString(metadata.getSize())));

        // 创建一个写入请求，指定表名和刚刚构建好的 item
        // 表示你要操作的 DynamoDB 表名。必须和 AWS 控制台创建的表名一致。
        String tableName = "FileMetadata";
        PutItemRequest request =  PutItemRequest.builder()
                .tableName(tableName)
                .item(item)
                .build();

        dynamoDbClient.putItem(request); //最终执行写入 DynamoDB 的操作。如果成功，将数据写入表中。
    }

    public void handleUpload(MultipartFile file) throws IOException {
        String s3Url = uploadFileToS3(file);

        FileMetadata metadata = new FileMetadata();
        metadata.setFilename(file.getOriginalFilename());
        metadata.setUploadTime(java.time.Instant.now().toString());
        metadata.setS3Url(s3Url);
        metadata.setSize(file.getSize());

        saveFileMetadata(metadata);
    }

    public void deleteFile(String filename) {
        // 1. 删除 S3 对象
        s3Client.deleteObject(DeleteObjectRequest.builder()
                .bucket("tony-upload-bucket")
                .key("uploads/" + filename)
                .build());

        // 2. 删除 DynamoDB 记录
        Map<String, AttributeValue> key = new HashMap<>();
        key.put("filename", AttributeValue.fromS(filename));

        dynamoDbClient.deleteItem(DeleteItemRequest.builder()
                .tableName("FileMetadata")
                .key(key)
                .build());
    }
}

