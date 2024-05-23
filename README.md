# eLife-JATS-schematron

Schematron for all JATS eLife content.

There are two sets of schematron files:

### VOR schematron

3 Schematron files are intended to be used:

- `src/pre-JATS-schematron.sch` (for pre-author validation).
- `src/dl-schematron.sch` (for decision letter/author response only related checks)
- `src/final-JATS-schematron.sch` (for post-author validation).

`src/final-package-JATS-schematron.sch` is an extension of `src/final-JATS-schematron.sch`, which includes java based checks for the presence of assets referenced in the XML. This is only intended for local use (via oXygen).

These three files are all derived from running `xquery/refactor.xq` on `src/schematron.sch`. `src/schematron.sch` is not intended to be used as a Schematron file itself, rather treated as master file from which other VOR-related files are derived and all patterns can be tested.

### Reviewed preprint schematron

- `src/rp-schematron.sch` is used for validating eLife reviewed preprints. Additionally included is `src/meca-manifest-schematron.sch` which is intended to be used locally (via oXygen) to validate the manifest files within MECA packages produced by production vendors.

## Testing

An XSpec file is generated from `src/schematron.sch` and `src/rp-schematron.sch` when `xquery/refactor.xq` is run (`test/xspec/schematron.xspec` and `test/xspec/rp-schematron.xspec`) (XSpec: https://github.com/xspec/xspec/wiki).

XSpec unit testing is carried out on a pr based on every `test/xspec/*.xspec`.

### In depth info for writing tests

For every `sch:assert` and `sch:report` there is both a `pass.xml` and `fail.xml` file. It's expected that `fail.xml` will fire, but `pass.xml` will not. A Schemalet file is included in each folder, which allows for default validation in oXygen when writing the tests. Schemalets also include a test for the context of the rule being tested - i.e. for a test in the context of `article-meta`, there must be an `article-meta` element as a descendant of the `root` element in both test files for them to pass unit testing.

Schemalets and new pass/fail cases are generated from `src/schematron.sch` using `xquery/write-tests.xq` (generated XML files only include `<root><article/></root>` and need content added - as specified above).

Running `xquery/get-xspec-failures.xq` provides a list of pass/fail cases which do not pass the unit testing (based on the latest local output of `xspec/xspec/schematron-result.xml` and `xspec/xspec/rp-schematron-result.xml`).

## Docker

You can now build a container based on basexhttp that contains the schematron and can be used for testing.

```
docker build . --tag elife-schematron:test
docker run --rm --memory="512Mi" -p 1984:1984 -p 8984:8984 elife-schematron:test
```

You can then interact with the service on port 8984 for example using either...

```
curl -F xml=@elife45905.xml http://localhost:8984/schematron/pre
curl -F xml=@elife45905.xml http://localhost:8984/schematron/final
```
