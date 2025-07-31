package com.tonyyang.fileuploadlookup.model;
import lombok.Data;


@Data
public class FileMetadata {

    private String filename; //文件名称（用户上传的）
    private String uploadTime; //上传时间戳（前端传ISO格式）
    private String s3Url; //文件在 S3 上的地址
    private long size;

    // Getters and Setters
    public String getFilename() { return filename; }
    public void setFilename(String filename) { this.filename = filename; }

    public String getUploadTime() { return uploadTime; }
    public void setUploadTime(String uploadTime) { this.uploadTime = uploadTime; }

    public String getS3Url() { return s3Url; }
    public void setS3Url(String s3Url) { this.s3Url = s3Url; }

    public long getSize() { return size; }
    public void setSize(long size) { this.size = size; }

}
