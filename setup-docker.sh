#!/bin/bash -e
set -e
BRANCH=dev
RUNTIME_BRANCH=dev

echo -e "\033[32mPhase 0: \033[33mChecking\033[m";

which java || ( echo -e "\033[31mCheck failed: java not found. Please install JDK 21: \033[32https://gravitlauncher.com/install\033[m" && exit 1 );
which javac || ( echo -e "\033[31mCheck failed: javac not found. Please install JDK 21: \033[32https://gravitlauncher.com/install\033[m" && exit 1 );
which git || ( echo -e "\033[31mCheck failed: git not found. Please install git\033[m" && exit 1 );
#which curl || ( echo -e "\033[31mCheck failed: curl not found. Please install curl\033[m" && exit 1 );

(javac -version | grep " 21") || ( echo -e "\033[31mCheck failed: javac version unknown. Supported Java 21+. Please install JDK 21: \033[32https://gravitlauncher.com/install\033[m" && exit 1 );

echo -e "\033[32mPhase 1: \033[33mClone main repository\033[m";
git clone -b $BRANCH  https://github.com/GravitLauncher/Launcher.git src;
cd src;
sed -i 's/git@github.com:/https:\/\/github.com\//' .gitmodules;
git submodule sync;
git submodule update --init --recursive;
echo -e "\033[32mPhase 2: \033[33mBuild\033[m";
./gradlew -Dorg.gradle.daemon=false assemble || ( echo -e "\033[31mBuild failed. Stopping\033[m" && exit 100 );
cd ..;
mkdir libraries;
mkdir launcher-libraries;
mkdir launcher-libraries-compile;
echo -e "\033[32mPhase 3: \033[33mClone runtime repository\033[m";
git clone -b $RUNTIME_BRANCH https://github.com/GravitLauncher/LauncherRuntime.git srcRuntime;
cd srcRuntime;
./gradlew -Dorg.gradle.daemon=false assemble || ( echo -e "\033[31mBuild failed. Stopping\033[m" && exit 100 );
cd ..;
echo -e "\033[32mPhase 4: \033[33mCopy files\033[m";
cp src/LaunchServer/build/libs/LaunchServer.jar .;
cp -r src/LaunchServer/build/libs/libraries ./libraries/default;
cp -r src/LaunchServer/build/libs/launcher-libraries ./launcher-libraries/default;
cp -r src/LaunchServer/build/libs/launcher-libraries-compile ./launcher-libraries-compile/default || true;
mkdir modules;
cp -r srcRuntime/runtime .;
mkdir launcher-modules;
cp srcRuntime/build/libs/JavaRuntime*.jar launcher-modules/;
mkdir compat;
cp -r srcRuntime/compat compat/runtime;
cp -r src/ServerWrapper/build/libs/ServerWrapper.jar compat/;
mkdir compat/launchserver-modules
cp -r src/modules/*_module/build/libs/*_module.jar compat/launchserver-modules
mkdir compat/launcher-modules
cp -r src/modules/*_lmodule/build/libs/*_lmodule.jar compat/launcher-modules
mkdir data
ln -s ../data/libraries libraries/custom
ln -s ../data/launcher-libraries launcher-libraries/custom
ln -s ../data/modules modules/custom
ln -s ../data/launcher-modules launcher-modules/custom
cat <<EOF > install_launchserver_module.sh
#!/bin/bash -e
set -e
if [ \$# -eq 0 ]; then
    >&2 echo "Usage: install_launchserver_module.sh MODULE_NAME"
    exit 1
fi
MODULE_FILE="compat/launchserver-modules/\$1_module.jar"
if test -f \$MODULE_FILE
then
    ln -s ../../\$MODULE_FILE data/modules/\$1_module.jar
else
    echo \$MODULE_FILE not exist
fi
EOF
chmod +x install_launchserver_module.sh

cat <<EOF > install_launcher_module.sh
#!/bin/bash -e
set -e
if [ \$# -eq 0 ]; then
    >&2 echo "Usage: install_launcher_module.sh MODULE_NAME"
    exit 1
fi
MODULE_FILE="compat/launcher-modules/\$1_lmodule.jar"
if test -f \$MODULE_FILE
then
    ln -s ../../\$MODULE_FILE data/launcher-modules/\$1_lmodule.jar
else
    echo \$MODULE_FILE not exist
fi
EOF
chmod +x install_launcher_module.sh

cat <<EOF > start.sh
#!/bin/bash
mkdir -p libraries
mkdir -p launcher-libraries
mkdir -p modules
mkdir -p launcher-modules
mkdir -p updates
chmod +rx updates
if test -f launchserver_args.txt
then
    true
else
    echo '-Xmx512M' > launchserver_args.txt
fi
if test -f runtime
then
    true
else
    cp -r ../runtime runtime
fi
exec java -Xmx512M -Dlaunchserver.dir.libraries=../libraries -Dlaunchserver.dir.launcher-libraries=../launcher-libraries -Dlaunchserver.dir.modules=../modules -Dlaunchserver.dir.launcher-modules=../launcher-modules -Dlauncher.useSlf4j=true -jar ../LaunchServer.jar \$@
EOF
chmod +x start.sh
echo -e "\033[32mPhase 4: \033[33mDelete source files\033[m";
rm -rf src
rm -rf srcRuntime
echo -e "\033[32mSetup completed\033[m"
