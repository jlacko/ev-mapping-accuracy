rm -rf ./ocm-export
git clone --filter=blob:none --no-checkout --depth 1 --sparse git@github.com:openchargemap/ocm-export.git
cd ./ocm-export
git sparse-checkout set data/CZ
git checkout
