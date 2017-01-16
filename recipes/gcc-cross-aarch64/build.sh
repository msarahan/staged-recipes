mkdir -p src
if [ -f src/linux-3.13.11.tar.gz ]; then
    echo "Linux already downloaded"
else
    curl -L https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.13.11.tar.xz -o src/linux-3.13.11.tar.xz
fi

ct-ng build

mkdir -p $PREFIX/etc/conda/activate.d
cp compiler_linux-64_linux-aarch64-activate.sh $PREFIX/etc/conda/activate.d

mkdir -p $PREFIX/etc/conda/deactivate.d
cp compiler_linux-64_linux-aarch64-deactivate.sh $PREFIX/etc/conda/deactivate.d
