#!/bin/bash

# 简化的 macOSecho ""
echo "🚀 证书设置完成，继续构建应用..."
echo "📱 用户安装时需要右键点击应用选择'打开'"名证书设置
echo "🔧 创建自签名证书用于代码签名..."

# 证书名称
CERT_NAME="Developer ID Application"

# 检查证书是否已存在
if security find-certificate -c "$CERT_NAME" > /dev/null 2>&1; then
    echo "✅ 证书 '$CERT_NAME' 已存在，跳过创建"
else
    echo "� 创建新的自签名证书..."
    
    # 创建自签名证书
    security create-certificate \
        -c "$CERT_NAME" \
        -a "DigitalSignature,CodeSigning" \
        -p codesigning \
        -k "login.keychain"
    
    echo "✅ 证书创建完成"
fi

echo ""
echo "� 现在可以运行: npm run build:mac"
echo "📱 用户安装时需要右键点击应用选择'打开'"
