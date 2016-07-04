#!/bin/bash

# Compile
# -------
chmod +x configure

if [ `uname` == Linux ]; then

    # Download QtWebkit
    curl "http://linorg.usp.br/Qt/community_releases/5.6/${PKG_VERSION}/qtwebkit-opensource-src-${PKG_VERSION}.tar.xz" > qtwebkit.tar.xz
    unxz qtwebkit.tar.xz
    tar xf qtwebkit.tar
    mv qtwebkit-opensource-src* qtwebkit
    patch -p0 < ${RECIPE_DIR}/0001-qtwebkit-old-ld-compat.patch
    patch -p0 < ${RECIPE_DIR}/0002-qtwebkit-ruby-1.8.patch
    patch -p0 < ${RECIPE_DIR}/0003-qtwebkit-O_CLOEXEC-workaround.patch
    patch -p0 < ${RECIPE_DIR}/0004-qtwebkit-CentOS5-Fix-fucomip-compat-with-gas-2.17.50.patch
    rm qtwebkit.tar

    MAKE_JOBS=$CPU_COUNT

    ./configure -prefix $PREFIX \
                -libdir $PREFIX/lib \
                -bindir $PREFIX/bin \
                -headerdir $PREFIX/include/qt \
                -archdatadir $PREFIX \
                -datadir $PREFIX \
                -L $PREFIX/lib \
                -I $PREFIX/include \
                -release \
                -opensource \
                -confirm-license \
                -shared \
                -nomake examples \
                -nomake tests \
                -verbose \
                -skip enginio \
                -skip location \
                -skip sensors \
                -skip serialport \
                -skip serialbus \
                -skip quickcontrols2 \
                -skip wayland \
                -skip canvas3d \
                -skip 3d \
                -skip webengine \
                -system-libjpeg \
                -system-libpng \
                -system-zlib \
                -qt-pcre \
                -qt-xcb \
                -qt-xkbcommon \
                -xkb-config-root $PREFIX/lib \
                -dbus \
                -no-linuxfb \
                -no-libudev \
                -D _X_INLINE=inline \
                -D XK_dead_currency=0xfe6f \
                -D XK_ISO_Level5_Lock=0xfe13 \
                -D FC_WEIGHT_EXTRABLACK=215 \
                -D FC_WEIGHT_ULTRABLACK=FC_WEIGHT_EXTRABLACK \
                -D GLX_GLXEXT_PROTOTYPES

# Currently broken since CentOS 5.11 only has gtk2 version 2.10.4:
# -gtkstyle \
# Digging into git history gives:
# pushd /f/upstreams/qt-project/qt5/qtbase
# git blame configure | grep "cflags gtk"
# ebca7d2ea (J-P Nurmi                  2013-01-29 17:02:54 +0100 5135)         QT_CFLAGS_QGTK2=`$PKG_CONFIG --cflags gtk+-2.0 ">=" 2.18 atk 2>/dev/null`
# git blame configure ebca7d2ea^ | grep "cflags gtk"
# 2cce297b5 (J-P Nurmi                  2012-10-08 15:10:44 +0200 4475)         QT_CFLAGS_QGTKSTYLE=`$PKG_CONFIG --cflags gtk+-2.0 ">=" 2.18 atk 2>/dev/null`
# git blame configure 2cce297b5^ | grep "cflags gtk"
# 842a0b094 (Morten Johan Sorvig        2012-04-24 14:23:02 +0200 4479)         QT_CFLAGS_QGTKSTYLE=`$PKG_CONFIG --cflags gtk+-2.0 ">=" 2.10 atk 2>/dev/null`

# Also broken is OpenGL:
# QXcbConnection: Failed to initialize XRandr
# QXcbIntegration: Cannot create platform OpenGL context, neither GLX nor EGL are enabled
# Probably .. https://bugreports.qt.io/browse/QTBUG-43784

# Finally (at least) 32-bit Webkit problem with Sypder:
# ImportError: /home/carlos/miniconda/envs/test-spy/lib/python2.7/site-packages/PyQt5/../../../libQt5WebKit.so.5: cannot restore segment prot after reloc: Permission denied

# If we must not remove strict_c++ from qtbase/mkspecs/features/qt_common.prf
# (0007-qtbase-CentOS5-Do-not-use-strict_c++.patch) then we need to add these
# defines instead:
# -D __u64="unsigned long long" \
# -D __s64="__signed__ long long" \
# -D __le64="unsigned long long" \
# -D __be64="__signed__ long long"

    LD_LIBRARY_PATH=$PREFIX/lib make -j $MAKE_JOBS || exit 1
    make install
fi

if [ `uname` == Darwin ]; then
    # Let Qt set its own flags and vars
    for x in OSX_ARCH CFLAGS CXXFLAGS LDFLAGS
    do
        unset $x
    done

    export MACOSX_DEPLOYMENT_TARGET=10.7
    MAKE_JOBS=$(sysctl -n hw.ncpu)

    ./configure -prefix $PREFIX \
                -libdir $PREFIX/lib \
                -bindir $PREFIX/bin \
                -headerdir $PREFIX/include/qt \
                -archdatadir $PREFIX \
                -datadir $PREFIX \
                -L $PREFIX/lib \
                -I $PREFIX/include \
                -release \
                -opensource \
                -confirm-license \
                -shared \
                -nomake examples \
                -nomake tests \
                -verbose \
                -skip enginio \
                -skip location \
                -skip sensors \
                -skip serialport \
                -skip script \
                -skip serialbus \
                -skip quickcontrols2 \
                -skip wayland \
                -skip canvas3d \
                -skip 3d \
                -system-zlib \
                -qt-pcre \
                -qt-freetype \
                -qt-libjpeg \
                -qt-libpng \
                -c++11 \
                -no-framework \
                -no-dbus \
                -no-mtdev \
                -no-harfbuzz \
                -no-xinput2 \
                -no-xcb-xlib \
                -no-libudev \
                -no-egl \
                -no-openssl

    DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib make -j $MAKE_JOBS || exit 1
    make install
fi


# Post build setup
# ----------------

# Remove static libs
rm -rf $PREFIX/lib/*.a

# Add qt.conf file to the package to make it fully relocatable
cp $RECIPE_DIR/qt.conf $PREFIX/bin/
