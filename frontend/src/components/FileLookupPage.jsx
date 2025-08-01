import React, { useEffect, useState } from "react";
import axios from "axios";
import dayjs from "dayjs";

const styles = {
  container: "bg-white shadow-lg rounded-lg p-6 space-y-4 w-full max-w-3xl mx-auto mt-10",
  title: "text-xl font-bold text-center",
  item: "border p-4 rounded bg-gray-50 space-y-1 text-sm",
  link: "text-blue-500 underline"
};

const formatBytes = (bytes) => {
  if (bytes === 0) return "0 B";
  const k = 1024;
  const sizes = ["B", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
};

const FileLookupPage = () => {
  const [files, setFiles] = useState([]);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchFiles = async () => {
      try {
        const res = await axios.get("https://1qcshbwwya.execute-api.us-east-1.amazonaws.com/api/files/lookup");
        const sorted = [...res.data].sort(
        (a, b) => new Date(b.uploadTime) - new Date(a.uploadTime) // 最新在上
      );
      setFiles(sorted);
      } catch (err) {
        console.error("Fetch error:", err);
        setError("Failed to fetch file list.");
      }
    };
    fetchFiles();
  }, []);

  //删除
  const handleDelete = async (filename) => {
  if (!window.confirm(`Are you sure you want to delete ${filename}?`)) return;

  try {
    await axios.delete(`https://1qcshbwwya.execute-api.us-east-1.amazonaws.com/api/files/delete/${filename}`);
    setFiles(prev => prev.filter(f => f.filename !== filename)); // 更新前端列表
  } catch (err) {
    console.error("Delete failed:", err);
    alert("Failed to delete file.");
  } 
};

  return (
    <div className={styles.container}>
      <h2 className={styles.title}>📄 Uploaded Files</h2>
      {error && <p className="text-red-500 text-center">{error}</p>}
      {files.length === 0 ? (
        <p className="text-center text-gray-500">No files found.</p>
      ) : (
        files.map((file, index) => (
          <div key={index} className={styles.item}>
            <p><strong>Filename:</strong> {file.filename}</p>
            <p><strong>Upload Time:</strong> {dayjs(file.uploadTime).format("YYYY-MM-DD HH:mm:ss")}</p>
            <p>
              <a href={file.s3Url} target="_blank" rel="noreferrer" className={styles.link}>
                Download / View
              </a>
            </p>
            <button
                onClick={() => handleDelete(file.filename)}
                className="text-red-500 hover:text-red-700 underline text-sm"
                >
                🗑 Delete
            </button>
            <p><strong>Size:</strong> {formatBytes(file.size)}</p>
          </div>
        ))
      )}
    </div>
  );
};

export default FileLookupPage;
