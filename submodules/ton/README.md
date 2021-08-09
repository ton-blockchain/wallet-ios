0. make sure you have installed openssl and cmake(optional ninja)
1. git submodule update --init --recursive
2. cd tonlib-src
3. mkdir build
4. cd build
5. cmake --DOPENSSL_ROOT_DIR=*openssl_path* .. (optional -GNinja)
6. cmake --build . --target prepare_cross_compiling (optional ninja prepare_cross_compiling)
7. cd ..
8. rm -rf build
9. cd ..
10. profit=)
