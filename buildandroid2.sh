8  cd "Tools_ul/FreeKill/FreeKill"

    /root/Tools_ul/FreeKill/FreeKill/build/android-build/
    /root/Tools_ul/Qt/6.10.0/gcc_64
    /root/Tools_ul/FreeKill/openssl-3.1.8
    /root/Tools_ul/FreeKill/libgit2
    /root/Tools_ul/FreeKill/android  android_sdk



    

   10  cd /root/Tools_ul/FreeKill/              
   
   11  ls
   12  cd /root/Tools_ul/FreeKill/android/
 
   13  ls
  先要上传包，在百度云盘里放
   14  unzip /root/Tools_ul/FreeKill/android/commandlinetools-linux-9477386_latest.zip
   15  yes | /root/Tools_ul/FreeKill/android/cmdline-tools/bin/sdkmanager --sdk_root="/root/Tools_ul/FreeKill/android"           "platforms;android-35"           "platform-tools"           "build-tools;35.0.0"           "ndk;27.2.12479018"
   16  cd /root/Tools_ul/FreeKill/
   
   上传包
   17  tar xf /root/Tools_ul/FreeKill/openssl-3.1.8.tar.gz
   18  cd /root/Tools_ul/FreeKill/openssl-3.1.8
    
   19  export ANDROID_SDK_ROOT=/root/Tools_ul/FreeKill/android
   20  export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/27.2.12479018
   21  PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
   22  ./Configure shared android-arm64 -U__ANDROID_API__ -D__ANDROID_API__=23
   23  make -j$(nproc) SHLIB_VERSION_NUMBER= build_libs
   24  cp /root/Tools_ul/FreeKill/openssl-3.1.8/libcrypto.so /root/Tools_ul/FreeKill/openssl-3.1.8/libcrypto_3.so
   25  cp /root/Tools_ul/FreeKill/openssl-3.1.8/libssl.so /root/Tools_ul/FreeKill/openssl-3.1.8/libssl_3.so
   26  patchelf --set-soname /root/Tools_ul/FreeKill/openssl-3.1.8/libcrypto_3.so /root/Tools_ul/FreeKill/openssl-3.1.8/libcrypto_3.so
   27  patchelf --set-soname /root/Tools_ul/FreeKill/openssl-3.1.8/libssl_3.so /root/Tools_ul/FreeKill/openssl-3.1.8/libssl_3.so
   28  patchelf --replace-needed /root/Tools_ul/FreeKill/openssl-3.1.8/libcrypto.so /root/Tools_ul/FreeKill/openssl-3.1.8/libcrypto_3.so /root/Tools_ul/FreeKill/openssl-3.1.8/libssl_3.so
   29  ls
   在有代理的机器下载好上传
   30  git clone https://github.com/KDAB/android_openssl
   31  ls
   32  rm -rf /root/Tools_ul/FreeKill/openssl-3.1.8/include
   33  cp -r /root/Tools_ul/FreeKill/openssl-3.1.8/android_openssl/ssl_3/include /root/Tools_ul/FreeKill/openssl-3.1.8/
   34  cp -r /root/Tools_ul/FreeKill/openssl-3.1.8/android_openssl/ssl_3/arm64-v8a/libcrypto_3.so /root/Tools_ul/FreeKill/openssl-3.1.8/
   35  cp -r /root/Tools_ul/FreeKill/openssl-3.1.8/android_openssl/ssl_3/arm64-v8a/libssl_3.so /root/Tools_ul/FreeKill/openssl-3.1.8/
   36  cd /root/Tools_ul/FreeKill/FreeKill
   37  cp -r /root/Tools_ul/FreeKill/openssl-3.1.8/include/openssl /root/Tools_ul/FreeKill/FreeKill/include
   38  cd /root/Tools_ul/FreeKill/
   先上传 libgit2目录
   39  cd /root/Tools_ul/FreeKill/libgit2

   47  mkdir /root/Tools_ul/FreeKill/libgit2/build
   48  cd /root/Tools_ul/FreeKill/libgit2/build
   49  export ANDROID_SDK_ROOT=/root/Tools_ul/FreeKill/android
   50  export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/27.2.12479018
   
   51  PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
   52  cmake ..           -DBUILD_SHARED_LIBS=ON           -DBUILD_TESTS=OFF           -DBUILD_CLI=OFF           -DCMAKE_SYSTEM_NAME=Android           -DCMAKE_SYSTEM_VERSION=29           -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a           -DCMAKE_ANDROID_NDK=${ANDROID_NDK_ROOT}           -DOPENSSL_INCLUDE_DIR="/root/Tools_ul/FreeKill/openssl-3.1.8/include"           -DOPENSSL_CRYPTO_LIBRARY="/root/Tools_ul/FreeKill/openssl-3.1.8/libcrypto_3.so"           -DOPENSSL_SSL_LIBRARY="/root/Tools_ul/FreeKill/openssl-3.1.8/libssl_3.so"
   53  make -j$(nproc)
   54  cp /root/Tools_ul/FreeKill/libgit2/build/libgit2.so /root/Tools_ul/FreeKill/openssl-3.1.8/
   55  sudo apt-get install -y swig
   56  aqt install-qt     --outputdir /root/Tools_ul/Qt     linux android 6.10.0 android_arm64_v8a     -m qtmultimedia qt5compat qtshadertools
   57  pip3 install -U aqtinstall py7zr
   58  
   59  cd /root/Tools_ul/FreeKill/FreeKill/
   60
   63  /root/Tools_ul/Qt/6.10.0/gcc_64/bin/lrelease /root/Tools_ul/FreeKill/FreeKill/lang/zh_CN.ts
   64  /root/Tools_ul/Qt/6.10.0/gcc_64/bin/lrelease /root/Tools_ul/FreeKill/FreeKill/lang/en_US.ts
   65  cp /root/Tools_ul/FreeKill/FreeKill/lang/zh_CN.qm /root/Tools_ul/FreeKill/FreeKill
   66  cp /root/Tools_ul/FreeKill/FreeKill/lang/en_US.qm /root/Tools_ul/FreeKill/FreeKill
   67  FKVER=$(cat CMakeLists.txt | grep 'project(FreeKill' | cut -d ' ' -f 3)
   68  cd /root/Tools_ul/FreeKill/FreeKill/android
   69  sed -i 's/function //g' copy_assets.sh  # FIX THIS
   下面要先去掉windows格式再执行
   
   74  dos2unix /root/Tools_ul/FreeKill/FreeKill/android/copy_assets.sh
   75  /root/Tools_ul/FreeKill/FreeKill/android/copy_assets.sh || echo "" # fail on copy cert, ubuntu is not arch
   76  cd /root/Tools_ul/FreeKill/FreeKill/android/assets/res
   77  cp -r /etc/ssl/certs /root/Tools_ul/FreeKill/FreeKill/android/assets/res
   78  cp /usr/share/ca-certificates/mozilla/* /root/Tools_ul/FreeKill/FreeKill/assets/res/certs/
   下面文件不存在，不用执行
   79  

   81  cd /root/Tools_ul/FreeKill/FreeKill/android/
   82  echo ${FKVER%)} > /root/Tools_ul/FreeKill/FreeKill/fk_ver
   83
   84  chmod +x /root/Tools_ul/FreeKill/FreeKill/genfkver.sh
   85  cp /root/Tools_ul/FreeKill/FreeKill/fk_ver /root/Tools_ul/FreeKill/FreeKill/android/assets/res
   86  cd /root/Tools_ul/FreeKill/FreeKill/
   87
   88  
   89  现在是在build的上一级  /root/Tools_ul/FreeKill/FreeKill/
   90  rm -rf /root/Tools_ul/FreeKill/FreeKill/build
   91  
   93  /root/Tools_ul/Qt/6.10.0/android_arm64_v8a/bin/qt-cmake   -S .   -B /root/Tools_ul/FreeKill/FreeKill/build   -DCMAKE_BUILD_TYPE=MinSizeRel   -DQT_HOST_PATH=/root/Tools_ul/Qt/6.10.0/gcc_64
   94  cd /root/Tools_ul/FreeKill/FreeKill/build/
   97  dos2unix /root/Tools_ul/FreeKill/FreeKill/genfkver.sh
  101  make -j2

  105  /root/Tools_ul/FreeKill/android/build-tools/35.0.0/apksigner sign   --ks /root/Tools_ul/FreeKill/FreeKill/freekill-release.keystore   --ks-key-alias freekill   --ks-pass pass:123456   --key-pass pass:123456   --out /root/Tools_ul/FreeKill/FreeKill/build/android-build/build/outputs/apk/release/android-build-release-signed.apk   /root/Tools_ul/FreeKill/FreeKill/build/android-build/build/outputs/apk/release/android-build-release-unsigned.apk