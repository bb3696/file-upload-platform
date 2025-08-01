import React, { useState } from "react"; 
import axios from 'axios'; // a popular HTTP client for making requests

const styles = {
  form: "bg-white shadow-lg rounded-lg px-8 py-6 w-full space-y-4",
  input: "border border-gray-300 p-2 rounded w-full text-sm",
  button:
    "bg-blue-500 text-white font-semibold rounded py-2 px-4 hover:bg-blue-600 w-full",
  success: "text-green-500 text-center",
  error: "text-red-500 text-center",
};

const FileUploadForm = () => {

    const [file, setFile] = useState(null);
    const [status, setStatus] = useState(""); // State to manage upload status 
    const [message, setMessage] = useState("");


    const handleSubmit = async (e) => { // Handle form submission
        e.preventDefault();
        if (!file) return;

        const formData = new FormData();
        formData.append("file", file);

        try {
            const response = await axios.post(
                'https://1qcshbwwya.execute-api.us-east-1.amazonaws.com/api/files/upload', 
                formData, 
                {
                    headers: {"Content-Type": "multipart/form-data",},
                }
            );
            setStatus("success");
            setMessage(response.data);
        } catch (error) {
            console.error('Error uploading file:', error);
            setStatus("error");
            setMessage(error.response?.data || "Unknown error");
            // Optionally, you can reset the file input or provide further feedback to the user
        }
    };

    return (
        <form onSubmit={handleSubmit} className={styles.form}>
            <input
                type="file"
                onChange={(e) => setFile(e.target.files[0])} // Update state
                required // Ensure a file is selected
                className={styles.input}
            />
            <button type="submit" className={styles.button}>Upload File</button>
            {status === "success" && <p className={styles.success}>{message}</p>}
            {status === "error" && <p className={styles.error}>{message}</p>}  
        </form>
    );
};  

export default FileUploadForm; // Export the component for use in other parts of the application