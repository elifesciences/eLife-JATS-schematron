# eLife-JATS-schematron
Schematron for all JATS eLife content.

2 Schematron files are intended to be used:
- `pre-JATS-schematron.sch` (for pre-author validation).
- `final-JATS-schematron.sch` (for post-author validation).

`final-package-JATS-schematron.sch` is an extension of `final-JATS-schematron.sch`, which includes java based checks for the presence of assets referenced in the XML. This is not intended to be used outside of oXygen.

These three files are all derived from running `xquery/refactor.xq` on `schematron.sch`. `schematron.sch` is not intended to be used as a Schematron file itself, rather treated as master file from which other files are derived and all patterns can be tested.

## Testing
Generate an XSpec file from `schematron.sch` using `xquery/refactor.xq`, which outputs `xspec/schematron.xspec` along with a version of that Schematron (XSpec: https://github.com/xspec/xspec/wiki).

For every `sch:assert` and `sch:report` there is both a `pass.xml` and `fail.xml` file. It's expected that `fail.xml` will fire, but `pass.xml` will not. A Schemalet file is included in each folder, which allows for validation in oXygen when writing the tests. Schemalets also include a test for the context of the rule being tested - i.e. for a test in the context of `article-meta`, there must be an `article-meta` element as a descendant of the `root` element in both test files for them to not pass the XSpec testing.

Schemalets and new pass/fail cases are generated from `schematron.sch` using `xquery/write-tests.xq` (generated XML files only include `<root><article/></root>` and need content added - as specified above).

Less robust Schematron unit testing can also be carried out in BaseX using `xquery/old/test-schematron.xq`, which makes use of Schematron for BaseX: https://github.com/Schematron/schematron-basex.
