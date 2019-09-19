# eLife-JATS-schematron
Schematron for all JATS eLife content.

2 Schematron files are intended to be used:
- `src/pre-JATS-schematron.sch` (for pre-author validation).
- `src/final-JATS-schematron.sch` (for post-author validation).

`src/final-package-JATS-schematron.sch` is an extension of `src/final-JATS-schematron.sch`, which includes java based checks for the presence of assets referenced in the XML. This is not intended to be used outside of oXygen.

These three files are all derived from running `xquery/refactor.xq` on `src/schematron.sch`. `src/schematron.sch` is not intended to be used as a Schematron file itself, rather treated as master file from which other files are derived and all patterns can be tested.

## Copy-edit
- `src/copy-edit.sch` is also included and intended to be used to determine whether US English or UK English should be used throughout an article (and what words need changing in order to achieve consistency)

## Testing
An XSpec file is generated from `src/schematron.sch` and `src/copy-edit.sch` when `xquery/refactor.xq` is run (`test/xspec/schematron.xspec` and `test/xspec/copy-edit.xspec`) (XSpec: https://github.com/xspec/xspec/wiki).

XSpec unit testing is carried out on a pr based on every `test/xspec/*.xspec`.

### In depth info for writing tests
For every `sch:assert` and `sch:report` there is both a `pass.xml` and `fail.xml` file. It's expected that `fail.xml` will fire, but `pass.xml` will not. A Schemalet file is included in each folder, which allows for default validation in oXygen when writing the tests. Schemalets also include a test for the context of the rule being tested - i.e. for a test in the context of `article-meta`, there must be an `article-meta` element as a descendant of the `root` element in both test files for them to pass unit testing.

Schemalets and new pass/fail cases are generated from `src/schematron.sch` using `xquery/write-tests.xq` (generated XML files only include `<root><article/></root>` and need content added - as specified above).

Running `xquery/get-xspec-failures.xq` provides a list of pass/fail cases which do not pass the unit testing (based on the latest local output of `xspec/xspec/schematron-result.xml` and `xspec/xspec/copy-edit-result.xml`).

Less robust Schematron unit testing can also be carried out in BaseX using `xquery/old/test-schematron.xq`, which makes use of Schematron for BaseX: https://github.com/Schematron/schematron-basex.
