import React from "react";
import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import FileUploadForm from "./components/FileUploadForm";
import FileLookupPage from "./components/FileLookupPage";

function App() {
  return (
    <Router>
      <div className="min-h-screen bg-blue-50 flex flex-col items-center px-4 py-10">
        <h1 className="text-3xl font-bold text-blue-700 mb-6 text-center">
          📁 <span>File Upload Platform</span>
        </h1>

        <div className="flex space-x-4 mb-8">
          <Link
            to="/upload"
            className="bg-blue-600 text-white px-5 py-2 rounded shadow hover:bg-blue-700 transition"
          >
            Upload File
          </Link>
          <Link
            to="/lookup"
            className="bg-green-600 text-white px-5 py-2 rounded shadow hover:bg-green-700 transition"
          >
            View Files
          </Link>
        </div>

        <div className="w-full max-w-3xl">
          <Routes>
            <Route path="/upload" element={<FileUploadForm />} />
            <Route path="/lookup" element={<FileLookupPage />} />
            <Route path="*" element={<FileUploadForm />} />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;
