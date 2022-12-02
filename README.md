# CAS_SA_Transfer

This repository contains all relevant documents related to the transfer project defined by I.CAS-SA.2201 (HSLU I.CAS Software Architecture 1).

## Generate diagrams & documentation

Launch a terminal in the repository root and execute the following command:

```
docker-compose up
```

The resulting [Structurizr DSL](https://structurizr.com/dsl) diagrams are stored in `./c4_diagrams/generated`, the exported [AsciiDoc](https://asciidoc.org/) PDF documentation (via [AsciiDoctor](https://asciidoctor.org/)) in `./arc42_documentation`.

## Build Workflow Status (currently manual trigger)
(C4 diagrams & arc42 PDF generated)

![build status](https://github.com/markuskaufmann/CAS_SA_Transfer/actions/workflows/build.yml/badge.svg)
