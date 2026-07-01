#!/usr/bin/env bash
set -euo pipefail

############################################
# 固定绝对路径
############################################
ROOT="/root/Tools_ul/FreeKill"

PROJECT="$ROOT/FreeKill"
ANDROID="$ROOT/android"
QT="/root/Tools_ul/Qt/6.10.0"
QT_HOST="$QT/gcc_64"
QT_ANDROID="$QT/android_arm64_v8a"

OPENSSL_DIR="$ROOT/openssl-3.1.8"
LIBGIT2_DIR="$ROOT/libgit2"
BACK_OPENSSL="/root/Tools_ul/FreeKill/openssl-3.1.8/android_openssl/"

NDK_VERSION="27.2.12479018"
ANDROID_API=23

############################################
# 环境变量
############################################
export ANDROID_SDK_ROOT="$ANDROID"
export ANDROID_NDK_ROOT="$ANDROID/ndk/$NDK_VERSION"

export PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
export PATH="$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH"

############################################
# 1. Android SDK（如果未初始化）
############################################
if [ ! -d "$ANDROID/platforms" ]; then
  echo ">>> Android SDK init..."

  unzip -o "$ANDROID/commandlinetools-linux-9477386_latest.zip" -d "$ANDROID"

  yes | "$ANDROID/cmdline-tools/bin/sdkmanager" \
    --sdk_root="$ANDROID" \
    "platforms;android-35" \
    "platform-tools" \
    "build-tools;35.0.0" \
    "ndk;$NDK_VERSION"
fi

############################################
# 2. OpenSSL（离线构建）
############################################
if [ ! -f "$OPENSSL_DIR/libssl_3.so" ]; then
  echo ">>> Build OpenSSL..."

  cd "$ROOT"
  tar xf "$ROOT/openssl-3.1.8.tar.gz"

  cd "$OPENSSL_DIR"

  ./Configure shared android-arm64 \
    -U__ANDROID_API__ -D__ANDROID_API__=$ANDROID_API

  make -j$(nproc) SHLIB_VERSION_NUMBER= build_libs

  cp libcrypto.so libcrypto_3.so
  cp libssl.so libssl_3.so

  patchelf --set-soname libcrypto_3.so libcrypto_3.so
  patchelf --set-soname libssl_3.so libssl_3.so
  patchelf --replace-needed libcrypto.so libcrypto_3.so libssl_3.so

  ########################################
  # 使用本地 android_openssl（关键）
  ########################################
  rm -rf include || true

  cp -r "$BACK_OPENSSL/ssl_3/include" .
  cp -r "$BACK_OPENSSL/ssl_3/arm64-v8a/libcrypto_3.so" .
  cp -r "$BACK_OPENSSL/ssl_3/arm64-v8a/libssl_3.so" .

  #cp -r include/openssl "$PROJECT/include"
fi

cp -r "$OPENSSL_DIR/include/openssl" "$PROJECT/include"

############################################
# 3. libgit2（Android交叉编译）
############################################
if [ ! -f "$LIBGIT2_DIR/build/libgit2.so" ]; then
  echo ">>> Build libgit2..."

  cd "$LIBGIT2_DIR"
  git checkout v1.9.0

  rm -rf build
  mkdir build
  cd build

  cmake .. \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTS=OFF \
    -DBUILD_CLI=OFF \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_SYSTEM_VERSION=29 \
    -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
    -DCMAKE_ANDROID_NDK="$ANDROID_NDK_ROOT" \
    -DOPENSSL_INCLUDE_DIR="$OPENSSL_DIR/include" \
    -DOPENSSL_CRYPTO_LIBRARY="$OPENSSL_DIR/libcrypto_3.so" \
    -DOPENSSL_SSL_LIBRARY="$OPENSSL_DIR/libssl_3.so"

  make -j$(nproc)

  cp libgit2.so "$OPENSSL_DIR/"
fi

############################################
# 4. Qt 翻译文件
############################################
echo ">>> Qt lrelease"

"$QT_HOST/bin/lrelease" /root/Tools_ul/FreeKill/FreeKill/lang/zh_CN.ts || true
"$QT_HOST/bin/lrelease" /root/Tools_ul/FreeKill/FreeKill/lang/en_US.ts || true

cp /root/Tools_ul/FreeKill/FreeKill/lang/zh_CN.qm "$PROJECT/" || true
cp /root/Tools_ul/FreeKill/FreeKill/lang/en_US.qm "$PROJECT/" || true

############################################
# 5. Android assets 处理
############################################
cd "$PROJECT/android"

sed -i 's/function //g' copy_assets.sh || true
dos2unix copy_assets.sh || true
chmod +x copy_assets.sh || true

./copy_assets.sh || true

mkdir -p assets/res/certs
cp -r /etc/ssl/certs assets/res/ || true
cp /usr/share/ca-certificates/mozilla/* assets/res/certs/ || true

############################################
# 6. 版本号生成
############################################
FKVER=$(grep 'project(FreeKill' "$PROJECT/CMakeLists.txt" | cut -d ' ' -f 3 | tr -d ')')

echo "$FKVER" > "$PROJECT/fk_ver"

chmod +x "$PROJECT/genfkver.sh" || true
dos2unix "$PROJECT/genfkver.sh" || true

cp "$PROJECT/fk_ver" "$PROJECT/android/assets/res" || true

############################################
# 7. 清理 build
############################################
rm -rf "$PROJECT/build"

############################################
# Qt Android Signing (correct CI-style)
############################################

export QT_ANDROID_KEYSTORE_PATH="$PROJECT/freekill-release.keystore"
export QT_ANDROID_KEYSTORE_ALIAS="freekill"
export QT_ANDROID_KEYSTORE_STORE_PASS="123456"
export QT_ANDROID_KEYSTORE_KEY_PASS="123456"

############################################
# 8. Qt Android build
############################################
"$QT_ANDROID/bin/qt-cmake" \
  -S "$PROJECT" \
  -B "$PROJECT/build" \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DQT_HOST_PATH="$QT_HOST"

cd "$PROJECT/build"

dos2unix "$PROJECT/genfkver.sh" || true

make -j2

############################################
# 9. APK 签名 /root/Tools_ul/FreeKill/android
############################################
APK_UNSIGNED=$(find "$PROJECT/build/android-build/build/outputs/apk/release" -name "*unsigned.apk" | head -n 1 || true)

if [ -n "$APK_UNSIGNED" ]; then
  echo ">>> Signing APK..."

  "$ANDROID/build-tools/35.0.0/apksigner" sign \
    --ks "$PROJECT/freekill-release.keystore" \
    --ks-key-alias freekill \
    --ks-pass pass:123456 \
    --key-pass pass:123456 \
    --out "${APK_UNSIGNED%-unsigned.apk}-signed.apk" \
    "$APK_UNSIGNED"
fi

echo ">>> BUILD SUCCESS"