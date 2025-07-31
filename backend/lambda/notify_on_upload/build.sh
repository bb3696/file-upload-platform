#!/bin/bash
echo "🔧 Running build script..."


# 切换到 Lambda 函数目录
cd "$(dirname "$0")"

echo "🛠️ Building notify_on_upload.zip..."
rm -f notify_on_upload.zip

# 打包 handler.py（不包括 .DS_Store 等隐藏文件）
zip -r notify_on_upload.zip handler.py > /dev/null

echo "✅ Done: notify_on_upload.zip created"
