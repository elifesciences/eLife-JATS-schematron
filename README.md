# eLife-JATS-schematron
Schematron for all JATS eLife content.

2 Schematron files are intended to be used:
- `pre-JATS-schematron.sch` (for pre-author validation).
- `final-JATS-schematron.sch` (for post-author validation).

`final-package-JATS-schematron.sch` is an extension of `final-JATS-schematron.sch`, which includes java based checks for the presence of assets referenced in the XML. This is not intended to be used outside of oXygen.

These three files are all derived from running `xquery/refactor.xq` on `schematron.sch`. `schematron.sch` is not intended to be used as a Schematron file itself, rather treated as master file from which other files are derived and all patterns can be tested.

## Testing
Generate an XSpec file from `schematron.sch` using `xquery/schematron2xspex.xq`, which outputs `xspec/schematron.xspec` along with a version of that Schematron (XSpec: https://github.com/xspec/xspec/wiki).

For every `sch:assert` and `sch:report` there is both a `pass.xml` and `fail.xml` file. It's expected that `fail.xml` will fire, but `pass.xml` will not. A Schemalet file is included in each folder, which allows for validation in oXygen when writing the tests. Schemalets and new pass/fail cases are generated from `schematron.sch` using `xquery/write-tests.xq` (generated XML files only include `<article/>` and need content added).

Less robust Schematron unit testing can also be carried out in BaseX using `xquery/test-schematron.xq`.
