# typical build scenario
```bash
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug \
  -DFFMPEG_CONFIGURE_EXTRAS="--enable-gpl|--enable-nonfree" \
  -DCMAKE_INSTALL_PREFIX=$HOME/arcana_install \
  ..
make && make install
```