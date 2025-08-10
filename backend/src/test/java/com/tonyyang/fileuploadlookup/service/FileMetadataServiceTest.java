package com.tonyyang.fileuploadlookup.service;

import com.tonyyang.fileuploadlookup.model.FileMetadata;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.test.util.ReflectionTestUtils;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.ScanRequest;
import software.amazon.awssdk.services.dynamodb.model.ScanResponse;
import software.amazon.awssdk.services.s3.S3Client;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

class FileMetadataServiceTest {

    @Test
    @DisplayName("listFiles should map DynamoDB items to FileMetadata list")
    void listFiles_mapsItems() {
        DynamoDbClient dynamoDbClient = Mockito.mock(DynamoDbClient.class);
        S3Client s3Client = Mockito.mock(S3Client.class);

        Map<String, AttributeValue> item1 = new HashMap<>();
        item1.put("filename", AttributeValue.fromS("a.txt"));
        item1.put("uploadTime", AttributeValue.fromS("2024-01-01T00:00:00Z"));
        item1.put("s3Url", AttributeValue.fromS("https://bucket/uploads/a.txt"));
        item1.put("size", AttributeValue.fromN("10"));

        Map<String, AttributeValue> item2 = new HashMap<>();
        item2.put("filename", AttributeValue.fromS("b.txt"));
        item2.put("uploadTime", AttributeValue.fromS("2024-01-02T00:00:00Z"));
        item2.put("s3Url", AttributeValue.fromS("https://bucket/uploads/b.txt"));
        item2.put("size", AttributeValue.fromN("20"));

        ScanResponse scanResponse = ScanResponse.builder()
                .items(Arrays.asList(item1, item2))
                .build();

        when(dynamoDbClient.scan(any(ScanRequest.class))).thenReturn(scanResponse);

        FileMetadataService service = new FileMetadataService(dynamoDbClient, s3Client);
        // set private config fields
        ReflectionTestUtils.setField(service, "tableName", "FileMetadata");
        ReflectionTestUtils.setField(service, "bucketName", "bucket");

        List<FileMetadata> files = service.listFiles();
        assertEquals(2, files.size());
        assertEquals("a.txt", files.get(0).getFilename());
        assertEquals(10, files.get(0).getSize());
        assertEquals("b.txt", files.get(1).getFilename());
        assertEquals(20, files.get(1).getSize());
    }
}