#!/bin/bash

# 简化的 macOS 自签名证书设置
echo "🔧 创建自签名证书用于代码签名..."

# 证书名称
CERT_NAME="Developer ID Application"

# 检查证书是否已存在
if security find-certificate -c "$CERT_NAME" > /dev/null 2>&1; then
    echo "✅ 证书 '$CERT_NAME' 已存在，跳过创建"
else
    echo "📝 创建新的自签名证书..."
    
    # 创建临时配置文件
    cat > /tmp/cert.conf << EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
C = CN
ST = Shanghai
L = Shanghai
O = FNTV
OU = Development
CN = $CERT_NAME

[v3_req]
keyUsage = keyEncipherment, dataEncipherment, digitalSignature
extendedKeyUsage = codeSigning
EOF
    
    # 生成证书和私钥
    openssl req -x509 -newkey rsa:2048 -keyout /tmp/cert-key.pem -out /tmp/cert.pem -days 365 -nodes -config /tmp/cert.conf
    
    # 合并为 p12 格式
    openssl pkcs12 -export -out /tmp/cert.p12 -inkey /tmp/cert-key.pem -in /tmp/cert.pem -name "$CERT_NAME" -passout pass:
    
    # 导入到钥匙串
    security import /tmp/cert.p12 -k "login.keychain" -P "" -T /usr/bin/codesign -T /usr/bin/security
    
    # 设置证书信任
    security add-trusted-cert -d -r trustRoot -k "login.keychain" /tmp/cert.pem
    
    # 清理临时文件
    rm -f /tmp/cert.conf /tmp/cert-key.pem /tmp/cert.pem /tmp/cert.p12
    
    echo "✅ 证书创建完成"
fi

echo ""
echo "🚀 证书设置完成，继续构建应用..."
echo "📱 用户安装时需要右键点击应用选择'打开'"
