# eLife-JATS-schematron
Schematron for all JATS eLife content

2 Schematron files are intended to be used:
- `pre-JATS-schematron.sch` (for pre-author validation)
- `final-JATS-schematron.sch` (for post-author validation)

`final-package-JATS-schematron.sch` is an extension of final-JATS-schematron.sch, which includes java based checks for assets referenced in the XML.

These files are all derived from running `xquery/refactor.xq` on `schematron.sch` (which is not intended to be used as a Schematron file in itself).

Test files to be added soon...
