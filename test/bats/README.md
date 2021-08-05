# BATS tests

bats is expected to be installed and in the path

Helper modules have been added as subpackages:
```
git submodule add https://github.com/ztombol/bats-support test/bats/lib/bats-support
git submodule add https://github.com/ztombol/bats-assert test/bats/lib/bats-assert
git submodule add https://github.com/jasonkarns/bats-mock test/bats/lib/bats-mock
```
If you want to use bats directly without running first at least once via the scripts in `build/ci`, then you must 
initialize (populate) the subpackages using:
```git submodule update --init --recursive```

Then, to run a test, execute the test files (and add the options for bats), e.g.:
```./example_test.bats -t```

For instructions on using bats and the helpers see:
* https://github.com/bats-core/bats-core
* https://github.com/ztombol/bats-docs
* https://github.com/jasonkarns/bats-mock

Sparse checkout could be enabled but I found the core files only for bats-mock, so it remains a TODO for now:
```
cd test/bats/lib/bats-mock
git config core.sparsecheckout true

# And from the root of the repo
echo stub.bash >> .git/modules/test/bats/lib/bats-mock/info/sparse-checkout
echo binstub >> .git/modules/test/bats/lib/bats-mock/info/sparse-checkout
```
